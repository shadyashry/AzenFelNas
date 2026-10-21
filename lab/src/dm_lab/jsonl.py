"""JSON Lines encoding of wire models: one compact document per LF-terminated UTF-8 line.

Optional members are absent, never null (DESIGN.md §15 D21); keys follow the schema order, so a
model always encodes to the same bytes.
"""

from collections.abc import Iterable
from pathlib import Path

from pydantic import BaseModel


def encode_line(model: BaseModel) -> str:
    """One JSONL line (without its terminator) for `model`."""
    return model.model_dump_json(exclude_none=True)


def encode_document(model: BaseModel) -> str:
    """Encode `model` as an indented JSON document with a trailing newline."""
    return model.model_dump_json(exclude_none=True, indent=2) + "\n"


def write_jsonl(path: Path, models: Iterable[BaseModel]) -> int:
    """Write `models` to `path` as JSONL and return how many lines were written."""
    count = 0
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as stream:
        for model in models:
            stream.write(encode_line(model))
            stream.write("\n")
            count += 1
    return count


def read_jsonl[M: BaseModel](path: Path, model_type: type[M]) -> list[M]:
    """Parse every non-empty line of `path` as `model_type`.

    Raises:
        pydantic.ValidationError: a line does not match the model's schema.

    """
    with path.open(encoding="utf-8") as stream:
        return [model_type.model_validate_json(line) for line in stream if line.strip()]


def write_document(path: Path, model: BaseModel) -> None:
    """Write `model` to `path` as one indented JSON document."""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(encode_document(model), encoding="utf-8", newline="\n")
