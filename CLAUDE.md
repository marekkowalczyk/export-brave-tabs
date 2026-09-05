# CLAUDE.md — export-brave-tabs

## Purpose

One-job macOS helper: export open Brave Browser tabs to markdown `[title](url)` lists so the human can close tabs without losing them.

## Layout

- `export-brave-tabs.sh` — only executable; AppleScript via `osascript` talks to Brave
- `README.md` — install and use
- This file — agent/human contract for changes

## Constraints

- Stay a single shell script. No Node, no Swift app, no Homebrew formula unless the owner asks.
- Keep output format stable: markdown headings per window, then `- [title](url)` lines.
- Do not invent browser support for Chrome/Safari unless asked; clone the script if needed.
- Never commit Desktop dump files or personal tab lists.

## Permissions

macOS Automation must allow the runner to control Brave. If `osascript` hangs, that gate is usually the cause.

## Symlink

Canonical install for the owner: `~/bin/export-brave-tabs.sh` → this repo’s script. Prefer editing the repo file, not a duplicate in `~/bin`.
