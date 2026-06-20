# 📁 ProjectsmacOS

A lightweight macOS file automation system that **automatically sorts files dropped into `~/Projects`** into categorized subfolders — no app, no GUI, just shell scripts and a background daemon.

> Tested on **macOS with Apple Silicon (M3)**. Compatible with any Mac running macOS 12 Monterey or later with Homebrew installed. See [compatibility notes](#compatibility) below.

---

## ✨ What it does

Drop any file into `~/Projects/` and it gets automatically moved to the right subfolder within 3 seconds:

```
~/Projects/
├── Coding/      → .py .js .ts .sh .go .swift .rb …
├── Web/         → .html .css .vue .svelte .jsx …
├── Notes/       → .md .txt .pages .rst …
├── Docs/        → .pdf .docx .pptx .xlsx .epub …
├── Design/      → .fig .sketch .xd .psd .ai …
├── Data/        → .csv .json .yaml .sql …
├── Media/       → .png .mp4 .svg .mp3 …
└── _inbox/      → anything that doesn't match a rule
```

You can also trigger a manual sort at any time with `projects-sort`, or preview what would happen with `projects-sort --dry-run`.

---

## 📦 What's included

| File | Role |
|------|------|
| `install.sh` | One-time setup: creates folders, installs scripts, registers the background daemon |
| `config.sh` | All classification rules — edit this to customize categories |
| `classify.sh` | Core logic: given a file path, moves it to the right folder |
| `watch.sh` | Background daemon: watches `~/Projects` with `fswatch` and calls `classify.sh` |
| `projects-sort.sh` | Manual sort command: processes all unsorted files at once |
| `icons/` | Custom `.icns` folder icons for each category (optional, see [Folder Icons](#-folder-icons)) |

---

## 🚀 Installation

### Prerequisites

- macOS 12 Monterey or later
- [Homebrew](https://brew.sh) installed (`fswatch` is installed automatically if missing)

### Steps

```bash
# 1. Clone or download this repo
git clone https://github.com/ProjectsmacOS-OFF/ProjectsmacOSDownload.git
cd ProjectsmacOSDownload/.projects-system

# 2. Run the installer
bash install.sh

# 3. Reload your shell
source ~/.zshrc
```

The installer will:
- Create `~/Projects/` and all category subfolders
- Copy scripts to `~/.projects-system/`
- Register a launchd daemon that starts automatically at login
- Add shell aliases to your `.zshrc`

> **Note:** If `fswatch` is not found, the installer runs `brew install fswatch` automatically.

---

## 🖥️ Terminal Commands

After installation, these aliases are available in your terminal:

```bash
projects                 # cd ~/Projects
projects-sort            # sort all unsorted files now
projects-sort --dry-run  # preview what would be moved (nothing is touched)
projects-watch-status    # check if the background daemon is running
projects-watch-start     # start the daemon
projects-watch-stop      # stop the daemon
```

Logs are written to:
```
~/Library/Logs/projects-classifier.log
~/Library/Logs/projects-classifier-error.log
```

---

## ⚙️ Configuration

All rules live in `~/.projects-system/config.sh`. Open it to add or modify categories:

```bash
# Format: "CATEGORY|ext1,ext2,ext3"
# Rules are read top-to-bottom — first match wins.

"Arduino|ino,pde"
"Config|env,yaml,toml,ini,cfg"
```

After editing, no restart is needed for `projects-sort`. To apply changes to the daemon:

```bash
projects-watch-stop && projects-watch-start
```

---

## 🎨 Folder Icons

The `icons/` folder contains custom `.icns` files for each category. Applying them is optional but gives your `~/Projects` a polished look in Finder.

Don't start the script before modifying the icns folder because the script delete the new icns.

If you have activated the script before modifying the icns just desactivate and reactivate : 
```bash
projects-watch-stop && projects-watch-start
```
See [HowToUse.md](HowToUse.md) for the full step-by-step guide (Finder method + terminal method).

---

## 🖥️ Compatibility

| Configuration | Status | Notes |
|---|---|---|
| Apple Silicon M1/M2/M3 (macOS 12+) | ✅ Fully tested | Primary target |
| Intel Mac (macOS 12+) | ✅ Should work | Homebrew path may differ (`/usr/local/bin` instead of `/opt/homebrew/bin`) |
| macOS 11 Big Sur | ⚠️ Likely works | Not tested |
| macOS 10.15 Catalina or earlier | ❌ Not supported | `zsh` default shell required |
| Linux | ❌ Not supported | `launchd` is macOS-only; `inotifywait` would be needed instead |

**Intel Mac users:** If `fswatch` is not found by the daemon, add this line to your plist manually:
```xml
<key>EnvironmentVariables</key>
<dict>
  <key>PATH</key>
  <string>/usr/local/bin:/usr/bin:/bin</string>
</dict>
```

---

## 🗑️ Uninstall

```bash
# Stop and remove the daemon
launchctl unload ~/Library/LaunchAgents/com.user.projects-classifier.plist
rm ~/Library/LaunchAgents/com.user.projects-classifier.plist

# Remove scripts
rm -rf ~/.projects-system

# Remove aliases — open ~/.zshrc and delete the "Projects system" block manually
```

Your `~/Projects/` folder and its contents are left untouched.

---

## 📄 License

MIT — do whatever you want with it.

# 📁 ProjectsmacOS Multi Folder

A lightweight macOS file automation system that **automatically sorts files from your system folders** (`~/Downloads`, `~/Desktop`, `~/Documents`, `~/Pictures`, `~/Movies`, `~/Music`) **into `~/Projects/`** — no app, no GUI, just shell scripts and a background daemon.

> Tested on **macOS with Apple Silicon (M3)**. Compatible with any Mac running macOS 12 Monterey or later with Homebrew installed. See [compatibility notes](#️-compatibility) below.

---

## ✨ What it does

Drop a file anywhere in your system folders and it gets automatically moved to the right subfolder inside `~/Projects/` within a few seconds:

```
~/Downloads/report.pdf      →  ~/Projects/Docs/report.pdf
~/Desktop/app.py            →  ~/Projects/Coding/app.py
~/Documents/mockup.fig      →  ~/Projects/Design/mockup.fig
~/Pictures/banner.png       →  ~/Projects/Media/banner.png
~/Movies/demo.mp4           →  ~/Projects/Media/demo.mp4
```

**Watched source folders** (root level only, not recursive):

| Source | What ends up there |
|---|---|
| `~/Downloads` | Everything you download |
| `~/Desktop` | Files you save or drag to the desktop |
| `~/Documents` | Files saved from apps like Pages, Word, etc. |
| `~/Pictures` | Images saved from apps |
| `~/Movies` | Videos exported or downloaded |
| `~/Music` | Audio files |

**Destination structure in `~/Projects/`:**

```
~/Projects/
├── Coding/      → .py .js .ts .sh .go .swift .rb …
├── Web/         → .html .css .vue .svelte .jsx …
├── Notes/       → .md .txt .pages .rst …
├── Docs/        → .pdf .docx .pptx .xlsx .epub …
├── Design/      → .fig .sketch .xd .psd .ai …
├── Data/        → .csv .json .yaml .sql …
├── Media/       → .png .mp4 .svg .mp3 …
└── _inbox/      → anything that doesn't match a rule
```

You can also trigger a manual sort at any time with `projects-sort`, preview with `projects-sort --dry-run`, or sort a single folder with `projects-sort ~/Downloads`.

---

## 📦 What's included

| File | Role |
|---|---|
| `installmf.sh` | One-time setup: creates folders, installs scripts, registers the daemon |
| `configmf.sh` | All classification rules and watched folders — edit to customize |
| `classify.sh` | Core logic: given a file path, moves it to the right folder in `~/Projects` |
| `watchmf.sh` | Background daemon: watches all source folders with `fswatch` |
| `projects-sortmf.sh` | Manual sort: processes all unsorted files in source folders at once |
| `icons/` | Custom `.icns` folder icons for each category (optional) |

---

## 🚀 Installation

### Prerequisites

- macOS 12 Monterey or later
- [Homebrew](https://brew.sh) installed (`fswatch` is installed automatically if missing)

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/ProjectsmacOS-OFF/ProjectsmacOSDownload.git
cd ProjectsmacOSDownload/.projects-system

# 2. Run the installer
bash installmf.sh

# 3. Reload your shell
source ~/.zshrc
```

The installer will:

- Create `~/Projects/` and all category subfolders
- Copy scripts to `~/.projects-system/`
- Register a launchd daemon that starts automatically at login
- Add shell aliases to your `.zshrc`
- Inject `PATH` into the plist so `fswatch` is always found (Intel + Apple Silicon)

> **Note:** If `fswatch` is not found, the installer runs `brew install fswatch` automatically.

---

## 🖥️ Terminal Commands

```bash
projects                          # cd ~/Projects
projects-sort                     # sort all source folders now
projects-sort --dry-run           # preview what would be moved (nothing is touched)
projects-sort ~/Downloads         # sort only one specific source folder
projects-watch-status             # check if the background daemon is running
projects-watch-start              # start the daemon
projects-watch-stop               # stop the daemon
```

Logs:

```
~/Library/Logs/projects-classifier.log
~/Library/Logs/projects-classifier-error.log
```

---

## ⚙️ Configuration

All rules and watched folders live in `~/.projects-system/configmf.sh`.

### Changing which folders are watched

```bash
export WATCH_DIRS=(
  "$HOME/Downloads"
  "$HOME/Desktop"
  "$HOME/Documents"
  "$HOME/Pictures"
  "$HOME/Movies"
  "$HOME/Music"
  # "$HOME/any/other/folder"   ← add your own
)
```

### Adding classification rules

```bash
# Format: "CATEGORY|ext1,ext2,ext3"
# Rules are read top-to-bottom — first match wins.

"Arduino|ino,pde"
"Config|env,yaml,toml,ini,cfg"
```

After editing config, restart the daemon to apply changes:

```bash
projects-watch-stop && projects-watch-start
```

---

## 🎨 Folder Icons

The `icons/` folder contains custom `.icns` files for each category. Applying them is optional but gives your `~/Projects` a polished look in Finder.

See [HowToUse.md](HowToUse.md) for the full step-by-step guide.

---

## 🖥️ Compatibility

| Configuration | Status | Notes |
|---|---|---|
| Apple Silicon M1/M2/M3 (macOS 12+) | ✅ Fully tested | Primary target |
| Intel Mac (macOS 12+) | ✅ Should work | PATH includes `/usr/local/bin` by default |
| macOS 11 Big Sur | ⚠️ Likely works | Not tested |
| macOS 10.15 or earlier | ❌ Not supported | `zsh` default shell required |
| Linux | ❌ Not supported | `launchd` is macOS-only |

---

## 🗑️ Uninstall

```bash
# Stop and remove the daemon
launchctl unload ~/Library/LaunchAgents/com.user.projects-classifier.plist
rm ~/Library/LaunchAgents/com.user.projects-classifier.plist

# Remove scripts
rm -rf ~/.projects-system

# Remove aliases (open ~/.zshrc and delete the "Projects Auto-Classifier" block)
```

Your `~/Projects/` folder and its contents are left untouched.

---

## 📄 License

MIT — do whatever you want with it.


## Discord Link 
https://discord.gg/UqQYbNjsN6

Thanks for view this page
