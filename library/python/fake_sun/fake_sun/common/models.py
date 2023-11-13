from __future__ import annotations

import datetime
import json
import pydantic

from pathlib import Path as P

from fake_sun.common.types import Period


class State(pydantic.BaseModel):
    name: str
    brightness: float
    period: Period
    morning_shift: datetime.timedelta

    def store(self, path: P) -> None:
        with path.open("w") as fp:
            fp.write(self.json())

    @classmethod
    def load(cls, path: P) -> State:
        with path.open("r") as fp:
            state = json.load(fp)
        morning_shift = state.pop("morning_shift", 0)
        state["morning_shift"] = datetime.timedelta(seconds=morning_shift)
        return State(**state)
