import inotify_simple
import logging
import os
import queue
import select
import threading

from pathlib import Path as P

from fake_sun.common import models

logger = logging.getLogger("library.python.fake_sun.pwmcontroller")


class Watcher(threading.Thread):

    def __init__(self, path: P) -> None:
        threading.Thread.__init__(self)
        self.path = path
        self.channel: queue.Queue[models.State] = queue.Queue(maxsize=1)
        self._inotify = inotify_simple.INotify()
        self._intr_rfd, self._intr_wfd = os.pipe()
        self._running = True

    def run(self) -> None:
        flags = inotify_simple.flags.CLOSE_WRITE
        self._inotify.add_watch(str(self.path), flags)
        inotify_fd = self._inotify.fileno()
        while True:
            rlist, _, _ = select.select([inotify_fd, self._intr_rfd], [], [])
            if self._intr_rfd in rlist:
                os.close(self._intr_rfd)
                self._inotify.close()
                return
            if inotify_fd in rlist:
                for event in self._inotify.read(timeout=0):
                    try:
                        state = models.State.load(self.path)
                    except Exception:
                        msg = f"Could not load state file from {self.path}"
                        logger.exception(msg)
                    else:
                        self.channel.put(state)
                        break

    def stop(self) -> None:
        assert self._running
        self._running = False
        os.write(self._intr_wfd, b"\0")
        os.close(self._intr_wfd)
