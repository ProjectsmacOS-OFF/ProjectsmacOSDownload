#!/usr/bin/env bash
# =============================================================================
# projects-sort.sh — Trier manuellement tous les fichiers à la racine de ~/Projects
# Usage : projects-sort  (ou projects-sort --dry-run pour simuler)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

DRY_RUN=false
[ "$1" = "--dry-run" ] && DRY_RUN=true

CLASSIFY_DELAY=0   # Pas de délai en mode manuel
export CLASSIFY_DELAY

echo ""
if $DRY_RUN; then
  echo "╔══════════════════════════════════════════╗"
  echo "║  projects-sort — MODE SIMULATION (dry)   ║"
  echo "╚══════════════════════════════════════════╝"
else
  echo "╔══════════════════════════════════════════╗"
  echo "║  projects-sort — Tri en cours…           ║"
  echo "╚══════════════════════════════════════════╝"
fi
echo ""

COUNT=0
MOVED=0

# Lister uniquement les fichiers à la racine (pas dans les sous-dossiers)
while IFS= read -r -d $'\0' filepath; do
  [ -f "$filepath" ] || continue

  FILENAME="$(basename "$filepath")"
  EXT="${FILENAME##*.}"
  EXT="$(echo "$EXT" | tr '[:upper:]' '[:lower:]')"

  # Ignorer préfixes
  SKIP=false
  IFS=',' read -ra PRFX <<< "$IGNORE_PREFIXES"
  for p in "${PRFX[@]}"; do
    p="${p// /}"
    [ -z "$p" ] && continue
    [[ "$FILENAME" == "$p"* ]] && SKIP=true && break
  done
  $SKIP && continue

  # Ignorer extensions
  IFS=',' read -ra IGN <<< "$IGNORE_EXTENSIONS"
  for i in "${IGN[@]}"; do
    i="${i// /}"
    [ "$EXT" = "$i" ] && SKIP=true && break
  done
  $SKIP && continue

  COUNT=$((COUNT + 1))

  # Trouver la catégorie
  TARGET_CATEGORY=""
  for rule in "${CLASSIFY_RULES[@]}"; do
    IFS='|' read -ra PARTS <<< "$rule"
    CATEGORY="${PARTS[0]}"
    EXTENSIONS="${PARTS[1]:-}"
    IFS=',' read -ra EXTS <<< "$EXTENSIONS"
    for e in "${EXTS[@]}"; do
      e="${e// /}"
      if [ "$EXT" = "$e" ]; then
        TARGET_CATEGORY="$CATEGORY"
        break 2
      fi
    done
  done
  [ -z "$TARGET_CATEGORY" ] && TARGET_CATEGORY="_inbox"

  echo "  $FILENAME  →  $TARGET_CATEGORY/"
  MOVED=$((MOVED + 1))

  if ! $DRY_RUN; then
    DEST_DIR="$PROJECTS_DIR/$TARGET_CATEGORY"
    mkdir -p "$DEST_DIR"
    DEST_FILE="$DEST_DIR/$FILENAME"
    if [ -f "$DEST_FILE" ]; then
      BASE="${FILENAME%.*}"
      if [ "$BASE" = "$FILENAME" ]; then
        DEST_FILE="$DEST_DIR/${FILENAME}_$(date +%s)"
      else
        DEST_FILE="$DEST_DIR/${BASE}_$(date +%s).${EXT}"
      fi
    fi
    mv "$filepath" "$DEST_FILE"
  fi

done < <(find "$PROJECTS_DIR" -maxdepth 1 -type f -print0)

echo ""
if [ "$COUNT" -eq 0 ]; then
  echo "  Aucun fichier à trier dans ~/Projects"
elif $DRY_RUN; then
  echo "  $MOVED fichier(s) seraient déplacés. Lance sans --dry-run pour confirmer."
else
  echo "  ✅  $MOVED fichier(s) classé(s)."
fi
echo ""
