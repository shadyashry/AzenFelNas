"""Base class of the models generated from `schemas/` (ADR-023, DESIGN.md §17.6)."""

from pydantic import BaseModel, ConfigDict


class WireModel(BaseModel):
    """Immutable wire record: camelCase on the wire, snake_case in Python, unknown keys rejected.

    Generated subclasses add `extra="forbid"` themselves; the base makes every record frozen
    and lets Python code construct it by field name.
    """

    model_config = ConfigDict(
        frozen=True,
        extra="forbid",
        validate_by_name=True,
        validate_by_alias=True,
        serialize_by_alias=True,
    )
