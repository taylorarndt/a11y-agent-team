---
name: python-development
description: "Python and wxPython development reference patterns, common pitfalls, framework-specific guides, desktop accessibility APIs, and cross-platform considerations. Use when building, debugging, packaging, or reviewing Python desktop applications."
---

# Python Development Skill

Reference data for the Developer Hub, Python Specialist, and wxPython Specialist agents.

## Python Version Quick Reference

| Version | Key Features | EOL |
|---|---|---|
| 3.10 | `match/case`, `X \| Y` unions, `ParamSpec` | Oct 2026 |
| 3.11 | Exception groups, `Self` type, `tomllib`, faster CPython | Oct 2027 |
| 3.12 | Type parameter syntax `def f[T]()`, `@override`, f-string nesting | Oct 2028 |
| 3.13 | Experimental free-threaded mode, improved error messages | Oct 2029 |
| 3.14 | `async pdb.set_trace_async()`, template strings (PEP 750) | Oct 2030 |

## pyproject.toml Skeleton

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "my-app"
version = "1.0.0"
requires-python = ">=3.10"
dependencies = []

[project.optional-dependencies]
dev = ["pytest>=8.0", "ruff>=0.6", "mypy>=1.11"]

[project.scripts]
myapp = "my_app.__main__:main"

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-ra --strict-markers"

[tool.ruff]
target-version = "py310"
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "UP", "B", "SIM", "TCH"]

[tool.mypy]
python_version = "3.10"
strict = true
```

## PyInstaller Quick Reference

### One-File Mode
```python
exe = EXE(pyz, a.scripts, a.binaries, a.zipfiles, a.datas,
          name='MyApp', console=False, icon='icon.ico')
```

### One-Folder Mode
```python
exe = EXE(pyz, a.scripts, exclude_binaries=True,
          name='MyApp', console=False, icon='icon.ico')
coll = COLLECT(exe, a.binaries, a.zipfiles, a.datas, name='MyApp')
```

### Common Hidden Imports
- `pkg_resources.extern`
- `accessible_output2` (for a11y desktop apps)
- `keyring.backends` (for credential storage)
- `platformdirs`
- `httpx._transports` / `httpcore._backends`
- `encodings` (always needed)

## wxPython Quick Reference

### Sizer Cheat Sheet

| Sizer | When to Use |
|---|---|
| `wx.BoxSizer(wx.VERTICAL)` | Stack items top-to-bottom |
| `wx.BoxSizer(wx.HORIZONTAL)` | Lay items left-to-right |
| `wx.GridBagSizer(vgap, hgap)` | Form layouts with labels + controls |
| `wx.FlexGridSizer(rows, cols, vgap, hgap)` | Even grid layouts |
| `wx.WrapSizer` | Flow layout that wraps |
| `wx.StaticBoxSizer(wx.VERTICAL, parent, "Label")` | Grouped controls with border |

### Thread-Safe GUI Updates

```python
# From worker thread:
wx.CallAfter(self.update_status, "Done")
wx.PostEvent(self, CustomEvent(data=result))

# NEVER do this from a worker thread:
self.status_bar.SetStatusText("Done")  # CRASH or CORRUPTION
```

### Standard IDs

| ID | Purpose |
|---|---|
| `wx.ID_OK` | OK button |
| `wx.ID_CANCEL` | Cancel button |
| `wx.ID_SAVE` | Save action |
| `wx.ID_OPEN` | Open action |
| `wx.ID_EXIT` | Exit / Quit |
| `wx.ID_HELP` | Help action |
| `wx.ID_NEW` | New document |
| `wx.ID_UNDO` / `wx.ID_REDO` | Undo / Redo |

### Event Types

| Event | Trigger |
|---|---|
| `wx.EVT_BUTTON` | Button click |
| `wx.EVT_MENU` | Menu item selected |
| `wx.EVT_CLOSE` | Window close requested |
| `wx.EVT_SIZE` | Window resized |
| `wx.EVT_TIMER` | Timer fired |
| `wx.EVT_TEXT` | Text control content changed |
| `wx.EVT_LIST_ITEM_SELECTED` | List item selected |
| `wx.EVT_TREE_SEL_CHANGED` | Tree selection changed |
| `wx.EVT_UPDATE_UI` | UI state update check |

## Common Pitfalls

### Python
- **Mutable default arguments:** `def f(items=[])` shares the list across calls. Use `None` and create inside.
- **Late binding closures:** `lambda: x` in a loop captures the variable, not the value. Use `lambda x=x: x`.
- **Circular imports:** Move imports inside functions, use `TYPE_CHECKING` block, or restructure modules.
- **`field()` outside dataclass:** `field()` is only valid inside `@dataclass` classes. Use plain type annotations elsewhere.
- **`is` vs `==`:** `is` checks identity, `==` checks equality. Use `is` only for `None`, `True`, `False`.
- **String concatenation in loops:** Use `"".join()` or `io.StringIO` instead.

### wxPython
- **GUI from worker thread:** Always use `wx.CallAfter()` or `wx.PostEvent()`.
- **Missing `event.Skip()`:** Other handlers won't fire. Call `event.Skip()` unless you intentionally consume the event.
- **Timer not stopped:** Stop timers in `EVT_CLOSE` handler to prevent callbacks after destruction.
- **AUI not uninitialized:** Call `_mgr.UnInit()` in close handler.
- **Dialog not destroyed:** Use context managers (`with MyDialog(...) as dlg:`) for automatic cleanup.
- **Wrong parent for sizer items:** All controls in a sizer must have the same parent panel.
- **Absolute positioning:** Never use `SetPosition()` or `SetSize()` for layout. Always use sizers.

## Cross-Platform Paths

```python
from platformdirs import user_config_dir, user_data_dir, user_cache_dir

config = user_config_dir("MyApp", "MyCompany")  # %APPDATA% / ~/Library/... / ~/.config/
data = user_data_dir("MyApp", "MyCompany")
cache = user_cache_dir("MyApp", "MyCompany")
```

## Testing Quick Reference

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_queue.py

# Run specific test
pytest tests/test_queue.py::test_submit_job -v

# With coverage
pytest --cov=mypackage --cov-report=term-missing

# Stop on first failure
pytest -x

# Show locals on failure
pytest -l
```

## Logging Setup Template

```python
import logging

def setup_logging(level: int = logging.INFO) -> None:
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(name)s %(levelname)s %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    # Quiet noisy libraries
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpcore").setLevel(logging.WARNING)
```

## Desktop Accessibility Quick Reference

### Platform API Summary

| Platform | API | Python Binding | Use For |
|---|---|---|---|
| Windows | UI Automation (UIA) | `comtypes`, `pywinauto` | Modern apps, NVDA/Narrator |
| Windows | MSAA / IAccessible2 | `comtypes`, `pywinauto` | Legacy apps, JAWS |
| macOS | NSAccessibility | `pyobjc` | VoiceOver |
| Linux | ATK / AT-SPI | `pyatspi` | Orca |

### wxPython Accessibility Essentials

```python
# Name every control that lacks a visible label
ctrl.SetName("Scan progress")

# Tab order follows sizer insertion order; override with:
ctrl2.MoveAfterInTabOrder(ctrl1)

# Keyboard shortcuts via accelerator table
accel = wx.AcceleratorTable([
    (wx.ACCEL_CTRL, ord('S'), wx.ID_SAVE),
    (wx.ACCEL_CTRL, ord('Q'), wx.ID_EXIT),
])
frame.SetAcceleratorTable(accel)

# Platform-correct button order in dialogs
sizer.Add(dialog.CreateStdDialogButtonSizer(wx.OK | wx.CANCEL))
```

### Screen Reader Interaction Model

Screen readers expose controls as: **Name + Role + Value + State**

| Property | wxPython Source | Example |
|---|---|---|
| Name | `SetName()` or visible label | "Scan progress" |
| Role | Widget type (automatic) | button, text field, list |
| Value | Widget content | "75%", "Hello world" |
| State | Widget flags | focused, disabled, checked |

### Desktop A11y Checklist

1. Every control has a meaningful name (`SetName()` or adjacent `wx.StaticText`)
2. Keyboard-only operation -- every action reachable via Tab/Enter/Space/arrows
3. Focus visible -- never suppress focus indicators
4. Tab order is logical (generally top-to-bottom, left-to-right)
5. Color is not the sole information carrier
6. High contrast mode supported (use system colors, not hardcoded)
7. Dialogs use `CreateStdDialogButtonSizer()` for platform-correct button order
8. AUI panes are keyboard-navigable

### Agent Routing

For deeper expertise, the skill routes to these specialists:
- **`desktop-a11y-specialist`** -- Platform API implementation, wx.Accessible, custom widget patterns
- **`desktop-a11y-testing-coach`** -- NVDA/JAWS/Narrator testing, Accessibility Insights, automated UIA tests
- **`a11y-tool-builder`** -- Rule engine architecture, document parsers, severity scoring, report generators
