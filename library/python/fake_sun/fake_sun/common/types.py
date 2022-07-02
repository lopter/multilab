import enum

from pathlib import Path as P
from typing import NamedTuple


class Period(enum.Enum):
    NIGHT = "night"
    DAY = "day"
    TRANSITION = "transition"


class ClickContext(NamedTuple):
    state_file_path: P
