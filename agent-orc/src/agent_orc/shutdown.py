"""SIGINT handling: warn, confirm, kill children, purge worktrees."""

from __future__ import annotations

import logging
import os
import signal
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable

from agent_orc.worktree import WorktreeSession, delete_worktree

logger = logging.getLogger("agent_orc.shutdown")


@dataclass
class ShutdownController:
    confirm_fn: Callable[[str], bool] | None = None
    active_pids: set[int] = field(default_factory=set)
    active_worktrees: list[WorktreeSession] = field(default_factory=list)
    _force_count: int = 0
    shutting_down: bool = False

    def register_pid(self, pid: int) -> None:
        self.active_pids.add(pid)

    def unregister_pid(self, pid: int) -> None:
        self.active_pids.discard(pid)

    def register_worktree(self, session: WorktreeSession) -> None:
        self.active_worktrees.append(session)

    def unregister_worktree(self, session: WorktreeSession) -> None:
        self.active_worktrees = [w for w in self.active_worktrees if w is not session]

    def install(self) -> None:
        signal.signal(signal.SIGINT, self._handle_sigint)
        if hasattr(signal, "SIGTERM"):
            signal.signal(signal.SIGTERM, self._handle_sigint)

    def _handle_sigint(self, signum: int, frame: object) -> None:
        self._force_count += 1
        if self._force_count >= 2:
            logger.warning("second interrupt: forcing shutdown")
            self.force_shutdown()
            raise SystemExit(130)

        if self.active_pids:
            msg = (
                f"agent-orc: {len(self.active_pids)} agent process(es) still running. "
                "End now and purge worktrees?"
            )
            logger.warning(msg)
            tty = sys.stdin.isatty()
            if tty:
                confirm = self.confirm_fn or _default_confirm
                if not confirm(msg):
                    logger.info("shutdown cancelled; continuing")
                    self._force_count = 0
                    return
            else:
                logger.warning("non-TTY: forcing shutdown")
        self.force_shutdown()
        raise SystemExit(130)

    def force_shutdown(self) -> None:
        self.shutting_down = True
        for pid in list(self.active_pids):
            try:
                os.killpg(pid, signal.SIGKILL)
            except (ProcessLookupError, PermissionError, OSError):
                try:
                    os.kill(pid, signal.SIGKILL)
                except (ProcessLookupError, PermissionError, OSError):
                    pass
            self.active_pids.discard(pid)
        for session in list(self.active_worktrees):
            delete_worktree(session)
            self.unregister_worktree(session)


def _default_confirm(message: str) -> bool:
    try:
        answer = input(f"{message} [y/N] ").strip().lower()
    except EOFError:
        return True
    return answer in {"y", "yes"}


def purge_worktrees_dir(worktrees_dir: Path, repo_root: Path) -> None:
    if not worktrees_dir.is_dir():
        return
    for child in list(worktrees_dir.iterdir()):
        if child.is_dir():
            delete_worktree(
                WorktreeSession(path=child, branch="", repo_root=repo_root)
            )
