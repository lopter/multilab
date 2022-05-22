# Copyright (c) 2016, Louis Opter <louis@opter.org>
# # This file is part of lightsd.
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

from __future__ import annotations

import abc
import asyncio
import collections.abc
import enum
import logging
import monome

from typing import TYPE_CHECKING, Iterator, Tuple, NamedTuple, Optional
from typing import List, Set  # noqa

from .types import Dimensions, Position
if TYPE_CHECKING:
    from .ui.elements import UILayer  # noqa


logger = logging.getLogger("library.python.monolight")

running = set()  # type: Set[MonomeGrid]
running_event = None  # type: asyncio.Event
_not_running_event = None  # type: asyncio.Event


class KeyState(enum.IntEnum):

    DOWN = 1
    UP = 0


KeyPress = NamedTuple("KeyPress", [
    ("grid", "MonomeGrid"),
    ("position", Position),
    ("state", KeyState),
])


class LedLevel(enum.IntEnum):

    OFF = 0
    VERY_LOW_1 = 1
    VERY_LOW_2 = 2
    VERY_LOW_3 = 3
    LOW = LOW_1 = 4
    LOW_2 = 5
    LOW_3 = 6
    LOW_4 = 7
    MEDIUM = MEDIUM_1 = 8
    MEDIUM_2 = 9
    MEDIUM_3 = 10
    MEDIUM_4 = 11
    HIGH = HIGH_1 = 12
    HIGH_2 = 13
    HIGH_3 = 14
    HIGH_4 = ON = 15


class LedCanvasBase(collections.abc.Iterable):

    @abc.abstractmethod
    def get(self, offset: Position) -> LedLevel:
        pass

    @abc.abstractmethod
    def set(self, offset: Position, level: LedLevel) -> None:
        pass

    @abc.abstractmethod
    def shift(self, offset: Position) -> LedCanvasBase:
        pass


class LedCanvas(LedCanvasBase):

    class _Proxy(LedCanvasBase):
        def __init__(self, canvas: LedCanvas, shift: Position) -> None:
            self._canvas = canvas
            self._shift = shift

        def get(self, offset: Position) -> LedLevel:
            return self._canvas.get(offset + self._shift)

        def set(self, offset: Position, level: LedLevel) -> None:
            self._canvas.set(offset + self._shift, level)

        def shift(self, offset: Position) -> LedCanvas._Proxy:
            return self.__class__(self._canvas, offset + self._shift)

        def __iter__(self) -> Iterator[Tuple[int, int, LedLevel]]:
            for off_x in range(self._shift.x, self._canvas.size.width):
                for off_y in range(self._shift.y, self._canvas.size.height):
                    yield off_x, off_y, self.get(Position(x=off_x, y=off_y))

    def __init__(
        self, size: Dimensions, level: LedLevel = LedLevel.OFF
    ) -> None:
        self.size = size
        self._levels = [level] * size.area

    def _index(self, offset: Position) -> int:
        return self.size.width * offset.y + offset.x

    def get(self, offset: Position) -> LedLevel:
        return self._levels[self._index(offset)]

    def set(self, offset: Position, level: LedLevel) -> None:
        self._levels[self._index(offset)] = level

    def shift(self, offset: Position) -> _Proxy:
        return self._Proxy(self, offset)

    def __iter__(self) -> Iterator[Tuple[int, int, LedLevel]]:
        for off_x in range(self.size.width):
            for off_y in range(self.size.height):
                yield off_x, off_y, self.get(Position(x=off_x, y=off_y))


class AIOSCMonolightApp(monome.GridApp):

    def __init__(self) -> None:
        monome.GridApp.__init__(self)

    def on_grid_ready(self) -> None:
        logger.info("Grid {} ready".format(self.grid.id))
        self._grid = MonomeGrid(self.grid)
        running.add(self._grid)
        if len(running) == 1:
            running_event.set()
            _not_running_event.clear()

    def on_grid_disconnect(self) -> None:
        if len(running) == 1:
            running_event.clear()
            _not_running_event.set()
        running.remove(self._grid)
        self._grid.shutdown()
        monome.GridApp.on_grid_disconnect(self)
        logger.info("Grid {} disconnected".format(self.grid.id))

    def on_grid_key(self, x: int, y: int, s: int) -> None:
        if self._grid is not None:
            keypress = KeyPress(self._grid, Position(x, y), KeyState(s))
            self._grid.submit_input(keypress)


class MonomeGrid:

    def __init__(self, monome_grid: monome.Grid) -> None:
        self.size = Dimensions(monome_grid.height, monome_grid.width)
        self.monome = monome_grid
        self.layers: List[UILayer] = []
        self._show_ui = asyncio.Event()
        self._show_ui.set()
        self._input_queue: asyncio.Queue[KeyPress] = asyncio.Queue()
        self._queue_get: Optional[asyncio.Task] = None
        self._led_buffer = monome.GridBuffer(self.size.width, self.size.height)

    def shutdown(self):
        self._queue_get.cancel()
        self._queue_get = None
        self.show_ui = False
        for layer in self.layers:
            layer.shutdown()
        self.monome.led_level_all(LedLevel.OFF.value)

    def submit_input(self, keypress: KeyPress) -> None:
        self._input_queue.put_nowait(keypress)

    async def get_input(self) -> KeyPress:
        if self._queue_get is None:
            raise asyncio.CancelledError
        loop = asyncio.get_running_loop()
        self._queue_get = loop.create_task(self._input_queue.get())
        keypress = await asyncio.wait_for(self._queue_get, timeout=None)
        self._input_queue.task_done()
        return keypress

    def _hide_ui(self) -> None:
        self._show_ui.clear()
        self.monome.led_level_all(LedLevel.OFF.value)

    def _display_ui(self) -> None:
        self._show_ui.set()
        self._led_buffer.render(self.monome)

    @property
    def show_ui(self) -> bool:
        return self._show_ui.is_set()

    @show_ui.setter
    def show_ui(self, value: bool) -> None:
        self._hide_ui() if value is False else self._display_ui()

    async def wait_ui(self) -> None:
        await self._show_ui.wait()

    @property
    def foreground_layer(self):
        return self.layers[-1] if self.layers else None

    def display(self, canvas: LedCanvas) -> None:
        for off_x, off_y, level in canvas:
            self._led_buffer.led_level_set(off_x, off_y, level.value)
        self._led_buffer.render(self.monome)


_serialosc = None


async def start_serialosc_connection() -> None:
    global _serialosc, running_event, _not_running_event

    running_event = asyncio.Event()
    _not_running_event = asyncio.Event()
    _not_running_event.set()

    def serialosc_device_added(id: str, type: str, port: int) -> None:
        logger.info(f"connecting to {id} ({type})")
        app = AIOSCMonolightApp()
        loop = asyncio.get_running_loop()
        loop.create_task(app.grid.connect("serialosc", port))

    _serialosc = monome.SerialOsc()
    _serialosc.device_added_event.add_handler(serialosc_device_added)
    await _serialosc.connect("serialosc")


async def stop_all() -> None:
    global running_event, _not_running_event

    if _serialosc is not None:
        _serialosc.transport.close()
    # copy the set since we're gonna modify it as we iter through it:
    for grid in list(running):
        grid.monome.disconnect()
    await _not_running_event.wait()
    running_event = _not_running_event = None
