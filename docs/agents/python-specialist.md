# python-specialist - Python Language Expert

> Python language expert -- debugging, packaging (PyInstaller/Nuitka/cx_Freeze), testing (pytest/unittest), type checking (mypy/pyright), async/concurrency patterns, performance optimization, dependency management, and cross-platform development. Handles everything from tracebacks to production builds.

## When to Use It

- Debugging Python crashes, tracebacks, or unexpected behavior
- Packaging desktop apps with PyInstaller, Nuitka, or cx_Freeze
- Setting up pytest, unittest, or coverage workflows
- Adding type hints or configuring mypy/pyright
- Optimizing Python performance or async concurrency
- Managing dependencies with pyproject.toml, requirements.txt, or Poetry

## What It Does NOT Do

- Does not build wxPython GUI layouts (routes to wxpython-specialist)
- Does not implement platform accessibility APIs (routes to desktop-a11y-specialist)
- Does not handle web or document accessibility auditing

## What It Covers

<details>
<summary>Expand - full coverage list</summary>

- Python 3.10-3.14 feature reference
- pyproject.toml configuration (hatchling, setuptools, flit)
- PyInstaller one-file and one-folder modes, hidden imports, spec files
- Nuitka compilation and cx_Freeze builds
- pytest fixtures, markers, parametrize, conftest patterns
- mypy and pyright strict mode configuration
- async/await, asyncio, concurrent.futures patterns
- Common pitfalls: mutable defaults, late binding closures, circular imports
- Cross-platform path handling with platformdirs
- Logging setup and configuration
- Dependency management and virtual environments

</details>

## Example Prompts

- "Debug this traceback"
- "Package my app as a single .exe with PyInstaller"
- "Add type hints to this module"
- "Set up pytest with coverage for my project"
- "Optimize this slow loop"
- "Fix this circular import"

## Skills Used

| Skill | Purpose |
|-------|---------|
| [python-development](../skills/python-development.md) | Version reference, pyproject.toml patterns, PyInstaller cheat sheet, common pitfalls |

## Related Agents

- [wxpython-specialist](wxpython-specialist.md) -- bidirectional handoffs for Python-in-GUI and GUI-needing-Python
- [developer-hub](developer-hub.md) -- routes here for Python language tasks
- [a11y-tool-builder](a11y-tool-builder.md) -- bidirectional handoffs for tool code needing Python expertise
