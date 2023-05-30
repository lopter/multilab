import click
import datetime
import logging
import queue
import re
import socket
import subprocess
import time

from typing import cast, Dict, Optional

from fake_sun.common import models
from fake_sun.common.types import ClickContext, Period

from . import pwm, statefile

logger = logging.getLogger("library.python.fake_sun.pwmcontroller")

PWM_PERIOD_NS = int(1E9) // 980  # Just shy of 1kHz


@click.command(
    help="""Convert `redshift -v -p' to a PWM output.

The PWM is sent to the LED driver to adjust the COB LED brightness
in a planter.
""",
    name="pwmcontroller",
)
@click.option(
    "--max-brightness",
    default=0.5,
    show_default=True,
    type=click.FloatRange(0.0, 1.0),
    help=(
        "Brightness will be clamped to this maximum rate between [0, 1], "
        "unless a different value has been set in the state file."
    ),
)
@click.option(
    "--name",
    default=None,
    help=(
        "Name for this planter, if not already specified "
        "in state file, defaults to hostname"
    ),
)
@click.option(
    "--latitude", "--lat",
    default="37.766574",
    show_default=True,
)
@click.option(
    "--longitude", "--long",
    default="-122.323219",
    show_default=True,
)
@click.pass_context
def main(
    ctx: click.Context,
    max_brightness: float,
    name: Optional[str],
    latitude: str,
    longitude: str,
) -> None:
    logging.basicConfig(
        level=logging.INFO,
        datefmt="%Y-%m-%dT%H:%M:%S%z",
        format="%(asctime)s %(name)s %(levelname)s %(message)s",
    )

    pwm_chan = _configure_pwm_chip()
    redshift = _RedshiftPoller(latitude, longitude)

    state_file_path = cast(ClickContext, ctx.obj).state_file_path
    if state_file_path.exists():
        state = models.State.load(state_file_path)
    else:
        period, transition = redshift.poll()
        state = models.State(
            name=name if name is not None else _default_name(),
            period=period,
            brightness=max_brightness,
            morning_shift=datetime.timedelta(seconds=0),
        )
        state.store(state_file_path)  # so that it can be read by apiserver

    state_watcher = statefile.Watcher(state_file_path)
    state_watcher.start()
    try:
        logger.info("starting pwmcontroller")
        # we align on those durations so that
        # different planters are synchronized:
        clock = 60  # seconds
        transition_clock = 1
        # It would be better to actually compute that value based on current
        # datetime in case the daemon is restarted during the sunrise
        # transition and we miss when we go from night to sunrise.
        dawn = datetime.datetime(1970, 1, 1, tzinfo=datetime.timezone.utc)
        while True:
            try:
                period, transition = redshift.poll()
            except Exception:
                msg = "Could not get period (night or day) from Redshift"
                logger.exception(msg)
                break

            if state.period != period:
                if state.period == Period.NIGHT:
                    dawn = datetime.datetime.now(datetime.timezone.utc)
                if transition is None:
                    logger.info(f"period={period.value}")
                else:
                    logger.info(f"period={period.value} ({transition})")
                state.period = period
                state.store(state_file_path)

            brightness = _compute_brightness(dawn, state, period)
            _set_brightness(pwm_chan, brightness, transition)
            if not pwm_chan.enable:
                pwm_chan.enable = True

            c = transition_clock if transition is not None else clock
            delay = c - time.time() % c
            while delay > 0:
                start = time.monotonic()
                try:
                    state = state_watcher.channel.get(timeout=delay)
                    logger.info(f"received new state: {state}")
                    # immediately set the new brightness if it changed
                    # while accounting for morning_shift:
                    if state.brightness != brightness:
                        brightness = _compute_brightness(dawn, state, period)
                        _set_brightness(pwm_chan, brightness, transition)
                except queue.Empty:
                    pass
                delay -= time.monotonic() - start
    finally:
        state_watcher.stop()
        state_watcher.join()

    ctx.exit(1)


def _configure_pwm_chip() -> pwm.PWM:
    chan = pwm.PWM(chip=0, channel=0)
    chan.export()
    if chan.period != PWM_PERIOD_NS:
        chan.period = PWM_PERIOD_NS
    return chan


def _default_name() -> str:
    hostname = socket.gethostname()
    return hostname[:hostname.find('.')]


class _RedshiftPoller:

    _PERIOD_NIGHT = "night"
    _PERIOD_TRANSITION = "transition"

    def __init__(self, latitude: str, longitude: str) -> None:
        location = f"manual:{latitude}:{longitude}"
        self._cmd = ["redshift", "-v", "-p", "-m", "dummy", "-l", location]

    def poll(self) -> tuple[Period, Optional[float]]:
        stderr = subprocess.DEVNULL
        output = subprocess.check_output(self._cmd, stderr=stderr).decode()
        data_lines = (line.strip().lower() for line in output.splitlines())
        redshift_attrs: Dict[str, str] = {}
        for line in data_lines:
            if ":" not in line:
                continue
            k, v = line.split(sep=":", maxsplit=1)
            redshift_attrs[k.strip()] = v.strip()

        redshift_period = redshift_attrs["period"]
        period, transition = Period.DAY, None
        if redshift_period.startswith(self._PERIOD_TRANSITION):
            period = Period.TRANSITION
            m = re.search(r"(\d+.\d+)%", redshift_period)
            if m is not None:
                transition = float(m.group(1)) / 100
        elif redshift_period == self._PERIOD_NIGHT:
            period = Period.NIGHT

        return period, transition


def _set_brightness(
    pwm_chan: pwm.PWM,
    brightness: float,
    transition: Optional[float],
) -> None:
    if transition is not None:
        brightness *= transition
    duty_cycle_ns = int(PWM_PERIOD_NS * brightness)
    if pwm_chan.duty_cycle != duty_cycle_ns:
        logger.info(f"setting brightness to {brightness}")
        pwm_chan.duty_cycle = duty_cycle_ns


def _compute_brightness(
    dawn: datetime.datetime,
    state: models.State,
    period: Period,
) -> float:
    if period == Period.NIGHT:
        return 0.
    lights_on_time = dawn + state.morning_shift
    if datetime.datetime.now(datetime.timezone.utc) >= lights_on_time:
        return state.brightness
    return 0.