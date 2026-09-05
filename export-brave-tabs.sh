#!/bin/zsh
set -euo pipefail
OUT="${1:-$HOME/Desktop/brave-tabs-$(date +%Y-%m-%d-%H%M).md}"
/usr/bin/osascript <<'APPLESCRIPT' > "$OUT"
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
echo "Wrote $OUT"
open -R "$OUT"
