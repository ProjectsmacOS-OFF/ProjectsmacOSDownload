#!/usr/bin/env bash
# =============================================================================
# install.sh — Installation du système ~/Projects
# Usage : bash install.sh
# =============================================================================

set -e

PROJECTS_DIR="$HOME/Projects"
SCRIPTS_DIR="$HOME/.projects-system"
PLIST_PATH="$HOME/Library/LaunchAgents/com.user.projects-classifier.plist"
SHELL_RC=""

echo ""
echo "╔══════════════════════════════════════╗"
echo "║    Installation ~/Projects System    ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 1. Dépendance : fswatch ────────────────────────────────────────────────
if ! command -v fswatch &>/dev/null; then
  echo "→ Installation de fswatch via Homebrew..."
  if ! command -v brew &>/dev/null; then
    echo "✗ Homebrew introuvable. Installe-le depuis https://brew.sh puis relance ce script."
    exit 1
  fi
  brew install fswatch
fi
echo "✓ fswatch disponible : $(fswatch --version 2>&1 | head -1)"

# ── 2. Dossier ~/Projects + sous-dossiers ────────────────────────────────
echo ""
echo "→ Création de ~/Projects et ses catégories..."
mkdir -p "$PROJECTS_DIR"/{Coding,Web,Notes,Design,Data,Docs,Media,_inbox}

# Créer le fichier .localized pour que macOS puisse l'afficher joliment
touch "$PROJECTS_DIR/.localized"

echo "✓ Structure créée :"
ls "$PROJECTS_DIR"

# ── 3. Dossier des scripts internes ───────────────────────────────────────
mkdir -p "$SCRIPTS_DIR"

# ── 4. Copier les scripts principaux ──────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/classify.sh"      "$SCRIPTS_DIR/classify.sh"
cp "$SCRIPT_DIR/watch.sh"         "$SCRIPTS_DIR/watch.sh"
cp "$SCRIPT_DIR/config.sh"        "$SCRIPTS_DIR/config.sh"
cp "$SCRIPT_DIR/projects-sort.sh" "$SCRIPTS_DIR/projects-sort.sh"
chmod +x "$SCRIPTS_DIR/"*.sh
echo ""
echo "✓ Scripts installés dans $SCRIPTS_DIR"

# ── 5. Alias terminal ─────────────────────────────────────────────────────
# Détecter zsh ou bash
if [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
  SHELL_RC="$HOME/.bash_profile"
fi

ALIAS_BLOCK='
# ── Projects system ───────────────────────────────────────────────────────
alias projects="cd ~/Projects"
alias projects-sort="~/.projects-system/projects-sort.sh"
alias projects-watch-status="launchctl list | grep projects-classifier"
alias projects-watch-start="launchctl load ~/Library/LaunchAgents/com.user.projects-classifier.plist"
alias projects-watch-stop="launchctl unload ~/Library/LaunchAgents/com.user.projects-classifier.plist"
# ─────────────────────────────────────────────────────────────────────────'

if [ -n "$SHELL_RC" ]; then
  if ! grep -q "Projects system" "$SHELL_RC"; then
    echo "$ALIAS_BLOCK" >> "$SHELL_RC"
    echo "✓ Alias ajoutés dans $SHELL_RC"
  else
    echo "✓ Alias déjà présents dans $SHELL_RC"
  fi
else
  echo "⚠ Impossible de détecter ton shell config. Ajoute manuellement :"
  echo "$ALIAS_BLOCK"
fi

# ── 6. LaunchAgent (daemon) ───────────────────────────────────────────────
cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.user.projects-classifier</string>

  <key>ProgramArguments</key>
  <array>
    <string>$SCRIPTS_DIR/watch.sh</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <true/>

  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/projects-classifier.log</string>

  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/projects-classifier-error.log</string>

  <key>ThrottleInterval</key>
  <integer>2</integer>
</dict>
</plist>
PLIST

echo ""
echo "✓ LaunchAgent créé : $PLIST_PATH"

# ── 7. Lancer le daemon ───────────────────────────────────────────────────
# Décharger si déjà chargé (pas d'erreur si absent)
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"
echo "✓ Daemon démarré"

# ── 8. Résumé ─────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✅  Installation terminée !                                 ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Commandes disponibles (après 'source $SHELL_RC') :         ║"
echo "║                                                              ║"
echo "║  projects              → cd ~/Projects                       ║"
echo "║  projects-sort         → trier manuellement                  ║"
echo "║  projects-watch-status → état du daemon                      ║"
echo "║  projects-watch-start  → démarrer le daemon                  ║"
echo "║  projects-watch-stop   → arrêter le daemon                   ║"
echo "║                                                              ║"
echo "║  Config : ~/.projects-system/config.sh                       ║"
echo "║  Logs   : ~/Library/Logs/projects-classifier.log             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "→ Lance : source $SHELL_RC"
echo ""
