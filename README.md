# Norristown AI OS

This is a folder you open in Claude. It makes Claude work the Norristown way:
your skills, your specialists, your standards, and a few guardrails so nobody
shoots themselves in the foot.

## New here? Three things.

1. Open this folder in Claude and just ask for what you need in plain English.
   You do not need to know any commands. The OS routes you to the right tool.
2. Your own stuff goes in `local/`. The shared OS is everything else, and it
   updates itself. You never edit the shared parts.
3. If something is genuinely dangerous (a password, deleting work), the OS
   stops and tells you why. Loose where it is safe, firm where it is not.

## The three rings

- **core** (everything tracked in this repo): the shared OS. It flows DOWN to
  everyone automatically and you never edit it.
- **team/** (optional): shared inside your group, never shipped to everyone.
- **local/**: private to you. Never leaves your machine unless you choose to.

See `standards/core-vs-local.md` for the full contract.
