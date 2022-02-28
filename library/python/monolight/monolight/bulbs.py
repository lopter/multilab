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
import collections
import lightsc
import logging

from typing import DefaultDict, Dict, List, Set

from lightsc.requests import GetLightState
from lightsc.structs import LightBulb  # noqa

from . import grids

DEFAULT_REFRESH_DELAY = 0.25
KEEPALIVE_DELAY = 60

logger = logging.getLogger("library.python.monolight")

lightsd = None  # type: lightsc.LightsClient

bulbs_by_label = {}  # type: Dict[str, LightBulb]
bulbs_by_group: DefaultDict[str, Set[LightBulb]] = collections.defaultdict(set)

_refresh_task = None  # type: asyncio.Task


def iter_targets(targets: List[str]):
    for target in targets:
        if target == "*":
            for bulb in bulbs_by_label.values():
                yield bulb
        elif target.startswith("#"):
            for bulb in bulbs_by_group.get(target[1:], set()):
                yield bulb
        elif target in bulbs_by_label:
            yield bulbs_by_label[target]


async def _poll(refresh_delay_s: float) -> None:
    global bulbs_by_label, bulbs_by_group

    while True:
        try:
            state = await lightsd.apply(GetLightState(["*"]))
        except lightsc.exceptions.LightsClientTimeoutError as ex:
            logger.warning(
                "lightsd timed out while trying to retrieve "
                "the state of the bulbs: {}".format(ex)
            )
            continue

        bulbs_by_label = {}
        bulbs_by_group = collections.defaultdict(set)
        for b in state.bulbs:
            bulbs_by_label[b.label] = b
            for t in b.tags:
                bulbs_by_group[t].add(b)

        delay = refresh_delay_s if grids.running else KEEPALIVE_DELAY
        await asyncio.sleep(delay)


async def start_lightsd_connection(
    lightsd_url: str,
    refresh_delay_s: float = DEFAULT_REFRESH_DELAY,
) -> None:
    global _refresh_task, lightsd

    lightsd = await lightsc.create_async_lightsd_connection(lightsd_url)
    loop = asyncio.get_running_loop()
    _refresh_task = loop.create_task(_poll(refresh_delay_s))


async def stop_all() -> None:
    global _refresh_task, lightsd

    _refresh_task.cancel()
    await asyncio.wait([_refresh_task])
    await lightsd.close()
    lightsd = _refresh_task = None
