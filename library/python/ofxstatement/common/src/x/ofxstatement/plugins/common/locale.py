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

import contextlib
import locale

from decimal import Decimal, Decimal as D
from typing import (
    Generator,
    Tuple,
)

from .exceptions import LocaleError


def validate(value: str) -> None:
    """Raise :class:`LocaleError` if the given locale isn't known or valid.

    :returns: value itself.
    """

    if value is None:
        ex = "Please configure a locale, learn how in the README file."
        raise LocaleError(ex)
    if not isinstance(value, str) or value.count(".") != 1:
        ex = "Malformed locale: {} (expected something like lang.encoding)."
        raise LocaleError(ex.format(value))

    return value


@contextlib.contextmanager
def _override(categories: Tuple[int], loc: str) -> Generator[None, None, None]:
    saves = [locale.setlocale(c, loc) for c in categories]
    yield
    for i, c in enumerate(categories):
        locale.setlocale(c, saves[i])


def parse_amount(value: str, loc: str) -> Decimal:
    """Parse the given amount of money according to the given locale.

    .. note:: This function isn't thread-safe.
    """

    with _override((locale.LC_NUMERIC, locale.LC_MONETARY), loc):
        lconv = locale.localeconv()
        value = value.replace(lconv["currency_symbol"], "")
        return D(locale.delocalize(value))
