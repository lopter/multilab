# Copyright (c) 2017, Louis Opter <louis@opter.org>
#
# This file is part of ofxstatement-common.
#
# ofxstatement-common is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# ofxstatement-common is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import logging
import pdb
import sys

from . import (  # noqa
    locale,
)


class spawn_debugger_on_exception:

    def __init__(self, errmsg: str) -> None:
        self._errmsg = errmsg

    def __enter__(self) -> None:
        pass

    def __exit__(self, exc_type, exc_value, exc_tb) -> bool:
        if exc_value is not None:
            logging.exception(self._errmsg)
            logging.info("Press {} to exit the debugger".format(
                "^Z" if sys.platform.startswith("win32") else "^D"
            ))
            pdb.post_mortem()
            sys.exit(1)
