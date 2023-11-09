# Copyright (c) 2017, Louis Opter <louis@opter.org>
#
# This file is part of ofxstatement-us-schwab.
#
# ofxstatement-us-hsbc is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# ofxstatement-us-hsbc is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import enum
import os

from typing import List


class CsvIndexes(enum.Enum):

    DATE = 0
    TYPE = 1
    CHECK_NUMBER = 2
    DESCRIPTION = 3
    WITHDRAWAL = 4
    DEPOSIT = 5
    BALANCE = 6


class Record:

    date: str = None
    type: str = None
    check_number: str = None
    description: str = None
    withdrawal: str = None
    deposit: str = None
    balance: str = None

    def __init__(self, line: List[str]) -> None:
        print("line: {}".format(line))
        for index in CsvIndexes:
            setattr(self, index.name.lower(), line[index.value].strip())

    def __repr__(self) -> str:
        linesep = "{}  ".format(os.linesep)
        return "<{}({}{}) object at 0x{:x}>".format(
            self.__class__.__name__,
            linesep,
            ",{}".format(linesep).join(
                "{}={}".format(attrname, getattr(self, attrname.lower()))
                for attrname in map(lambda idx: idx.name.lower(), CsvIndexes)
            ),
            id(self),
        )
