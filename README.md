# export-brave-tabs

Dump every open [Brave Browser](https://brave.com) tab (all windows) into one markdown file as `- [title](url)` links, so you can close tabs without losing them.

## Requirements

- macOS
- Brave Browser running (or at least installed; Scripting works best when it is open)
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
# optional path:
export-brave-tabs.sh ~/Desktop/my-tabs.md
```

Default output: `~/Desktop/brave-tabs-YYYY-MM-DD-HHMM.md`. Finder reveals the file when done.

## Notes

- Browser tabs only. Other app windows have no URL.
- Titles come from Brave; empty or odd titles are possible on `chrome://` / `brave://` pages.
