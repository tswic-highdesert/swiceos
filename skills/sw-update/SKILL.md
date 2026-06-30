---
name: sw-update
description: Safely update the shared OS to the latest version. Use when the user asks to update the AI OS or check for updates.
---

# Update the OS

Run `tools/update.sh`. It does a fast-forward-only pull of `stable` and
relinks any new skills. It never produces a merge conflict because the user
never edits core. If it reports the core is dirty, tell the user to move their
changes into `local/` and try again.
