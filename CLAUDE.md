# CLAUDE.md — export-brave-tabs

## Purpose

One-job macOS helper: export open Brave Browser tabs to a Desktop markdown snapshot, and append Kit-style lines to the owner standing log on `system/pkm/brave-tabs.md`.

## Layout

- `export-brave-tabs.sh` — only executable; AppleScript via `osascript` talks to Brave
- `README.md` — install and use
- This file — agent/human contract for changes

## Constraints

- Stay a single shell script (+ tiny inline python for standing append). No Node, no Swift app, no Homebrew formula unless the owner asks.
- Desktop output format stays stable: markdown headings per window, then `- [title](url)` lines.
- Standing format stays stable: `YYYY-MM-DDTHH:MM W{n} | title | url` (Europe/Warsaw).
- Do not invent browser support for Chrome/Safari unless asked; clone the script if needed.
- Never commit Desktop dump files or paste personal tab lists into this public repo.
- Do not `git commit`/`push` `system/` from this script.

## Permissions

macOS Automation must allow the runner to control Brave. If `osascript` hangs, that gate is usually the cause.

## Symlink

Canonical install for the owner: `~/bin/export-brave-tabs.sh` → this repo’s script. Prefer editing the repo file, not a duplicate in `~/bin`.
