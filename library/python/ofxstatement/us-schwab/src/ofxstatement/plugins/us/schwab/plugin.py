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

import csv
import datetime
import logging

from decimal import Decimal, Decimal as D
from ofxstatement.parser import CsvStatementParser
from ofxstatement.plugin import Plugin as PluginBase
from ofxstatement.statement import StatementLine, generate_transaction_id
from typing import Dict, Iterable, List
from typing.io import TextIO
from x.ofxstatement.plugins import common

from .record import CsvIndexes, Record

logger = logging.getLogger("ofxstatement.plugins.us.schwab")


class Parser(CsvStatementParser):

    date_format = "%m/%d/%Y"

    mappings: Dict[str, int] = {
        "date": CsvIndexes.DATE.value,
        "check_no": CsvIndexes.CHECK_NUMBER.value,
        "memo": CsvIndexes.DESCRIPTION.value
    }

    _TYPE_TO_TRNTYPE: Dict[str, str] = {
        "ATM": "ATM",
        "ATMREBATE": "DEP",
        "CHECK": "CHECK",
        "DEPOSIT": "DEP",
        "INTADJUST": "INT",
        "TRANSFER": "XFER",
        "VISA": "POS",
    }

    def __init__(self, fin: TextIO, locale: str) -> None:
        super(Parser, self).__init__(fin)

        self._locale = locale

        self.statement.currency = "USD"
        self.statement.start_date = datetime.datetime.now()  # timezones pls?
        self.statement.end_date = self.statement.start_date
        self.statement.start_balance = None
        self.statement.end_balance = None

    def split_records(self) -> Iterable[str]:
        return csv.reader(self.fin, delimiter=",", quotechar='"', strict=True)

    @classmethod
    def _get_trntype(cls, record: Record) -> str:
        if not record.type:
            if record.withdrawal:
                return "DEBIT"
            if record.deposit:
                return "CREDIT"
        if record.type in cls._TYPE_TO_TRNTYPE:
            return cls._TYPE_TO_TRNTYPE[record.type]
        if record.type == "ACH":
            if record.withdrawal:
                return "DIRECTDEBIT"
            if record.deposit:
                return "DIRECTDEP"

        logger.info(
            "The transaction type for the following record couldn't be "
            "determined and will default to OTHER: {}".format(record)
        )
        return "OTHER"

    def parse_record(self, row: List[str]) -> StatementLine:
        if len(row) != len(CsvIndexes):
            msg = "Skipping row (invalid number of fields): {}".format(row)
            logger.info(msg)
            return None

        record = Record(row)

        try:
            # if we don't have a valid date on the row then we can skip it:
            datetime.datetime.strptime(record.date, self.date_format)
        except ValueError as ex:
            logger.info("Skipping row ({}): {}".format(str(ex), row))
            return None

        if record.withdrawal:
            amount = record.withdrawal
            sign = D(-1)
        else:
            amount = record.deposit
            sign = D(1)
        try:
            amount = sign * self.parse_decimal(amount)
        except ValueError as ex:
            logger.info("Skipping row ({}): {}".format(str(ex), row))
            return None

        try:
            balance = self.parse_decimal(record.balance)
        except ValueError:
            balance = D(0)

        with common.spawn_debugger_on_exception("Parsing failed:"):
            sl = super(Parser, self).parse_record(row)
            sl.trntype = self._get_trntype(record)

        sl.amount = amount
        sl.id = generate_transaction_id(sl)

        if min(self.statement.start_date, sl.date) == sl.date:
            self.statement.start_date = sl.date
            if balance is not None:
                self.statement.start_balance = balance
        if max(self.statement.end_date, sl.date) == sl.date:
            self.statement.end_date = sl.date
            if balance is not None:
                self.statement.end_balance = balance

        return sl

    def parse_decimal(self, value: str) -> Decimal:
        return common.locale.parse_amount(value, self._locale)


class Plugin(PluginBase):

    # Not simply using LANG and ENCODING because the encoding part of a
    # locale doesn't necessarily match the encoding name from Python's point
    # of view; e.g: on Arch Linux (2017-09) you can have en_US.ansix341968
    # which corresponds to the ascii encoding.
    LOCALE = "en_US.UTF-8"
    ENCODING = "UTF-8"

    def get_parser(self, filename: str) -> Parser:
        # XXX: how does this gets closed?
        fin = open(filename, "r", encoding=self.ENCODING)

        p = Parser(fin, self.LOCALE)
        p.statement.bank_id = self.settings.get("routing_number")
        p.statement.account_id = self.settings.get("account_number")
        p.statement.account_type = self.settings.get("account_type", "CHECKING")

        return p
