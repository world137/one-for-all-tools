# PDFToPNG

## Purpose

Convert each page of a PDF into a PNG image, from the command line.

## Installation

```bash
make install
```

or directly:

```bash
./binary/PDFToPNG/install.sh
```

This builds the Go source with `go build` and installs the resulting binary
to `/usr/local/bin/pdftopng`.

## Usage

```bash
pdftopng input.pdf [output-prefix]
```

Produces `output-prefix-1.png`, `output-prefix-2.png`, ... (one per page).
`output-prefix` defaults to the input filename without its extension.

## Dependencies

- Go toolchain (`go`) on `PATH` at install/build time only.
- [poppler](https://poppler.freedesktop.org/)'s `pdftoppm` on `PATH` at
  **run** time — this tool wraps it rather than implementing PDF rendering
  itself:
  - macOS: `brew install poppler`
  - Debian/Ubuntu: `sudo apt install poppler-utils`

## Supported Platforms

macOS
Linux

## Uninstallation

```bash
./binary/PDFToPNG/uninstall.sh
```
