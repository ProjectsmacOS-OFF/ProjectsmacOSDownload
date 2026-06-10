#!/usr/bin/env bash
# =============================================================================
# config.sh — Configuration des catégories du système ~/Projects
# Modifie ce fichier pour personnaliser ton classement.
# =============================================================================

# Dossier racine (ne pas modifier sauf si tu l'as déplacé)
export PROJECTS_DIR="$HOME/Projects"

# Dossier de réception quand aucune catégorie ne correspond
export INBOX_DIR="$PROJECTS_DIR/_inbox"

# ── Règles de classification ──────────────────────────────────────────────
# Format : "CATEGORIE|ext1,ext2,ext3|mot-clé-dans-le-nom-optionnel"
# La catégorie est le NOM du sous-dossier dans ~/Projects.
# Les extensions sont en minuscules, sans le point.
# Le mot-clé est optionnel : s'il est présent, il est cherché dans le nom du fichier.
#
# Priorité : les règles du HAUT passent AVANT celles du bas.
# =============================================================================

export CLASSIFY_RULES=(

  # ── Code & Scripts ────────────────────────────────────────────────────────
  "Coding|py,js,ts,jsx,tsx,mjs,cjs,rb,go,rs,java,kt,swift,c,cpp,h,hpp,cs,php,lua,r,m,pl,sh,bash,zsh,fish,ps1,psm1"

  # ── Web ───────────────────────────────────────────────────────────────────
  "Web|html,htm,css,scss,sass,less,vue,svelte,astro,xml,xhtml,wasm"

  # ── Data & Bases ──────────────────────────────────────────────────────────
  "Data|csv,tsv,json,jsonl,yaml,yml,toml,sql,db,sqlite,sqlite3,parquet,arrow,ndjson"

  # ── Notes & Écriture ──────────────────────────────────────────────────────
  "Notes|md,markdown,txt,rst,org,tex,latex,rtf,pages"

  # ── Documents & Présentations ─────────────────────────────────────────────
  "Docs|pdf,docx,doc,odt,xlsx,xls,ods,pptx,ppt,odp,epub,numbers,keynote"

  # ── Design & Maquettes ────────────────────────────────────────────────────
  "Design|fig,sketch,xd,ai,psd,indd,afdesign,afpub,afphoto,studio"

  # ── Médias ───────────────────────────────────────────────────────────────
  "Media|png,jpg,jpeg,gif,webp,svg,ico,bmp,tiff,tif,mp4,mov,avi,mkv,webm,mp3,wav,flac,aac,ogg,m4a"

  # ── Config & Outils ───────────────────────────────────────────────────────
  "Coding|env,gitignore,dockerignore,editorconfig,eslintrc,prettierrc,babelrc,webpack,vite,tsconfig,jsconfig,makefile,dockerfile,vagrantfile,procfile"

  # ── Archives ──────────────────────────────────────────────────────────────
  "Docs|zip,tar,gz,bz2,xz,7z,rar"

)

# ── Fichiers à IGNORER (jamais classés) ───────────────────────────────────
# Extensions système ou temporaires
export IGNORE_EXTENSIONS="ds_store,localized,swp,swo,tmp,temp,bak,log,cache"

# Préfixes de noms à ignorer (fichiers cachés et temporaires)
export IGNORE_PREFIXES=".,.~,~"

# ── Délai avant de classifier (secondes) ──────────────────────────────────
# Évite de classifier un fichier encore en cours d'écriture
export CLASSIFY_DELAY=3

# ── Activer le log détaillé ───────────────────────────────────────────────
# true = log chaque fichier classé  |  false = silencieux
export VERBOSE_LOG=true
