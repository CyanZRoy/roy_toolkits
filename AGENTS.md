# Repository Agent Notes

This repository is a personal toolkit collection. Codex may perform normal git
operations for this repository when asked.

Git guidance:

- Local git commands such as `git status`, `git diff`, `git add`, `git commit`,
  `git log`, and `git branch` can be run directly.
- Networked git commands such as `git push`, `git pull`, `git fetch`,
  `git ls-remote`, and submodule operations may require escalation because the
  Codex sandbox has network access disabled by default.
- When escalation is required for git network commands, request the narrowest
  applicable persisted command prefix, for example `["git", "push"]`,
  `["git", "pull"]`, or `["git", "fetch"]`.
- Do not request broad full-network or full-access permissions just for git.
