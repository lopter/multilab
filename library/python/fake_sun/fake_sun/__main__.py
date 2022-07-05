import click
import datetime
import logging
import re
import subprocess
import sys
import time

from typing import Dict

from fake_sun import pwm

logger = logging.getLogger("library.python.fake_sun")

PERIOD_NIGHT = "night"
PERIOD_TRANSITION = "transition"

PWM_PERIOD_NS = int(1E9) // 980  # Just shy of 1kHz


@click.command(help="""Convert `redshift -v -p' to a PWM output.

The PWM is sent to the LED driver to adjust the COB LED brightness
in a planter.
""")
@click.option(
    "--max-brightness",
    default=0.5,
    show_default=True,
    type=click.FloatRange(0.0, 1.0),
    help="Brightness will be clamped to this maximum rate between [0, 1]",
)
@click.option(
    "--latitude", "--lat",
    default="37.766574",
    show_default=True,
)
@click.option(
    "--longitude", "--lon",
    default="-122.323219",
    show_default=True,
)
def main(max_brightness: float, latitude: str, longitude: str) -> None:
    logging.basicConfig(
        level=logging.INFO,
        datefmt="%Y-%m-%dT%H:%M:%S%z",
        format="%(asctime)s %(name)s %(levelname)s %(message)s",
    )

    pwm_chan = _configure_pwm_chip()

    # we align on this duration so that different planters are synchronized.
    clock = datetime.timedelta(minutes=5).total_seconds()
    location = f"manual:{latitude}:{longitude}"
    cmd = ["redshift", "-v", "-p", "-m", "dummy", "-l", location]
    stderr = subprocess.DEVNULL
    while True:
        try:
            output = subprocess.check_output(cmd, stderr=stderr).decode()
        except subprocess.CalledProcessError:
            logger.exception("Could not call redshift")
            sys.exit(1)

        data_lines = (line.strip().lower() for line in output.splitlines())
        redshift_attrs: Dict[str, str] = {}
        for line in data_lines:
            if ":" not in line:
                continue
            k, v = line.split(sep=":", maxsplit=1)
            redshift_attrs[k.strip()] = v.strip()

        period = redshift_attrs.get("period")
        if not period:
            logger.error("Could not get period (night or day) from Redshift")
            sys.exit(1)
        logger.info(f"period={period}")

        brightness = max_brightness
        if period.startswith(PERIOD_TRANSITION):
            m = re.search(r"(\d+.\d+)%", period)
            if m is not None:
                brightness *= float(m.group(1)) / 100
        duty_cycle_ns = int(PWM_PERIOD_NS * brightness)
        if pwm_chan.duty_cycle != duty_cycle_ns:
            pwm_chan.duty_cycle = duty_cycle_ns

        enable = period != PERIOD_NIGHT
        if enable != pwm_chan.enable:
            pwm_chan.enable = enable

        delay = clock - time.time() % clock
        while delay > 0:
            bed_time = time.monotonic()
            time.sleep(delay)
            delay -= time.monotonic() - bed_time


def _configure_pwm_chip() -> pwm.PWM:
    chan = pwm.PWM(chip=0, channel=0)
    chan.export()
    if chan.period != PWM_PERIOD_NS:
        chan.period = PWM_PERIOD_NS
    return chan
