# CLAUDE.md — export-brave-tabs

## Purpose

One-job macOS helper: export open Brave Browser tabs into the owner standing log on `system/pkm/brave-tabs.md`, then project that file for Console. Desktop markdown is optional (`--desktop`), not a third home.

## Layout

- `export-brave-tabs.sh` — only executable; AppleScript via `osascript` talks to Brave
- `README.md` — install and use
- This file — agent/human contract for changes

## Constraints

- Stay a single shell script (+ tiny inline python for standing append). No Node, no Swift app, no Homebrew formula unless the owner asks.
- Default path writes **no** Desktop file. Optional `--desktop` keeps the old markdown window/`- [title](url)` shape for a one-off snapshot.
- Standing format stays stable: `YYYY-MM-DDTHH:MM W{n} | title | url` (Europe/Warsaw).
- Do not invent browser support for Chrome/Safari unless asked; clone the script if needed.
- Never commit Desktop dump files or paste personal tab lists into this public repo.
- Do not `git commit`/`push` `system/` from this script.

## Permissions

macOS Automation must allow the runner to control Brave. If `osascript` hangs, that gate is usually the cause.

## Symlink

Canonical install for the owner: `~/bin/export-brave-tabs.sh` → this repo’s script. Prefer editing the repo file, not a duplicate in `~/bin`.

## Console projection (Lock A, 2026-09-06)

Standing SSOT stays `system/pkm/brave-tabs.md` (git). After each standing append, `export-brave-tabs.sh` runs `system/scripts/project-console-logs.sh`, which copies that file (and `owner-inbox/inbox.md`) to real files under `~/Library/Logs/*.log` for Console.app Log Reports. Symlinks are invisible in Console — do not use them. Logs may be purged; regenerate anytime with the projector. Do not move the home into Library/Logs.
