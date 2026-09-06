# export-brave-tabs

Dump every open [Brave Browser](https://brave.com) tab (all windows) into markdown, and append a Kit-style standing log on `system/` when that home exists.

## Requirements

- macOS
- Brave Browser running (Scripting works best when it is open)
- **Automation** permission: allow Terminal (or whatever runs the script) to control Brave Browser  
  System Settings → Privacy & Security → Automation

## Install

```bash
git clone https://github.com/marekkowalczyk/export-brave-tabs.git ~/repos/export-brave-tabs
ln -sf ~/repos/export-brave-tabs/export-brave-tabs.sh ~/bin/export-brave-tabs.sh
```

Ensure `~/bin` is on your `PATH`.

## Usage

```bash
export-brave-tabs.sh
# optional Desktop path:
export-brave-tabs.sh ~/Desktop/my-tabs.md
# Desktop only (no standing append):
export-brave-tabs.sh --no-standing
```

Default Desktop output: `~/Desktop/brave-tabs-YYYY-MM-DD-HHMM.md`. Finder reveals the file when done.

### Standing log (owner)

When `~/repos/system/pkm/brave-tabs.md` exists (or is creatable), each run **appends** lines:

```text
YYYY-MM-DDTHH:MM W{n} | title | url
```

Timezone: Europe/Warsaw. Override path with `BRAVE_TABS_STANDING`. Set `BRAVE_TABS_STANDING=` empty or pass `--no-standing` to skip.

Commit/push of `system/` is not done by this script — Larry or the commit-push safeguard owns that.

## Notes

- Browser tabs only. Other app windows have no URL.
- Titles come from Brave; empty or odd titles are possible on `chrome://` / `brave://` pages.

## Console projection (Lock A, 2026-09-06)

Standing SSOT stays `system/pkm/brave-tabs.md` (git). After each standing append, `export-brave-tabs.sh` runs `system/scripts/project-console-logs.sh`, which copies that file (and `owner-inbox/inbox.md`) to real files under `~/Library/Logs/*.log` for Console.app Log Reports. Symlinks are invisible in Console — do not use them. Logs may be purged; regenerate anytime with the projector. Do not move the home into Library/Logs.
