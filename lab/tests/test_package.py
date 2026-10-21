"""Workspace wiring check for the dm_lab package."""

import dm_lab


def test_package_imports_with_docstring() -> None:
    """The package is importable and documents its purpose."""
    assert dm_lab.__doc__
