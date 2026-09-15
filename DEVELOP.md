# Development Guide — dev-tools

## 1. Project Purpose

`dev-tools` is a centralized repository for managing and distributing developer tools.

The repository solves this problem:

> Developers have many small tools implemented as shell scripts, VS Code extensions, and web applications. Installing and sharing these tools manually is inconvenient because users need to copy scripts, install extensions, and find/open HTML files themselves.

This project provides a **single installation and management experience**.

The user should be able to clone the repository and run:

```bash
make install
```

Then select the tools they want to install.

The repository automatically discovers tools from:

```text
shell/
binary/
extension/
web/
```

A developer should be able to add a new tool without modifying the core installer.

---

# 2. Core Principles

AI agents working on this repository MUST follow these principles.

### 2.1 Tool independence

Every tool should be self-contained.

Example:

```text
shell/my-tool/
├── tool.yaml
├── install.sh
├── uninstall.sh
└── my-tool.sh
```

The core installer should not contain tool-specific installation logic.

Bad:

```bash
if [[ "$tool" == "sort-files" ]]; then
    ...
elif [[ "$tool" == "unique-lines" ]]; then
    ...
fi
```

Good:

```bash
discover_tools
install_tool "$tool_directory"
```

The tool itself owns its installation process.

---

### 2.2 Automatic discovery

Adding a new tool should require creating a directory only.

For example:

```text
shell/my-new-tool/
```

After adding the required files, the tool should automatically appear in:

```bash
make list
```

and in the installation UI.

Do NOT require developers to manually register tools in a central list.

---

### 2.3 Consistent tool contract

Every tool should provide metadata:

```text
tool.yaml
```

At minimum:

```yaml
name:
type:
description:
version:
```

Optional fields depend on the tool type.

Example:

```yaml
name: sort-files
type: shell
description: Sort files by extension
version: 1.0.0
command: sort-files
```

---

# 3. Repository Structure

The expected structure is:

```text
dev-tools/
│
├── Makefile
├── README.md
├── DEVELOP.md
│
├── install.sh
├── uninstall.sh
├── tools
│
├── lib/
│   ├── common.sh
│   └── ui.sh
│
├── shell/
│   └── <tool-name>/
│       ├── tool.yaml
│       ├── install.sh
│       ├── uninstall.sh
│       ├── run.sh              # optional
│       ├── README.md           # optional
│       └── ...
│
├── binary/
│   └── <tool-name>/
│       ├── tool.yaml
│       ├── install.sh
│       ├── uninstall.sh
│       ├── README.md           # optional
│       └── ...                 # source for a compiled language, e.g. Go
│
├── extension/
│   └── <tool-name>/
│       ├── tool.yaml
│       ├── install.sh
│       ├── uninstall.sh
│       ├── README.md
│       └── ...
│
└── web/
    └── <tool-name>/
        ├── tool.yaml
        ├── install.sh
        ├── uninstall.sh
        ├── run.sh
        ├── README.md
        └── ...
```

---

# 4. Directory Responsibilities

## `shell/`

Contains command-line tools implemented primarily with:

- Bash
- Shell scripts
- CLI utilities

Example:

```text
shell/
├── sort-files/
├── unique-lines/
├── kubectl-helper/
└── git-helper/
```

A shell tool normally installs an executable into:

```text
/usr/local/bin/
```

Example:

```bash
sort-files
```

---

## `binary/`

Contains tools written in a compiled language (e.g. Go) that must be built
before they can be installed.

Example:

```text
binary/
└── PDFToPNG/
```

Unlike `shell/`, a `binary/` tool's `install.sh` runs a build step (e.g.
`go build`) and installs the resulting compiled binary into:

```text
/usr/local/bin/
```

`tool.yaml` for a `binary/` tool uses `type: go` (or another compiled
language, as needed).

---

## `extension/`

Contains VS Code extensions.

Example:

```text
extension/
├── sort-extension/
├── unique-extension/
└── json-helper/
```

Installation should normally use:

```bash
code --install-extension <extension-id>
```

The tool should verify that the `code` command is available.

---

## `web/`

Contains browser-based tools.

Example:

```text
web/
├── json-formatter/
├── sql-formatter/
└── yaml-validator/
```

A web tool should provide an easy way to launch the UI.

Preferred:

```bash
./tools run json-formatter
```

The user should NOT need to manually find:

```text
web/json-formatter/index.html
```

---

# 5. Tool Metadata

Every tool must have:

```text
tool.yaml
```

Example:

```yaml
name: json-formatter
type: web
description: Format and validate JSON
version: 1.0.0
```

Allowed `type` values:

```text
shell
extension
web
go
```

A `go` tool lives under `binary/<tool-name>/` (see §4.1) — its `install.sh`
compiles a Go source tree (`go build`) before installing the resulting
binary into `/usr/local/bin`, rather than installing a plain script
directly.

Additional metadata can be added when necessary.

For example:

```yaml
name: kubectl-helper
type: shell
description: Kubernetes helper commands
version: 1.2.0
command: kubectl-helper
platforms:
  - darwin
  - linux
```

---

# 6. Tool Installation Contract

## `install.sh`

Every installable tool should have:

```text
install.sh
```

The script is responsible for installing the tool.

Example:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install -m 755 \
    "$SCRIPT_DIR/my-tool.sh" \
    /usr/local/bin/my-tool
```

Installation scripts MUST:

- use `set -euo pipefail`
- be executable
- fail with a useful error message
- avoid unnecessary global changes
- be safe to run more than once when possible

---

# 7. Uninstallation Contract

Tools should provide:

```text
uninstall.sh
```

Example:

```bash
#!/usr/bin/env bash
set -euo pipefail

sudo rm -f /usr/local/bin/my-tool
```

Uninstall should be safe if the tool is already absent.

---

# 8. Running Tools

Tools that have a meaningful runtime action should provide:

```text
run.sh
```

Example:

```text
web/json-formatter/
├── tool.yaml
├── install.sh
├── uninstall.sh
├── run.sh
└── index.html
```

Then:

```bash
./tools run json-formatter
```

should launch the tool.

The core CLI should locate the tool automatically.

---

# 9. Makefile

`make` is the primary developer interface.

The Makefile should remain simple and predictable.

Recommended commands:

```bash
make list
make install
make uninstall
make run TOOL=json-formatter
make test
make lint
make check
```

Example:

```makefile
list:
	./tools list

install:
	./install.sh

uninstall:
	./uninstall.sh

run:
	./tools run $(TOOL)

test:
	./scripts/test.sh

lint:
	./scripts/lint.sh

check:
	make lint
	make test
```

If a new command is needed, prefer adding it to `Makefile` rather than requiring users to remember complicated shell commands.

---

# 10. AI Development Workflow

AI agents working on this repository should follow this workflow.

## Step 1 — Understand the structure

Before changing code, inspect:

```text
Makefile
tools
install.sh
uninstall.sh
lib/
shell/
binary/
extension/
web/
```

Determine whether the requested change belongs to:

```text
core installer
tool implementation
tool metadata
UI
Makefile
documentation
```

---

## Step 2 — Prefer existing abstractions

Before creating a new helper, search:

```text
lib/
```

and existing tools.

Reuse existing functions when possible.

Do not create duplicate implementations of:

- tool discovery
- metadata parsing
- installation
- uninstallation
- command execution
- UI handling

---

## Step 3 — Keep core code generic

The core system should operate on tool metadata.

Avoid adding code such as:

```bash
install_sort_extension
install_json_formatter
install_kubectl_helper
```

Instead:

```bash
install_tool "$tool_dir"
```

The individual tool owns its behavior.

---

## Step 4 — Add tests

When modifying core functionality, add or update tests.

At minimum verify:

```text
tool discovery
metadata parsing
tool selection
installation
uninstallation
tool execution
invalid tool handling
```

---

## Step 5 — Validate with Make

AI agents should prefer:

```bash
make check
```

before considering the change complete.

If `make check` does not exist yet, create the appropriate validation target.

---

# 11. Adding a New Shell Tool

Example:

```text
shell/my-tool/
```

Create:

```text
shell/my-tool/
├── tool.yaml
├── install.sh
├── uninstall.sh
├── run.sh
└── my-tool.sh
```

`tool.yaml`:

```yaml
name: my-tool
type: shell
description: My useful developer tool
version: 1.0.0
command: my-tool
```

`install.sh` installs the command.

After implementation:

```bash
make list
```

must show:

```text
my-tool
```

Then:

```bash
make install
```

must make it available to the user.

---

# 12. Adding a VS Code Extension

Create:

```text
extension/my-extension/
├── tool.yaml
├── install.sh
├── uninstall.sh
└── README.md
```

Example metadata:

```yaml
name: my-extension
type: extension
description: My VS Code extension
version: 1.0.0
extension_id: publisher.my-extension
```

Installation:

```bash
code --install-extension publisher.my-extension
```

Uninstallation:

```bash
code --uninstall-extension publisher.my-extension
```

The installer should validate:

```bash
command -v code
```

before attempting installation.

---

# 13. Adding a Web Tool

Create:

```text
web/my-web-tool/
├── tool.yaml
├── install.sh
├── uninstall.sh
├── run.sh
├── index.html
├── app.js
├── style.css
└── README.md
```

The user experience should be:

```bash
make run TOOL=my-web-tool
```

or:

```bash
./tools run my-web-tool
```

The user should not need to know the internal file structure.

---

# 14. Interactive Installer

The long-term goal is an interactive checkbox UI.

Example:

```text
╔══════════════════════════════════════════════════╗
║                  🛠 dev-tools                    ║
╚══════════════════════════════════════════════════╝

Shell

  [ ] sort-files
  [ ] unique-lines
  [ ] kubectl-helper

VS Code Extensions

  [ ] sort-extension
  [ ] unique-extension

Web

  [ ] json-formatter
  [ ] sql-formatter

────────────────────────────────────────────────────

↑/↓  Navigate
Space Select
A    Select all
N    Select none
Enter Install
Q    Quit
```

The UI should be generated dynamically from discovered tools.

Do NOT hard-code:

```text
sort-files
unique-lines
json-formatter
```

in the UI.

---

# 15. Dependency Philosophy

Prefer tools that are already available on common developer machines.

Before introducing a dependency, ask:

1. Can Bash implement this reliably?
2. Can an existing dependency be reused?
3. Is the dependency available on macOS and Linux?
4. Does it require sudo?
5. Can the dependency be installed automatically?

Avoid unnecessary dependencies.

For interactive UI, a dependency such as `gum` or `fzf` may be appropriate, but the installer should provide a clear fallback or installation message.

---

# 16. Platform Support

Primary platforms:

```text
macOS
Linux
```

The code should detect the operating system when behavior differs.

Example:

```bash
case "$(uname -s)" in
  Darwin)
    ...
    ;;
  Linux)
    ...
    ;;
  *)
    echo "Unsupported operating system"
    exit 1
    ;;
esac
```

Do not assume:

```text
/usr/local/bin
```

is writable.

Use `sudo` only when necessary.

---

# 17. Error Handling

Shell scripts must use:

```bash
set -euo pipefail
```

Errors should be actionable.

Bad:

```text
command failed
```

Better:

```text
Error: VS Code 'code' command was not found.

Please enable the VS Code command-line tool and run:
    make install
again.
```

Never silently ignore installation failures.

---

# 18. Security Rules

AI agents MUST NOT introduce:

```bash
curl ... | bash
```

unless explicitly required and reviewed.

Do not execute arbitrary downloaded scripts.

Do not modify:

```text
~/.ssh/
~/.gitconfig
~/.zshrc
~/.bashrc
```

without explicit tool requirements.

Do not overwrite existing commands in:

```text
/usr/local/bin
```

without clearly identifying the conflict.

Installation should make destructive operations explicit.

---

# 19. Naming Convention

Tool directories should use:

```text
kebab-case
```

Examples:

```text
sort-files
json-formatter
sql-formatter
kubectl-helper
unique-lines
```

Avoid:

```text
SortFiles
sort_files
sortFiles
```

The `name` in `tool.yaml` should normally match the directory name.

---

# 20. Documentation

Each non-trivial tool should have a:

```text
README.md
```

containing:

```text
Purpose
Installation
Usage
Examples
Dependencies
Platform support
Uninstallation
```

Example:

```markdown
# json-formatter

## Purpose

Format and validate JSON.

## Usage

```bash
make run TOOL=json-formatter
```

## Dependencies

None.

## Supported Platforms

macOS
Linux
```

---

# 21. What AI Agents Should NOT Do

Do not:

- hard-code tool names into the core installer
- duplicate installation logic
- move tools between categories without a reason
- introduce unnecessary dependencies
- modify unrelated tools
- rewrite the entire installer for a small feature
- remove existing tools without explicit instruction
- change public command names unnecessarily
- silently change installation locations
- break existing `make` commands

Prefer small, isolated changes.

---

# 22. Definition of Done

A feature is considered complete when:

### Code

- [ ] Implementation is complete
- [ ] Existing architecture is respected
- [ ] No unnecessary duplication
- [ ] Errors are handled

### Tool

- [ ] `tool.yaml` exists
- [ ] `install.sh` exists when installation is required
- [ ] `uninstall.sh` exists
- [ ] `run.sh` exists when appropriate
- [ ] Tool is automatically discovered

### Make

- [ ] Relevant `make` command works
- [ ] `make list` works
- [ ] `make check` passes

### Documentation

- [ ] README updated when behavior changes
- [ ] New tool documented

### Compatibility

- [ ] macOS considered
- [ ] Linux considered
- [ ] Existing tools still work

---

# 23. AI Agent Decision Rules

When an AI agent receives a request, classify it first.

### New tool

Create:

```text
<category>/<tool-name>/
```

Do not modify the core installer unless required.

### Installer feature

Modify:

```text
install.sh
lib/
tools
```

and add tests.

### UI feature

Prefer:

```text
lib/ui.sh
```

Keep tool discovery separate from UI rendering.

### New CLI command

Modify:

```text
tools
Makefile
```

Keep the implementation reusable.

### Bug fix

Find the smallest layer responsible for the bug.

Do not redesign the architecture unless necessary.

---

# 24. Preferred Development Commands

AI agents should use these commands when working on the project:

```bash
make list
```

Discover all tools.

```bash
make install
```

Run the installer.

```bash
make uninstall
```

Remove installed tools.

```bash
make run TOOL=<tool-name>
```

Run a specific tool.

```bash
make test
```

Run tests.

```bash
make lint
```

Run linting/static checks.

```bash
make check
```

Run the complete validation.

---

# 25. Long-Term Architecture

The project should evolve toward:

```text
                     ┌─────────────────┐
                     │    dev-tools    │
                     └────────┬────────┘
                              │
                     Tool Discovery
                              │
                    ┌─────────┴─────────┐
                    │                   │
                tool.yaml          Tool Directory
                    │                   │
          ┌─────────┼─────────┐         │
          │         │         │         │
        shell   extension     web       │
          │         │         │         │
          └─────────┴─────────┴─────────┘
                              │
                       Install / Run
                              │
                 ┌────────────┼────────────┐
                 │            │            │
             /usr/local   VS Code       Browser
                /bin      Extension        UI
```

The most important architectural property is:

> **The core system knows how to manage tools, but does not need to know what each tool does.**

This allows the repository to grow from:

```text
5 tools
```

to:

```text
50 tools
```

or:

```text
100+ tools
```

without turning the installer into a large collection of tool-specific logic.

---

# 26. AI Implementation Priority

When implementing the project, use this order:

```text
1. Tool metadata
2. Automatic discovery
3. Generic install/uninstall
4. CLI
5. Makefile
6. Interactive checkbox UI
7. Tool execution
8. Validation/tests
9. Documentation
```

Do not prematurely build complex infrastructure.

Start with a simple generic architecture and extend it only when a real requirement appears.

---

# 27. Final Rule

Before implementing any change, ask:

> "Can this be implemented as a new independent tool instead of changing the core system?"

If yes, create a new tool.

If no, determine whether the change belongs in:

```text
lib/
tools
install.sh
Makefile
```

Keep the core small.

**The goal of `dev-tools` is not to become another application.**

Its purpose is to make distributing, installing, running, and maintaining small developer tools effortless.