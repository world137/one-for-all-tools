package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func main() {
	if len(os.Args) < 2 || os.Args[1] == "-h" || os.Args[1] == "--help" {
		usage()
		os.Exit(1)
	}

	input := os.Args[1]
	if _, err := os.Stat(input); err != nil {
		fmt.Fprintf(os.Stderr, "Error: cannot read input PDF %q: %v\n", input, err)
		os.Exit(1)
	}

	outputPrefix := strings.TrimSuffix(filepath.Base(input), filepath.Ext(input))
	if len(os.Args) >= 3 {
		outputPrefix = os.Args[2]
	}

	pdftoppmPath, err := exec.LookPath("pdftoppm")
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error: 'pdftoppm' was not found on PATH.")
		fmt.Fprintln(os.Stderr, "pdftopng converts PDFs by wrapping poppler's pdftoppm.")
		fmt.Fprintln(os.Stderr, "Install it with:")
		fmt.Fprintln(os.Stderr, "  macOS:         brew install poppler")
		fmt.Fprintln(os.Stderr, "  Debian/Ubuntu: sudo apt install poppler-utils")
		os.Exit(1)
	}

	cmd := exec.Command(pdftoppmPath, "-png", input, outputPrefix)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: pdftoppm failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Converted %s -> %s-*.png\n", input, outputPrefix)
}

func usage() {
	fmt.Fprintln(os.Stderr, "Usage: pdftopng <input.pdf> [output-prefix]")
	fmt.Fprintln(os.Stderr)
	fmt.Fprintln(os.Stderr, "Converts each page of <input.pdf> to a PNG image named")
	fmt.Fprintln(os.Stderr, "<output-prefix>-1.png, <output-prefix>-2.png, ...")
	fmt.Fprintln(os.Stderr, "output-prefix defaults to the input filename without its extension.")
}
