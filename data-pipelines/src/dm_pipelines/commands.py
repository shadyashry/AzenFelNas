"""Running external tools: the `CommandRunner` port and its subprocess adapter (DESIGN.md §17.6).

The pipelines call `make`, `zic` and `dart`; the port lets tests replace them without spawning
processes, and the adapter is the only place that does.
"""

import subprocess
from collections.abc import Sequence
from pathlib import Path
from typing import Protocol


class CommandError(Exception):
    """An external tool could not be started or exited with a non-zero status."""


class CommandRunner(Protocol):
    """Runs one external command to completion (port)."""

    def run(self, args: Sequence[str], cwd: Path) -> None:
        """Run `args` in `cwd`; raise `CommandError` unless it exits with status 0."""
        ...


class SubprocessRunner:
    """`CommandRunner` over `subprocess.run`, with no shell and the caller's environment."""

    def run(self, args: Sequence[str], cwd: Path) -> None:
        """Run `args` in `cwd`; raise `CommandError` with the tool's stderr on failure."""
        try:
            # The arguments are fixed tool names and paths built by the pipeline; no shell runs.
            completed = subprocess.run(  # noqa: S603
                list(args),
                cwd=cwd,
                capture_output=True,
                text=True,
                check=False,
            )
        except OSError as error:
            message = f"cannot run {args[0]}: {error}"
            raise CommandError(message) from error
        if completed.returncode != 0:
            message = f"{' '.join(args)} exited {completed.returncode}: {completed.stderr.strip()}"
            raise CommandError(message)


class CapturingRunner(Protocol):
    """Runs one external command to completion and returns what it printed (port)."""

    def capture(self, args: Sequence[str], cwd: Path) -> str:
        """Run `args` in `cwd`; return stdout and stderr; raise `CommandError` unless it exits 0."""
        ...


class CapturingSubprocessRunner(SubprocessRunner):
    """`SubprocessRunner` that also returns a tool's output (ffprobe, ffmpeg's loudness meter)."""

    def capture(self, args: Sequence[str], cwd: Path) -> str:
        """Run `args` in `cwd`; return stdout followed by stderr."""
        try:
            # As `run`: fixed tool names and pipeline paths, no shell.
            completed = subprocess.run(  # noqa: S603
                list(args),
                cwd=cwd,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                check=False,
            )
        except OSError as error:
            message = f"cannot run {args[0]}: {error}"
            raise CommandError(message) from error
        if completed.returncode != 0:
            message = f"{' '.join(args)} exited {completed.returncode}: {completed.stderr.strip()}"
            raise CommandError(message)
        return completed.stdout + completed.stderr
