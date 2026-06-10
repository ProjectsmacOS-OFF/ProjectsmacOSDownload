#!/usr/bin/env bash
# =============================================================================
# watch.sh — Daemon de surveillance de ~/Projects
# Lancé automatiquement par launchd au démarrage de session.
# Ne pas lancer manuellement sauf pour tester.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "[projects-watch] Démarré le $(date)"
echo "[projects-watch] Surveillance : $PROJECTS_DIR"

# fswatch surveille la racine ~/Projects (pas récursivement dans les sous-dossiers)
# --event Created  : nouveau fichier
# --event Renamed  : copié/déplacé dans le dossier
# -0               : séparer les chemins par \0 (safe pour les espaces)

fswatch \
  --event Created \
  --event Renamed \
  --event MovedTo \
  -0 \
  "$PROJECTS_DIR" \
  | while IFS= read -r -d $'\0' filepath; do

    # fswatch peut émettre des événements pour les dossiers aussi → on filtre
    [ -f "$filepath" ] || continue

    echo "[projects-watch] Événement : $filepath"

    # Classifier en arrière-plan (pour ne pas bloquer la surveillance)
    "$SCRIPT_DIR/classify.sh" "$filepath" &

  done
