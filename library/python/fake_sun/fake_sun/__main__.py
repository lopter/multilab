import click

from pathlib import Path as P

from . import apiserver, pwmcontroller
from .common.types import ClickContext


@click.group(name="Toolbelt for the fake-sun planters control stack.")
@click.option(
    "--state-file",
    default=P("/var/lib/fake-sun/state.json"),
    type=click.Path(dir_okay=False, path_type=P),  # type: ignore
    show_default=True,
    help="Path to the state file where settings are stored.",
)
@click.pass_context
def main(ctx: click.Context, state_file: P) -> None:
    ctx.obj = ClickContext(state_file_path=state_file)


main.add_command(pwmcontroller.main)
main.add_command(apiserver.main)
