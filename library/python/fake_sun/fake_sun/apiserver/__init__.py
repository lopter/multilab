import click
import uvicorn

from . import server


@click.command(
    help="HTTP API to read or update the PWM controller state.",
    name="apiserver",
)
@click.option(
    "--host",
    type=str,
    default="127.0.0.1",
    help="Bind socket to this host.",
    show_default=True,
)
@click.option(
    "--port",
    type=int,
    default=8000,
    help="Bind socket to this port.",
    show_default=True,
)
@click.pass_context
def main(ctx: click.Context, host: str, port: int) -> None:
    server.app.state.click_context = ctx.obj
    uvicorn.run(server.app, host=host, port=port)
