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

import functools
import logging

from lightsc import requests

from .. import grids
from ..types import Dimensions, Position

from . import actions
from .elements import (
    Button,
    PowerButton,
    UILayer,
    groups,
)

logger = logging.getLogger("library.python.monolight.ui")


class _ToggleUI(actions.Action):

    def __init__(self, grid: grids.MonomeGrid) -> None:
        actions.Action.__init__(self)
        self._grid = grid

    async def _run(self) -> None:
        self._grid.show_ui = not self._grid.show_ui


def root(grid: grids.MonomeGrid) -> UILayer:
    foreground_layer = UILayer("root", grid.size)

    foreground_layer.insert(Button("toggle ui", Position(15, 7), actions={
        Button.ActionEnum.UP: _ToggleUI(grid),
    }))

    # some shortcuts:
    foreground_layer.insert(Button("off *", Position(0, 7), actions={
        Button.ActionEnum.UP: actions.Lightsd(
            requests=[requests.PowerOff], targets=["*"]
        )
    }))
    foreground_layer.insert(Button("on *", Position(1, 7), actions={
        Button.ActionEnum.UP: actions.Lightsd(
            requests=[requests.PowerOn], targets=["*"]
        )
    }))
    foreground_layer.insert(
        Button("4000k kitchen", Position(2, 7), actions={
            Button.ActionEnum.UP: actions.Lightsd(requests=[
                functools.partial(
                    requests.SetLightFromHSBK,
                    ["neko"], 0.0, 0.0, 1.0, 4000, 1000,
                ),
                functools.partial(requests.PowerOn, ["neko"]),
            ])
        })
    )
    foreground_layer.insert(Button("orange", Position(3, 7), actions={
        Button.ActionEnum.UP: actions.Lightsd(requests=[
            functools.partial(
                requests.SetLightFromHSBK,
                ["#tower"], 37.469443, 1.0, 0.25, 3500, 600,
            ),
            functools.partial(
                requests.SetLightFromHSBK,
                ["fugu"], 47.469443, 0.2, 0.1, 3500, 600,
            ),
            functools.partial(
                requests.SetLightFromHSBK,
                ["candle"], 47.469443, 0.2, 0.15, 3500, 600,
            ),
            functools.partial(requests.PowerOn, ["#br"])
        ]),
    }))
    foreground_layer.insert(Button("blue", Position(4, 7), actions={
        Button.ActionEnum.UP: actions.Lightsd(requests=[
            functools.partial(
                requests.SetLightFromHSBK,
                ["#tower"], 163.237354, 0.923552, 0.25, 3500, 600,
            ),
            functools.partial(
                requests.SetLightFromHSBK,
                ["fugu"], 47.469443, 0.2, 0.1, 3500, 600,
            ),
            functools.partial(
                requests.SetLightFromHSBK,
                ["candle"], 47.469443, 0.2, 0.15, 3500, 600,
            ),
            functools.partial(requests.PowerOn, ["#br"])
        ]),
    }))
    foreground_layer.insert(PowerButton(
        "#br", Position(5, 7), targets=["#br"]
    ))
    foreground_layer.insert(PowerButton(
        "white", Position(6, 7), targets=["white"]
    ))

    # some control blocks:
    BulbControlPad = functools.partial(
        groups.BulbControlPad, sliders_size=Dimensions(width=1, height=6),
    )
    foreground_layer.insert(BulbControlPad(
        "kitchen control", Position(0, 0), targets=["neko"],
    ))
    foreground_layer.insert(BulbControlPad(
        "#tower control", Position(4, 0), targets=["#tower"],
    ))
    foreground_layer.insert(BulbControlPad(
        "fugu control", Position(8, 0), targets=["fugu"],
    ))
#   foreground_layer.insert(BulbControlPad(
#       "candle control", Position(12, 0), targets=["candle"],
#   ))

    return foreground_layer
