# export-brave-tabs

Dump every open [Brave Browser](https://brave.com) tab (all windows) into the standing Kit-style log on `system/`, and project that file for Console.app.

## Requirements

- macOS
- Brave Browser running (Scripting works best when it is open)
- **Automation** permission: allow Terminal (or whatever runs the script) to control Brave Browser  
  System Settings → Privacy & Security → Automation

## Install

```bash
git clone https://github.com/marekkowalczyk/export-brave-tabs.git ~/repos/export-brave-tabs
ln -sfn ~/repos/export-brave-tabs/export-brave-tabs.sh ~/.local/bin/export-brave-tabs
```

Command name is `export-brave-tabs` (no `.sh`). `~/.local/bin` is on PATH via dotfiles `src/path.sh`.

## Usage

```bash
export-brave-tabs
export-brave-tabs --help
export-brave-tabs --version
# optional one-off snapshot (not the home):
export-brave-tabs --desktop
export-brave-tabs --desktop ~/Desktop/my-tabs.md
# snapshot only (no standing append):
export-brave-tabs --desktop --no-standing
export-brave-tabs -q   # quieter stdout
```

Default: append standing log only. No Desktop file. Finder reveal only when `--desktop` is set.

### Standing log (owner)

Home: `~/repos/system/pkm/brave-tabs.md`. Each run **appends** lines:

```text
YYYY-MM-DDTHH:MM W{n} | title | url
```

Timezone: Europe/Warsaw. Override path with `BRAVE_TABS_STANDING`. Set `BRAVE_TABS_STANDING=` empty or pass `--no-standing` to skip.

Commit/push of `system/` is not done by this script — Larry or the commit-push safeguard owns that.

## Notes

- Browser tabs only. Other app windows have no URL.
- Titles come from Brave; empty or odd titles are possible on `chrome://` / `brave://` pages.
- Do not keep dated Desktop dumps as a third copy. Standing markdown is SSOT; `~/Library/Logs/brave-tabs.log` is regenerable for Console.

## Console projection (Lock A, 2026-09-06)

Standing SSOT stays `system/pkm/brave-tabs.md` (git). After each standing append, `export-brave-tabs` runs `system/scripts/project-console-logs.sh`, which copies that file (and `owner-inbox/inbox.md`) to real files under `~/Library/Logs/*.log` for Console.app Log Reports. Symlinks are invisible in Console — do not use them. Logs may be purged; regenerate anytime with the projector. Do not move the home into Library/Logs.
