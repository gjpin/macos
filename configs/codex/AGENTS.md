# Codex container environment

When `uname -s` reports `Linux`, Codex is running as the non-root `codex` user in a restricted Fedora 44 arm64 Podman container. Commands execute in the container, not directly on the macOS host. If `uname -s` reports `Darwin`, these container-specific restrictions do not describe the current execution surface.

Only the directory from which Codex was launched is mounted as the workspace. The rest of the host home directory, host package manager, macOS services, devices, root filesystem, and Podman control socket are inaccessible. The container root filesystem is read-only and there is no `sudo` or host-level authority.

When progress requires an action on the macOS host that Codex cannot perform from the container, tell the user the exact command or commands they need to run on the host. Include the required working directory and any relevant arguments or environment setup; do not merely state that the container cannot perform the action.

Common development tools are already included. Python Playwright and pytest-playwright use the system Chromium browser at `/usr/bin/chromium`. Direct Playwright calls must use `launch(executable_path="/usr/bin/chromium")`. Pytest suites must merge the same executable path into their session-scoped `browser_type_launch_args` fixture while preserving existing arguments:

```python
import pytest


@pytest.fixture(scope="session")
def browser_type_launch_args(browser_type_launch_args):
    return {
        **browser_type_launch_args,
        "executable_path": "/usr/bin/chromium",
    }
```

Playwright is headless by default. Do not run `playwright install`; Playwright-managed browser downloads are unsupported.

Podman and Docker are unavailable inside the container. If a task requires a container engine, ask the user to run the required command on the macOS host.

Do not install missing runtime tools with `dnf`, `sudo`, `npm`, `uv`, `pip`, `cargo`, `go install`, downloaded binaries, or other language package managers. Existing project dependency workflows may be used only when the task itself requires those project dependencies; do not use them to modify the container toolchain.

If a required tool is missing, continue independent useful work and report:

- the exact Fedora package, npm language-server package, or Python tool that should be added;
- why it is needed; and
- the exact blocked command or validation.

Installing a tool on macOS does not make it available in this container. Permanent tools belong in the Codex `Containerfile`, followed by an image rebuild.
