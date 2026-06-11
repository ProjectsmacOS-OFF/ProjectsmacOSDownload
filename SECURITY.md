# Security Policy

## Scope

This project is a local macOS automation tool. It runs entirely on your machine — no network requests, no remote servers, no data collection. The attack surface is limited to:

- Shell scripts executed by your user account
- A launchd agent running under your session
- File system operations within `~/Projects/`

---

## Supported Versions

Only the latest version on the `main` branch receives security fixes.

| Version | Supported |
|---------|-----------|
| Latest (`main`) | ✅ |
| Older commits | ❌ |

---

## Potential Risk Areas

While the project is intentionally minimal, here are the areas worth being aware of:

**`watch.sh` / launchd daemon**
Runs continuously in the background as your user. It only watches `~/Projects/` and calls `classify.sh` — it does not open ports, make network requests, or run with elevated privileges.

**`classify.sh` / `projects-sort.sh`**
Move files on your local filesystem. They only operate on `~/Projects/` and only on files at the root level (never recurse into subfolders you've already organized).

**`config.sh`**
Sourced by every other script. If someone modifies this file maliciously, they could inject arbitrary shell commands. Treat it like any other shell script in your home directory — don't edit it with untrusted content, and don't let other users write to `~/.projects-system/`.

**`install.sh`**
Writes to `~/.projects-system/`, `~/.zshrc`, and `~/Library/LaunchAgents/`. Always inspect install scripts before running them:
```bash
cat install.sh   # read it first
bash install.sh  # then run it
```

---

## Reporting a Vulnerability

If you find a security issue (e.g. a path traversal bug, unsafe variable expansion, or privilege escalation via the plist), please report it privately rather than opening a public issue.

**How to report:**

1. Open a [GitHub Security Advisory](https://github.com/headypaint30-dotcom/ProjectsmacOSDownload/security/advisories/new) on this repository
2. Describe the vulnerability, the affected file(s), and steps to reproduce
3. If possible, suggest a fix or patch

I aim to respond within **7 days** and to release a fix within **30 days** for confirmed issues.

Please do not disclose the vulnerability publicly until a fix has been released.

---

## Out of Scope

The following are not considered security vulnerabilities for this project:

- A user with access to your Mac modifying files in `~/.projects-system/` — that's a local access control issue, not a bug in this tool
- The daemon moving a file you didn't want moved — that's a configuration issue, use `IGNORE_EXTENSIONS` or `IGNORE_PREFIXES` in `config.sh`
- Issues in `fswatch` or `fileicon` themselves — report those to their respective projects

---

## Best Practices When Using This Project

- Only run `install.sh` from a clone of this repository — never pipe it directly from the internet (`curl ... | bash`)
- Keep `~/.projects-system/` writable only by your user (`chmod 700 ~/.projects-system`)
- Review `config.sh` before adding third-party rules
- Check the daemon logs periodically: `tail -f ~/Library/Logs/projects-classifier.log`
