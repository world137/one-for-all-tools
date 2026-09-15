#!/bin/bash
# Same as diff2.sh — standalone Monaco diff viewer in the browser,
# pure bash, no Python — plus a word-wrap toggle: press Option+Z (⌥Z)
# to toggle word wrap on both diff panes, matching VS Code's shortcut.
#
# Usage: diff3.sh <file1> <file2>

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $(basename "$0") <file1> <file2>" >&2
  exit 1
fi

FILE1="$1"
FILE2="$2"

for f in "$FILE1" "$FILE2"; do
  if [ ! -f "$f" ]; then
    echo "Error: file not found: $f" >&2
    exit 1
  fi
done

guess_language() {
  case "${1##*.}" in
    js|jsx|mjs) echo javascript ;;
    ts|tsx) echo typescript ;;
    py) echo python ;;
    go) echo go ;;
    rs) echo rust ;;
    java) echo java ;;
    c|h) echo c ;;
    cpp|cc|hpp) echo cpp ;;
    cs) echo csharp ;;
    rb) echo ruby ;;
    php) echo php ;;
    json) echo json ;;
    yaml|yml) echo yaml ;;
    html|htm) echo html ;;
    css) echo css ;;
    scss) echo scss ;;
    less) echo less ;;
    md) echo markdown ;;
    sh|bash|zsh) echo shell ;;
    sql) echo sql ;;
    xml) echo xml ;;
    swift) echo swift ;;
    kt) echo kotlin ;;
    toml) echo toml ;;
    ini) echo ini ;;
    *) echo plaintext ;;
  esac
}

html_escape() {
  printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

LANGUAGE="$(guess_language "$FILE1")"
if [ "$LANGUAGE" = "plaintext" ]; then
  LANGUAGE="$(guess_language "$FILE2")"
fi

NAME1="$(basename "$FILE1")"
NAME2="$(basename "$FILE2")"
NAME1_ESC="$(html_escape "$NAME1")"
NAME2_ESC="$(html_escape "$NAME2")"
TITLE_ESC="$(html_escape "$NAME1 ↔ $NAME2")"

# base64 sidesteps all JS-string-escaping concerns (quotes, backslashes,
# backticks, control chars) — the alphabet can't contain any of them.
B64_1="$(base64 < "$FILE1" | tr -d '\n')"
B64_2="$(base64 < "$FILE2" | tr -d '\n')"

OUT_HTML="$(mktemp "${TMPDIR:-/tmp}/diff3.XXXXXX").html"

cat > "$OUT_HTML" <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>${TITLE_ESC}</title>
<style>
  html, body { margin: 0; padding: 0; height: 100%; background: #1e1e1e; }
  #header {
    display: flex;
    font: 12px -apple-system, "Segoe UI", sans-serif;
    color: #cccccc;
    background: #252526;
    border-bottom: 1px solid #3c3c3c;
    height: 28px;
    line-height: 28px;
  }
  #header .pane {
    flex: 1;
    padding: 0 12px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  #header .pane.left { border-right: 1px solid #3c3c3c; }
  #container { position: absolute; top: 28px; left: 0; right: 0; bottom: 0; }
</style>
</head>
<body>
<div id="header">
  <div class="pane left">${NAME1_ESC}</div>
  <div class="pane right">${NAME2_ESC}</div>
</div>
<div id="container"></div>
<script src="https://cdn.jsdelivr.net/npm/monaco-editor@0.45.0/min/vs/loader.js"></script>
<script>
  function b64ToUtf8(b64) {
    var binary = atob(b64);
    var bytes = Uint8Array.from(binary, function (c) { return c.charCodeAt(0); });
    return new TextDecoder('utf-8').decode(bytes);
  }

  require.config({ paths: { vs: 'https://cdn.jsdelivr.net/npm/monaco-editor@0.45.0/min/vs' } });
  require(['vs/editor/editor.main'], function () {
    var original = monaco.editor.createModel(b64ToUtf8('${B64_1}'), '${LANGUAGE}');
    var modified = monaco.editor.createModel(b64ToUtf8('${B64_2}'), '${LANGUAGE}');

    monaco.editor.setTheme('vs-dark');
    var diffEditor = monaco.editor.createDiffEditor(document.getElementById('container'), {
      automaticLayout: true,
      readOnly: true,
      renderSideBySide: true,
      originalEditable: false,
    });
    diffEditor.setModel({ original: original, modified: modified });

    var wordWrapEnabled = false;
    document.addEventListener('keydown', function (e) {
      if (e.altKey && e.code === 'KeyZ') {
        e.preventDefault();
        wordWrapEnabled = !wordWrapEnabled;
        var mode = wordWrapEnabled ? 'on' : 'off';
        diffEditor.getOriginalEditor().updateOptions({ wordWrap: mode });
        diffEditor.getModifiedEditor().updateOptions({ wordWrap: mode });
      }
    });
  });
</script>
</body>
</html>
EOF

if command -v open >/dev/null 2>&1; then
  open "$OUT_HTML"
else
  echo "Diff page written to: $OUT_HTML" >&2
fi
