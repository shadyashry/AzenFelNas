"""Workspace wiring check for the dm_pipelines package."""

import dm_pipelines


def test_package_imports_with_docstring() -> None:
    """The package is importable and documents its purpose."""
    assert dm_pipelines.__doc__
