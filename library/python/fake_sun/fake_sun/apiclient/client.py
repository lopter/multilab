import datetime

from typing import NamedTuple, Optional

from fake_sun.common.types import Period


class Target(NamedTuple):
    names: list[str]

    @classmethod
    def all(cls):
        return cls(names=[])  # empty list means target all


class FakeSun(NamedTuple):
    name: str
    brightness: float
    period: Period
    morning_shift: datetime.timedelta
    override_period: Optional[Period]


class Client:

    def __init__(self, endpoints: list[str]) -> None:
        """Get a client to interact with one or more fake-sun planters.

        :param endpoints: List of http endpoints running the fake-sun api
                          server.
        """
        pass

    def get_state(self, target: Target) -> list[FakeSun]:
        """Get the state of the targeted planters."""
        pass

    def set_state(self, target: Target, state: FakeSun) -> list[FakeSun]:
        """Set targeted planters to the given state.

        :returns: The new state of each planter that acknowledged the request.
        """

        pass
