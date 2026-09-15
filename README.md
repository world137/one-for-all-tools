# dev-tools

A simple toolbox for sharing and installing personal developer tools.

## Structure

```text
dev-tools/
├── tools
├── install.sh
├── uninstall.sh
├── shell/
├── binary/
├── extension/
├── web/
└── lib/
```

Each tool is self-contained and discovered automatically from its `tool.yaml`.

## Usage

```bash
make init
```

Links `tools` onto your `PATH` (so `tools` works from any directory, for
any user who clones this repo) and installs every tool, non-interactively.

For more control, use `./install.sh` to pick which tools to install
interactively, or the individual commands below:

```bash
./tools list           # tools you've installed
./tools list-all       # every tool in the repo, installed or not
./tools install        # interactive picker
./tools install-all    # install every tool, no prompts
./tools uninstall      # interactive picker over installed tools
./tools run <tool-name>
./tools link            # symlink tools onto PATH (/usr/local/bin, falls back to ~/.local/bin)
./tools unlink           # remove that symlink
```

Once linked, drop the `./` and run it from anywhere:

```bash
tools run go-struct-to-json
```

## Adding a tool

Create a directory under one of:

- `shell/`
- `binary/`
- `extension/`
- `web/`

Then add a `tool.yaml` and an `install.sh`.

Example:

```text
shell/my-tool/
├── tool.yaml
├── install.sh
├── uninstall.sh
└── my-tool.sh
```

The root installer will discover it automatically.
