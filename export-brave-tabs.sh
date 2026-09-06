#!/bin/zsh
set -euo pipefail

# Standing Kit-style log is the home (system/ pkm/brave-tabs.md).
# Desktop markdown is optional (--desktop) — not a third SSOT.
# Override standing: BRAVE_TABS_STANDING=/path/to/file
# Skip standing: --no-standing   or   BRAVE_TABS_STANDING=
STANDING_DEFAULT="$HOME/repos/system/pkm/brave-tabs.md"
if [[ -v BRAVE_TABS_STANDING ]]; then
  STANDING="$BRAVE_TABS_STANDING"
else
  STANDING="$STANDING_DEFAULT"
fi
NO_STANDING=0
WANT_DESKTOP=0
DESKTOP_OUT=""
POSITIONAL=()
for a in "$@"; do
  if [[ "$a" == "--no-standing" ]]; then
    NO_STANDING=1
  elif [[ "$a" == "--desktop" ]]; then
    WANT_DESKTOP=1
  elif [[ "$a" == --desktop=* ]]; then
    WANT_DESKTOP=1
    DESKTOP_OUT="${a#--desktop=}"
  else
    POSITIONAL+=("$a")
  fi
done
# Positional path after --desktop means custom Desktop/snapshot path
if (( WANT_DESKTOP )) && (( ${#POSITIONAL[@]} > 0 )); then
  DESKTOP_OUT="${POSITIONAL[1]}"
elif (( WANT_DESKTOP )) && [[ -z "$DESKTOP_OUT" ]]; then
  DESKTOP_OUT="$HOME/Desktop/brave-tabs-$(date +%Y-%m-%d-%H%M).md"
elif (( ${#POSITIONAL[@]} > 0 )); then
  echo "Unknown argument: ${POSITIONAL[1]}" >&2
  echo "Usage: export-brave-tabs.sh [--no-standing] [--desktop [path]]" >&2
  exit 2
fi

RAW="$(/usr/bin/osascript <<'APPLESCRIPT'
tell application "Brave Browser"
  set md to "# Brave tabs" & linefeed & "Exported " & (current date as string) & linefeed & linefeed
  set wi to 0
  repeat with w in every window
    set wi to wi + 1
    set md to md & "## Window " & wi & linefeed & linefeed
    repeat with t in every tab of w
      set tabTitle to title of t
      set tabURL to URL of t
      set md to md & "- [" & tabTitle & "](" & tabURL & ")" & linefeed
    end repeat
    set md to md & linefeed
  end repeat
  return md
end tell
APPLESCRIPT
)"

if (( WANT_DESKTOP )); then
  print -r -- "$RAW" > "$DESKTOP_OUT"
  echo "Wrote optional snapshot $DESKTOP_OUT"
  open -R "$DESKTOP_OUT"
fi

if (( NO_STANDING )) || [[ -z "$STANDING" ]]; then
  if (( ! WANT_DESKTOP )); then
    echo "Nothing to do: standing skipped and --desktop not set." >&2
    exit 2
  fi
  echo "Standing append skipped."
  exit 0
fi

STAMP="$(TZ=Europe/Warsaw date +%Y-%m-%dT%H:%M)"

if [[ ! -f "$STANDING" ]]; then
  mkdir -p "$(dirname "$STANDING")"
  cat > "$STANDING" <<'HDR'
---
title: Brave tabs capture log
home: pkm/brave-tabs.md
format: "YYYY-MM-DDTHH:MM W{n} | title | url"
timezone: Europe/Warsaw
appends: export-brave-tabs.sh
triage: Larry / Principal
process: false
---

# Brave tabs

Standing capture log. One run appends dated lines (Kit-style stamp first). Optional Desktop snapshot only with --desktop. Do not invent tabs.

HDR
fi

print -r -- "$RAW" | /usr/bin/python3 -c '
import sys
from pathlib import Path
standing = Path(sys.argv[1])
stamp = sys.argv[2]
raw = sys.stdin.read()
window = 0
lines = []
for raw_line in raw.splitlines():
    line = raw_line.strip()
    if line.startswith("## Window "):
        try:
            window = int(line.split()[-1])
        except ValueError:
            window = 0
        continue
    if not line.startswith("- ["):
        continue
    try:
        title = line[3:line.rindex("](")]
        url = line[line.rindex("](") + 2:-1]
    except ValueError:
        continue
    title = title.replace("|", "/").replace("\n", " ").strip()
    lines.append(f"{stamp} W{window} | {title} | {url}")
text = standing.read_text(encoding="utf-8") if standing.exists() else ""
with standing.open("a", encoding="utf-8") as f:
    if text and not text.endswith("\n"):
        f.write("\n")
    if lines:
        f.write("\n")
        f.write("\n".join(lines) + "\n")
print(f"Appended {len(lines)} lines to {standing}")
' "$STANDING" "$STAMP"

# Console Log Reports need a real .log under ~/Library/Logs (symlinks invisible).
# Lock A: regenerate projection from standing SSOT; do not move the home.
PROJECTOR="${SYSTEM_HOME:-$HOME/repos/system}/scripts/project-console-logs.sh"
if [[ -x "$PROJECTOR" ]]; then
  "$PROJECTOR" || echo "Console projection failed (non-fatal): $PROJECTOR" >&2
else
  echo "Console projector missing: $PROJECTOR" >&2
fi
