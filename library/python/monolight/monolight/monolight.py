# Copyright (c) 2016, Louis Opter <louis@opter.org>
#
# This file is part of lightsd.
#
# lightsd is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# lightsd is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with lightsd.  If not, see <http://www.gnu.org/licenses/>.

import asyncio
import click
import logging
import signal
import sys
import pdb
import traceback

from . import bulbs, grids, ui


@click.command()
@click.option(
    "--lightsd-url",
    help="tcp+jsonrpc://host:port or unix+jsonrpc:///a/path",
)
def main(lightsd_url: str) -> None:
    logging.basicConfig(level=logging.INFO)
    logging.getLogger("library.python.monolight.ui").setLevel(logging.DEBUG)
    logging.getLogger("library.python.monolight").setLevel(logging.DEBUG)
    logging.getLogger("library.python.lightsc").setLevel(logging.WARN)

    # NOTE: this isn't good enough on Windows unless you pass --lightsd-url:
    # discovering lightsd's socket involves using asyncio.subprocess which
    # requires an IOCP event loop, which doesn't support UDP connections.
    loop = asyncio.get_event_loop()

    click.echo("connecting to serialoscd and lightsd...")

    try:
        loop.run_until_complete(asyncio.gather(
            loop.create_task(bulbs.start_lightsd_connection(lightsd_url)),
            loop.create_task(grids.start_serialosc_connection()),
        ))
    except Exception as ex:
        traceback.print_exc()
        click.echo(
            f"couldn't connect to lightsd and/or serialoscd, please check "
            f"that they are properly setup. error: {ex}"
        )
        loop.close()
        sys.exit(1)

    # Port 12002 is hardcoded in monome/serialosc.
    click.echo("serialoscd running at udp://serialoscd:12002")
    click.echo("lightsd running at {}".format(bulbs.lightsd.url))

    click.echo("Starting ui engine...")

    ui_task = ui.start()

    if hasattr(loop, "add_signal_handler"):
        for signum in (signal.SIGINT, signal.SIGTERM, signal.SIGQUIT):
            loop.add_signal_handler(signum, ui_task.cancel)

    try:
        loop.run_until_complete(ui_task)
        click.echo("ui stopped, disconnecting from serialoscd and lightsd...")
    except asyncio.CancelledError:
        pass
    except Exception:
        traceback.print_exc()
        click.echo("ui crashed, disconnecting from serialoscd and lightsd...")
        pdb.post_mortem()
        sys.exit(1)
    finally:
        loop.run_until_complete(asyncio.gather(
            loop.create_task(grids.stop_all()),
            loop.create_task(bulbs.stop_all()),
        ))
        loop.close()
