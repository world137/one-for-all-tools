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
./install.sh
```

Select the tools you want to install.

Other commands:

```bash
./tools list
./tools install
./tools uninstall
./tools run <tool-name>
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
