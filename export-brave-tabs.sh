#!/bin/zsh
# export-brave-tabs — append open Brave tabs to the standing log (and optional snapshot).
set -euo pipefail

readonly PROG_NAME="${0:t}"
readonly PROG_VERSION="0.2.0"

STANDING_DEFAULT="$HOME/repos/system/pkm/brave-tabs.md"
if [[ -v BRAVE_TABS_STANDING ]]; then
  STANDING="$BRAVE_TABS_STANDING"
else
  STANDING="$STANDING_DEFAULT"
fi

NO_STANDING=0
WANT_DESKTOP=0
DESKTOP_OUT=""
QUIET=0

usage() {
  cat <<USAGE
Usage: $PROG_NAME [OPTION]...

Append open Brave Browser tabs to the standing Kit-style log
($STANDING_DEFAULT), then refresh ~/Library/Logs/brave-tabs.log for Console.

Options:
  -h, --help            show this help and exit
  -V, --version         show version and exit
  -q, --quiet           print less (errors still go to stderr)
      --desktop [PATH]  also write a one-off markdown snapshot
                        (default PATH: ~/Desktop/brave-tabs-YYYY-MM-DD-HHMM.md)
      --no-standing     skip the standing log (requires --desktop)

Environment:
  BRAVE_TABS_STANDING   override standing log path; empty skips standing
  SYSTEM_HOME           override system/ root for the Console projector

Exit status:
  0  success (also for --help / --version)
  2  usage error
  other  failure from Brave/osascript or write errors
USAGE
}

version() {
  print -r -- "$PROG_NAME $PROG_VERSION"
}

log() {
  (( QUIET )) && return 0
  print -r -- "$@"
}

die_usage() {
  print -r -- "$PROG_NAME: $*" >&2
  print -r -- "Try '$PROG_NAME --help' for more information." >&2
  exit 2
}

# Parse options. Supports GNU-style long options and an optional path after --desktop.
while (( $# > 0 )); do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -V|--version)
      version
      exit 0
      ;;
    -q|--quiet)
      QUIET=1
      shift
      ;;
    --desktop)
      WANT_DESKTOP=1
      shift
      if (( $# > 0 )) && [[ "$1" != -* ]]; then
        DESKTOP_OUT="$1"
        shift
      fi
      ;;
    --desktop=*)
      WANT_DESKTOP=1
      DESKTOP_OUT="${1#--desktop=}"
      [[ -n "$DESKTOP_OUT" ]] || die_usage "--desktop= requires a path"
      shift
      ;;
    --no-standing)
      NO_STANDING=1
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      die_usage "unrecognized option '$1'"
      ;;
    *)
      die_usage "unexpected argument '$1' (use --desktop PATH for a snapshot file)"
      ;;
  esac
done
(( $# == 0 )) || die_usage "unexpected argument '$1'"

if (( WANT_DESKTOP )) && [[ -z "$DESKTOP_OUT" ]]; then
  DESKTOP_OUT="$HOME/Desktop/brave-tabs-$(date +%Y-%m-%d-%H%M).md"
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
  log "Wrote optional snapshot $DESKTOP_OUT"
  (( QUIET )) || open -R "$DESKTOP_OUT"
fi

if (( NO_STANDING )) || [[ -z "$STANDING" ]]; then
  if (( ! WANT_DESKTOP )); then
    die_usage "nothing to do: standing skipped and --desktop not set"
  fi
  log "Standing append skipped."
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
' "$STANDING" "$STAMP" | { (( QUIET )) && cat >/dev/null || cat; }

# Console Log Reports need a real .log under ~/Library/Logs (symlinks invisible).
# Lock A: regenerate projection from standing SSOT; do not move the home.
PROJECTOR="${SYSTEM_HOME:-$HOME/repos/system}/scripts/project-console-logs.sh"
if [[ -x "$PROJECTOR" ]]; then
  if (( QUIET )); then
    "$PROJECTOR" >/dev/null || print -r -- "Console projection failed (non-fatal): $PROJECTOR" >&2
  else
    "$PROJECTOR" || print -r -- "Console projection failed (non-fatal): $PROJECTOR" >&2
  fi
else
  print -r -- "Console projector missing: $PROJECTOR" >&2
fi
