import fastapi

from typing import cast, Union

from fake_sun.common.types import ClickContext
from fake_sun.common import models

app = fastapi.FastAPI(title="fake-sun-apiserver")


@app.get("/state", response_model=models.State)
async def get_state() -> Union[models.State, fastapi.responses.JSONResponse]:
    click_ctx = cast(ClickContext, app.state.click_context)
    try:
        return models.State.load(click_ctx.state_file_path)
    except FileNotFoundError:
        msg = (
            "state not found, make sure pwmcontroller is running "
            "or has been configured via the state file."
        )
        content = {"error": msg}
    except Exception as ex:
        content = {"error": f"could not load state: {ex}"}
    return fastapi.responses.JSONResponse(content, status_code=500)


@app.put("/state", response_model=models.State)
async def put_state(state: models.State) -> models.State:
    click_ctx = cast(ClickContext, app.state.click_context)
    state.store(click_ctx.state_file_path)
    return state


@app.get("/health")
async def get_health():
    return {"health": "ok"}
