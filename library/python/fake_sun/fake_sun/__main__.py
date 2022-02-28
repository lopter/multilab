import click
import logging
import subprocess
import sys

from typing import Dict

from fake_sun import pwm

logger = logging.getLogger("library.python.fake_sun")

PERIOD_NIGHT = "night"

PWM_PERIOD_NS = int(1E9) // 980  # Just shy of 1kHz


def _configure_pwm_chip(duty_cycle: float) -> pwm.PWM:
    assert .0 <= duty_cycle <= 1.
    chan = pwm.PWM(chip=0, channel=0)
    chan.export()
    if chan.period != PWM_PERIOD_NS:
        chan.period = PWM_PERIOD_NS
    duty_cycle_ns = int(PWM_PERIOD_NS * duty_cycle)
    if chan.duty_cycle != duty_cycle_ns:
        chan.duty_cycle = duty_cycle_ns
    return chan


@click.command(help="""Convert `redshift -v -p' to a PWM output.

The PWM is sent to the LED driver to adjust the COB LED brightness
in a planter.
""")
@click.option(
    "--max-brightness",
    default=1.0,
    help="Brightness will be clamped to this maximum rate between [0, 1]",
)
@click.option(
    "--latitude", "--lat",
    default="37.766574",
)
@click.option(
    "--longitude", "--lon",
    default="-122.323219"
)
def main(max_brightness: float, latitude: str, longitude: str) -> None:
    logging.basicConfig(level=logging.INFO)

    logger.info("OK")
    sys.exit(0)

    try:
        location = f"manual:{latitude}:{longitude}"
        cmd = ["redshift", "-v", "-p", "-m", "dummy", "-l", location]
        output = subprocess.check_output(cmd).decode()
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

    chan = _configure_pwm_chip(duty_cycle=max_brightness)
    enable = period != PERIOD_NIGHT
    if enable != chan.enable:
        chan.enable = enable


main()
