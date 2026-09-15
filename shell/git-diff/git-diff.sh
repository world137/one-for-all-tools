#!/bin/bash
# Standalone Monaco diff viewer, same look/behavior as ../diffFile.sh
# (dark theme, side-by-side, Option+Z word-wrap toggle) — but content
# comes from git instead of two files on disk.
#
# Usage:
#   gitDiff.sh <file>                        # HEAD:file  vs  working tree
#   gitDiff.sh <file> <ref1>                 # ref1:file  vs  working tree
#   gitDiff.sh <file> <ref1> <ref2>          # ref1:file  vs  ref2:file
#   gitDiff.sh <file> <ref1> <ref2> <ref3>+  # N >= 3 refs: N horizontally
#                                             # scrollable inline-diff panes,
#                                             # pane i = diff(ref[i-1], ref[i]),
#                                             # pane 1 = diff(ref1^, ref1).
#   gitDiff.sh <repo> <hash1> <hash2> [...]  # every changed file, hash1
#                                             # (old) vs the LAST hash given
#                                             # (new) — any hashes in
#                                             # between are ignored.

set -uo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage:" >&2
  echo "  $(basename "$0") <file> [ref1] [ref2]" >&2
  echo "  $(basename "$0") <repo> <hash1> <hash2> [<hash3> ...]   # diff all changed files" >&2
  exit 1
fi

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

b64_str() {
  printf '%s' "$1" | base64 | tr -d '\n'
}

# Cap on how large a single file's content this tool will embed/diff.
# Multi-file modes can walk hundreds of changed files across a commit
# range — without this, a single large tracked file (data dump, binary)
# makes the tool try to base64 the whole blob into the page and hang.
MAX_FILE_BYTES=2097152 # 2 MiB

# base64 sidesteps all JS-string-escaping concerns (quotes, backslashes,
# backticks, control chars) — the alphabet can't contain any of them.
# Missing-at-ref (added/deleted file) prints nothing, not an error.
# `cat-file -s` doubles as the existence check (fails if missing) and the
# size check, in one subprocess instead of two.
b64_of_ref() {
  local ref="$1" path="$2" repo_root="$3" size
  size="$(git -C "$repo_root" cat-file -s "${ref}:${path}" 2>/dev/null)" || return 0
  if [ "$size" -gt "$MAX_FILE_BYTES" ]; then
    b64_str "(file too large to preview in this viewer — ${size} bytes)"
    return 0
  fi
  git -C "$repo_root" show "${ref}:${path}" | base64 | tr -d '\n'
}

if [ -d "$1" ]; then
  # ---- multi-file mode: <repo> <hash1> <hash2> [<hash3> ...] ----
  REPO_ARG="$1"
  shift
  if [ "$#" -lt 2 ]; then
    echo "Error: multi-file mode needs at least 2 commit hashes: $(basename "$0") <repo> <hash1> <hash2> [...]" >&2
    exit 1
  fi
  HASHES=("$@")

  REPO_ROOT="$(cd "$REPO_ARG" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)"
  if [ -z "$REPO_ROOT" ]; then
    echo "Error: not a git repository: $REPO_ARG" >&2
    exit 1
  fi

  if [ "${#HASHES[@]}" -ge 3 ]; then
    # ---- repo chain mode: hashes[0] is the fixed base; one pane per
    # remaining hash, each a full sidebar+diff-editor view of that hash
    # against the base (N hashes -> N-1 panes) ----
    BASE_HASH="${HASHES[0]}"
    OLD_REF="$BASE_HASH"
    OLD_LABEL="$BASE_HASH"
    PANES_JS=""
    for ((i = 1; i < ${#HASHES[@]}; i++)); do
      NEW_REF="${HASHES[$i]}"

      CHANGED="$(git -C "$REPO_ROOT" diff --no-renames --name-status "$OLD_REF" "$NEW_REF" 2>&1)"
      GIT_STATUS=$?
      if [ "$GIT_STATUS" -ne 0 ]; then
        echo "Error: git diff failed ($OLD_LABEL -> $NEW_REF):" >&2
        echo "$CHANGED" >&2
        exit 1
      fi
      # git's own binary call (numstat prints "-\t-\tpath" for binary files)
      # — more reliable than reinventing NUL-byte sniffing, and portable
      # (no dependency on GNU-only grep -P).
      BINARY_SET="$(git -C "$REPO_ROOT" diff --no-renames --numstat "$OLD_REF" "$NEW_REF" 2>/dev/null | awk -F'\t' '$1 == "-" && $2 == "-" { print $3 }')"

      FILES_JS=""
      if [ -n "$CHANGED" ]; then
        while IFS=$'\t' read -r status relpath; do
          [ -z "$relpath" ] && continue
          lang="$(guess_language "$relpath")"
          path_b64="$(b64_str "$relpath")"
          if grep -Fxq -- "$relpath" <<< "$BINARY_SET"; then
            old_b64="$(b64_str '(binary file, not shown)')"
            new_b64="$(b64_str '(binary file, not shown)')"
          else
            old_b64="$(b64_of_ref "$OLD_REF" "$relpath" "$REPO_ROOT")"
            new_b64="$(b64_of_ref "$NEW_REF" "$relpath" "$REPO_ROOT")"
          fi
          FILES_JS="${FILES_JS}{path:'${path_b64}',status:'${status}',language:'${lang}',oldC:'${old_b64}',newC:'${new_b64}'},"
        done <<< "$CHANGED"
      fi
      FILES_JS="[${FILES_JS%,}]"

      old_label_b64="$(b64_str "$OLD_LABEL")"
      new_label_b64="$(b64_str "$NEW_REF")"
      PANES_JS="${PANES_JS}{oldLabel:'${old_label_b64}',newLabel:'${new_label_b64}',files:${FILES_JS}},"
    done
    PANES_JS="[${PANES_JS%,}]"

    TITLE_ESC="$(html_escape "$(basename "$REPO_ROOT") ($BASE_HASH vs $((${#HASHES[@]} - 1)) others)")"
    OUT_HTML="$(mktemp "${TMPDIR:-/tmp}/gitdiff-repo-chain.XXXXXX").html"

    cat > "$OUT_HTML" <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>${TITLE_ESC}</title>
<style>
  html, body { margin: 0; padding: 0; height: 100%; background: #1e1e1e; }
  #page-header {
    font: 12px -apple-system, "Segoe UI", sans-serif;
    color: #cccccc;
    background: #252526;
    border-bottom: 1px solid #3c3c3c;
    height: 28px;
    line-height: 28px;
    padding: 0 12px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  #panes-row {
    position: absolute;
    top: 28px; left: 0; right: 0; bottom: 0;
    display: flex;
    overflow-x: auto;
    overflow-y: hidden;
  }
  .repo-pane {
    flex: 0 0 900px;
    min-width: 900px;
    height: 100%;
    display: flex;
    flex-direction: column;
    border-right: 1px solid #3c3c3c;
  }
  .repo-pane-header {
    font: 12px -apple-system, "Segoe UI", sans-serif;
    color: #cccccc;
    background: #252526;
    border-bottom: 1px solid #3c3c3c;
    height: 24px;
    line-height: 24px;
    padding: 0 10px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    flex-shrink: 0;
  }
  .repo-pane-body { flex: 1; min-height: 0; display: flex; }
  .repo-sidebar {
    width: 240px;
    flex-shrink: 0;
    overflow-y: auto;
    background: #252526;
    border-right: 1px solid #3c3c3c;
    font: 12px ui-monospace, Menlo, monospace;
    color: #cccccc;
    padding: 4px 0;
  }
  .repo-container { flex: 1; min-width: 0; height: 100%; }
  .file-item {
    display: flex;
    gap: 8px;
    align-items: center;
    padding: 3px 10px;
    cursor: pointer;
    white-space: nowrap;
    overflow: hidden;
  }
  .file-item:hover { background: #2a2d2e; }
  .file-item.active { background: #37373d; }
  .status-badge { width: 14px; text-align: center; font-weight: bold; flex-shrink: 0; }
  .status-A { color: #81b88b; }
  .status-M { color: #e2c08d; }
  .status-D { color: #f14c4c; }
  .status-T { color: #6796e6; }
  .file-path { overflow: hidden; text-overflow: ellipsis; }
  .no-changes { padding: 8px 10px; color: #888888; font-style: italic; }
</style>
</head>
<body>
<div id="page-header">${TITLE_ESC}</div>
<div id="panes-row"></div>
<script src="https://cdn.jsdelivr.net/npm/monaco-editor@0.45.0/min/vs/loader.js"></script>
<script>
  function b64ToUtf8(b64) {
    var binary = atob(b64);
    var bytes = Uint8Array.from(binary, function (c) { return c.charCodeAt(0); });
    return new TextDecoder('utf-8').decode(bytes);
  }

  var panes = ${PANES_JS};

  require.config({ paths: { vs: 'https://cdn.jsdelivr.net/npm/monaco-editor@0.45.0/min/vs' } });
  require(['vs/editor/editor.main'], function () {
    monaco.editor.setTheme('vs-dark');
    var row = document.getElementById('panes-row');
    var allDiffEditors = [];

    panes.forEach(function (paneData) {
      var paneEl = document.createElement('div');
      paneEl.className = 'repo-pane';

      var header = document.createElement('div');
      header.className = 'repo-pane-header';
      header.textContent = b64ToUtf8(paneData.oldLabel) + ' → ' + b64ToUtf8(paneData.newLabel);

      var body = document.createElement('div');
      body.className = 'repo-pane-body';

      var sidebar = document.createElement('div');
      sidebar.className = 'repo-sidebar';

      var container = document.createElement('div');
      container.className = 'repo-container';

      body.appendChild(sidebar);
      body.appendChild(container);
      paneEl.appendChild(header);
      paneEl.appendChild(body);
      row.appendChild(paneEl);

      var files = paneData.files;

      if (!files.length) {
        var empty = document.createElement('div');
        empty.className = 'no-changes';
        empty.textContent = 'No file differences';
        sidebar.appendChild(empty);
        return;
      }

      var diffEditor = monaco.editor.createDiffEditor(container, {
        automaticLayout: true,
        readOnly: true,
        renderSideBySide: true,
        originalEditable: false,
      });
      allDiffEditors.push(diffEditor);

      var models = files.map(function (f) {
        return {
          original: monaco.editor.createModel(b64ToUtf8(f.oldC), f.language),
          modified: monaco.editor.createModel(b64ToUtf8(f.newC), f.language),
        };
      });

      var items = [];
      files.forEach(function (f, idx) {
        var path = b64ToUtf8(f.path);
        var item = document.createElement('div');
        item.className = 'file-item';
        item.title = path;

        var badge = document.createElement('span');
        badge.className = 'status-badge status-' + f.status;
        badge.textContent = f.status;

        var label = document.createElement('span');
        label.className = 'file-path';
        label.textContent = path;

        item.appendChild(badge);
        item.appendChild(label);
        item.addEventListener('click', function () { selectFile(idx); });
        sidebar.appendChild(item);
        items.push(item);
      });

      function selectFile(idx) {
        items.forEach(function (el, j) { el.classList.toggle('active', j === idx); });
        diffEditor.setModel(models[idx]);
      }

      selectFile(0);
    });

    var wordWrapEnabled = false;
    document.addEventListener('keydown', function (e) {
      if (e.altKey && e.code === 'KeyZ') {
        e.preventDefault();
        wordWrapEnabled = !wordWrapEnabled;
        var mode = wordWrapEnabled ? 'on' : 'off';
        allDiffEditors.forEach(function (de) {
          de.getOriginalEditor().updateOptions({ wordWrap: mode });
          de.getModifiedEditor().updateOptions({ wordWrap: mode });
        });
      }
    });
  });
</script>
</body>
</html>
EOF

  else
  # ---- repo mode: exactly 2 hashes -> single page, sidebar + one diff editor ----
  HASH_OLD="${HASHES[0]}"
  HASH_NEW="${HASHES[1]}"

  CHANGED="$(git -C "$REPO_ROOT" diff --no-renames --name-status "$HASH_OLD" "$HASH_NEW" 2>&1)"
  GIT_STATUS=$?
  if [ "$GIT_STATUS" -ne 0 ]; then
    echo "Error: git diff failed:" >&2
    echo "$CHANGED" >&2
    exit 1
  fi
  if [ -z "$CHANGED" ]; then
    echo "No file differences between $HASH_OLD and $HASH_NEW" >&2
    exit 0
  fi
  BINARY_SET="$(git -C "$REPO_ROOT" diff --no-renames --numstat "$HASH_OLD" "$HASH_NEW" 2>/dev/null | awk -F'\t' '$1 == "-" && $2 == "-" { print $3 }')"

  FILES_JS=""
  while IFS=$'\t' read -r status relpath; do
    [ -z "$relpath" ] && continue
    lang="$(guess_language "$relpath")"
    path_b64="$(b64_str "$relpath")"
    if grep -Fxq -- "$relpath" <<< "$BINARY_SET"; then
      old_b64="$(b64_str '(binary file, not shown)')"
      new_b64="$(b64_str '(binary file, not shown)')"
    else
      old_b64="$(b64_of_ref "$HASH_OLD" "$relpath" "$REPO_ROOT")"
      new_b64="$(b64_of_ref "$HASH_NEW" "$relpath" "$REPO_ROOT")"
    fi
    FILES_JS="${FILES_JS}{path:'${path_b64}',status:'${status}',language:'${lang}',oldC:'${old_b64}',newC:'${new_b64}'},"
  done <<< "$CHANGED"
  FILES_JS="[${FILES_JS%,}]"

  HASH_OLD_B64="$(b64_str "$HASH_OLD")"
  HASH_NEW_B64="$(b64_str "$HASH_NEW")"
  TITLE_ESC="$(html_escape "$HASH_OLD ↔ $HASH_NEW ($(basename "$REPO_ROOT"))")"

  OUT_HTML="$(mktemp "${TMPDIR:-/tmp}/gitdiff-multi.XXXXXX").html"

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
  #body-wrap { position: absolute; top: 28px; left: 0; right: 0; bottom: 0; display: flex; }
  #sidebar {
    width: 280px;
    flex-shrink: 0;
    overflow-y: auto;
    background: #252526;
    border-right: 1px solid #3c3c3c;
    font: 12px ui-monospace, Menlo, monospace;
    color: #cccccc;
    padding: 4px 0;
  }
  .file-item {
    display: flex;
    gap: 8px;
    align-items: center;
    padding: 3px 10px;
    cursor: pointer;
    white-space: nowrap;
    overflow: hidden;
  }
  .file-item:hover { background: #2a2d2e; }
  .file-item.active { background: #37373d; }
  .status-badge { width: 14px; text-align: center; font-weight: bold; flex-shrink: 0; }
  .status-A { color: #81b88b; }
  .status-M { color: #e2c08d; }
  .status-D { color: #f14c4c; }
  .status-T { color: #6796e6; }
  .file-path { overflow: hidden; text-overflow: ellipsis; }
  #container { flex: 1; height: 100%; }
</style>
</head>
<body>
<div id="header">
  <div class="pane left"></div>
  <div class="pane right"></div>
</div>
<div id="body-wrap">
  <div id="sidebar"></div>
  <div id="container"></div>
</div>
<script src="https://cdn.jsdelivr.net/npm/monaco-editor@0.45.0/min/vs/loader.js"></script>
<script>
  function b64ToUtf8(b64) {
    var binary = atob(b64);
    var bytes = Uint8Array.from(binary, function (c) { return c.charCodeAt(0); });
    return new TextDecoder('utf-8').decode(bytes);
  }

  var HASH_OLD = b64ToUtf8('${HASH_OLD_B64}');
  var HASH_NEW = b64ToUtf8('${HASH_NEW_B64}');
  var files = ${FILES_JS};

  require.config({ paths: { vs: 'https://cdn.jsdelivr.net/npm/monaco-editor@0.45.0/min/vs' } });
  require(['vs/editor/editor.main'], function () {
    monaco.editor.setTheme('vs-dark');
    var diffEditor = monaco.editor.createDiffEditor(document.getElementById('container'), {
      automaticLayout: true,
      readOnly: true,
      renderSideBySide: true,
      originalEditable: false,
    });

    var models = files.map(function (f) {
      return {
        original: monaco.editor.createModel(b64ToUtf8(f.oldC), f.language),
        modified: monaco.editor.createModel(b64ToUtf8(f.newC), f.language),
      };
    });

    var sidebar = document.getElementById('sidebar');
    var items = [];
    files.forEach(function (f, i) {
      var path = b64ToUtf8(f.path);
      var item = document.createElement('div');
      item.className = 'file-item';
      item.title = path;

      var badge = document.createElement('span');
      badge.className = 'status-badge status-' + f.status;
      badge.textContent = f.status;

      var label = document.createElement('span');
      label.className = 'file-path';
      label.textContent = path;

      item.appendChild(badge);
      item.appendChild(label);
      item.addEventListener('click', function () { selectFile(i); });
      sidebar.appendChild(item);
      items.push(item);
    });

    function selectFile(i) {
      items.forEach(function (el, j) { el.classList.toggle('active', j === i); });
      diffEditor.setModel(models[i]);
      var path = b64ToUtf8(files[i].path);
      document.querySelector('#header .pane.left').textContent = HASH_OLD + ':' + path;
      document.querySelector('#header .pane.right').textContent = HASH_NEW + ':' + path;
    }

    if (files.length) selectFile(0);

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
  fi

else
  # ---- single-file mode: <file> [ref1] [ref2] [ref3] ... ----
  FILE="$1"
  shift
  REFS=("$@")

  FILE_DIR="$(cd "$(dirname "$FILE")" 2>/dev/null && pwd)"
  if [ -z "$FILE_DIR" ]; then
    echo "Error: directory not found for: $FILE" >&2
    exit 1
  fi
  FILE_BASE="$(basename "$FILE")"

  REPO_ROOT="$(cd "$FILE_DIR" && git rev-parse --show-toplevel 2>/dev/null)"
  if [ -z "$REPO_ROOT" ]; then
    echo "Error: not inside a git repository: $FILE" >&2
    exit 1
  fi
  PREFIX="$(cd "$FILE_DIR" && git rev-parse --show-prefix)"
  REL_PATH="${PREFIX}${FILE_BASE}"
  LANGUAGE="$(guess_language "$REL_PATH")"

  if [ "${#REFS[@]}" -ge 3 ]; then
    # ---- chain mode: refs[0] is the fixed base; one pane per remaining
    # ref, each diffing it against that base (N refs -> N-1 panes) ----
    BASE_REF="${REFS[0]}"
    WINDOWS_JS=""
    for ((i = 1; i < ${#REFS[@]}; i++)); do
      NEW_REF="${REFS[$i]}"

      old_b64="$(b64_of_ref "$BASE_REF" "$REL_PATH" "$REPO_ROOT")"
      new_b64="$(b64_of_ref "$NEW_REF" "$REL_PATH" "$REPO_ROOT")"
      old_label_b64="$(b64_str "$BASE_REF")"
      new_label_b64="$(b64_str "$NEW_REF")"

      WINDOWS_JS="${WINDOWS_JS}{oldLabel:'${old_label_b64}',newLabel:'${new_label_b64}',oldC:'${old_b64}',newC:'${new_b64}'},"
    done
    WINDOWS_JS="[${WINDOWS_JS%,}]"

    REL_PATH_ESC="$(html_escape "$REL_PATH")"
    TITLE_ESC="$(html_escape "$REL_PATH ($BASE_REF vs $((${#REFS[@]} - 1)) others)")"

    OUT_HTML="$(mktemp "${TMPDIR:-/tmp}/gitdiff-chain.XXXXXX").html"

    cat > "$OUT_HTML" <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>${TITLE_ESC}</title>
<style>
  html, body { margin: 0; padding: 0; height: 100%; background: #1e1e1e; }
  #page-header {
    font: 12px -apple-system, "Segoe UI", sans-serif;
    color: #cccccc;
    background: #252526;
    border-bottom: 1px solid #3c3c3c;
    height: 28px;
    line-height: 28px;
    padding: 0 12px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  #windows-row {
    position: absolute;
    top: 28px; left: 0; right: 0; bottom: 0;
    display: flex;
    overflow-x: auto;
    overflow-y: hidden;
  }
  .window {
    flex: 0 0 640px;
    min-width: 640px;
    height: 100%;
    display: flex;
    flex-direction: column;
    border-right: 1px solid #3c3c3c;
  }
  .window .win-header {
    font: 12px -apple-system, "Segoe UI", sans-serif;
    color: #cccccc;
    background: #252526;
    border-bottom: 1px solid #3c3c3c;
    height: 24px;
    line-height: 24px;
    padding: 0 10px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    flex-shrink: 0;
  }
  .window .win-body { flex: 1; min-height: 0; }
</style>
</head>
<body>
<div id="page-header">${REL_PATH_ESC}</div>
<div id="windows-row"></div>
<script src="https://cdn.jsdelivr.net/npm/monaco-editor@0.45.0/min/vs/loader.js"></script>
<script>
  function b64ToUtf8(b64) {
    var binary = atob(b64);
    var bytes = Uint8Array.from(binary, function (c) { return c.charCodeAt(0); });
    return new TextDecoder('utf-8').decode(bytes);
  }

  var LANGUAGE = '${LANGUAGE}';
  var windows = ${WINDOWS_JS};

  require.config({ paths: { vs: 'https://cdn.jsdelivr.net/npm/monaco-editor@0.45.0/min/vs' } });
  require(['vs/editor/editor.main'], function () {
    monaco.editor.setTheme('vs-dark');
    var row = document.getElementById('windows-row');
    var diffEditors = [];

    windows.forEach(function (w) {
      var winEl = document.createElement('div');
      winEl.className = 'window';

      var header = document.createElement('div');
      header.className = 'win-header';
      header.textContent = b64ToUtf8(w.oldLabel) + ' → ' + b64ToUtf8(w.newLabel);

      var body = document.createElement('div');
      body.className = 'win-body';

      winEl.appendChild(header);
      winEl.appendChild(body);
      row.appendChild(winEl);

      var original = monaco.editor.createModel(b64ToUtf8(w.oldC), LANGUAGE);
      var modified = monaco.editor.createModel(b64ToUtf8(w.newC), LANGUAGE);

      var diffEditor = monaco.editor.createDiffEditor(body, {
        automaticLayout: true,
        readOnly: true,
        renderSideBySide: false,
        originalEditable: false,
      });
      diffEditor.setModel({ original: original, modified: modified });
      diffEditors.push(diffEditor);
    });

    var wordWrapEnabled = false;
    document.addEventListener('keydown', function (e) {
      if (e.altKey && e.code === 'KeyZ') {
        e.preventDefault();
        wordWrapEnabled = !wordWrapEnabled;
        var mode = wordWrapEnabled ? 'on' : 'off';
        diffEditors.forEach(function (de) {
          de.getOriginalEditor().updateOptions({ wordWrap: mode });
          de.getModifiedEditor().updateOptions({ wordWrap: mode });
        });
      }
    });
  });
</script>
</body>
</html>
EOF

  else
    # ---- classic mode: 0, 1, or 2 refs -> single 2-pane diff editor ----
    REF1="${REFS[0]:-HEAD}"
    REF2="${REFS[1]:-}"

    if [ -z "$REF2" ] && [ ! -f "$FILE" ]; then
      echo "Error: file not found: $FILE" >&2
      exit 1
    fi

    B64_1="$(b64_of_ref "$REF1" "$REL_PATH" "$REPO_ROOT")"
    NAME1="${REF1}:${REL_PATH}"

    if [ -n "$REF2" ]; then
      B64_2="$(b64_of_ref "$REF2" "$REL_PATH" "$REPO_ROOT")"
      NAME2="${REF2}:${REL_PATH}"
    else
      B64_2="$(base64 < "$FILE" | tr -d '\n')"
      NAME2="${REL_PATH} (working tree)"
    fi

    NAME1_ESC="$(html_escape "$NAME1")"
    NAME2_ESC="$(html_escape "$NAME2")"
    TITLE_ESC="$(html_escape "$NAME1 ↔ $NAME2")"

    OUT_HTML="$(mktemp "${TMPDIR:-/tmp}/gitdiff.XXXXXX").html"

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
  fi
fi

if command -v open >/dev/null 2>&1; then
  open "$OUT_HTML"
else
  echo "Diff page written to: $OUT_HTML" >&2
fi
