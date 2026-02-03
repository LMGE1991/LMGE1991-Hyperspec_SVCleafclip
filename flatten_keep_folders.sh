#!/usr/bin/env bash
set -euo pipefail

# Flatten a directory tree into one folder BUT keep folder names in the filename.
# Default: copy. Use --move to move.
#
# Example:
#   SRC/Trial1/Plot07/CameraA/img001.tif
# becomes:
#   DST/Trial1__Plot07__CameraA__img001.tif
#
# Usage:
#   ./flatten_keep_folders.sh -s "/path/src" -d "/path/dst" --delim "__" --dry-run
#   ./flatten_keep_folders.sh -s "/path/src" -d "/path/dst" --delim "__"        (copy)
#   ./flatten_keep_folders.sh -s "/path/src" -d "/path/dst" --delim "__" --move (move)

# Default parameters. Here DELIM is double underscore, but you can change it.
SRC=""
DST=""
DELIM="__"
MODE="copy"
DRYRUN=0

# die is a function to print an error message and exit if something goes wrong.
die() { echo "ERROR: $*" >&2; exit 1; }

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--src) SRC="${2:-}"; shift 2;;
    -d|--dst) DST="${2:-}"; shift 2;;
    --delim)  DELIM="${2:-}"; shift 2;;
    --move)   MODE="move"; shift;;
    --copy)   MODE="copy"; shift;;
    --dry-run) DRYRUN=1; shift;;
    -h|--help)
      cat <<EOF
Usage:
  $(basename "$0") -s <src_root> -d <dst_dir> [--delim "__"] [--move|--copy] [--dry-run]
EOF
      exit 0
      ;;
    *) die "Unknown argument: $1";;
  esac
done

# Validate arguments
[[ -n "$SRC" ]] || die "Missing --src"
[[ -n "$DST" ]] || die "Missing --dst"

# Resolve to absolute paths
SRC="$(cd "$SRC" && pwd)"
mkdir -p "$DST"
DST="$(cd "$DST" && pwd)"

# Check that source and destination are directories
[[ -d "$SRC" ]] || die "Source is not a directory: $SRC"
[[ -d "$DST" ]] || die "Destination is not a directory: $DST"

# Turn "A/B/C" into "A__B__C"
dir_to_prefix() {
  local rel_dir="$1"
  rel_dir="${rel_dir#./}"
  [[ -z "$rel_dir" || "$rel_dir" == "." ]] && { echo ""; return; }
  echo "${rel_dir//\//$DELIM}"
}

# Replace characters that are annoying in filenames (optional but useful).
# Keep this conservative; adjust if you want to preserve spaces, etc.
sanitise() {
  local s="$1"
  # Replace spaces with a single underscore; remove ':' (common on macOS metadata)
  s="${s// /_}"
  s="${s//:/-}"
  echo "$s"
}

# Transfer function: copy or move based on MODE
transfer() {
  local src="$1"
  local dst="$2"

  if (( DRYRUN )); then
    echo "[DRY] $MODE: $src -> $dst"
    return
  fi

  if [[ "$MODE" == "move" ]]; then
    mv -n "$src" "$dst"
  else
    cp -p "$src" "$dst"
  fi
}

# MAIN LOOP (safe for spaces/newlines)
while IFS= read -r -d '' f; do
  rel="${f#$SRC/}"
  rel_dir="$(dirname "$rel")"
  fname="$(basename "$rel")"

  prefix="$(dir_to_prefix "$rel_dir")"
  prefix="$(sanitise "$prefix")"
  clean_fname="$(sanitise "$fname")"

  if [[ -n "$prefix" ]]; then
    out_name="${prefix}${DELIM}${clean_fname}"
  else
    out_name="$clean_fname"
  fi

  out_path="$DST/$out_name"

  # Collision handling:
  # If out_path already exists, that means TWO different source files map to the same output name.
  # This is rare if we include the full relative folder path, but it can still happen if:
  # - you have identical relative paths under different mounts, or
  # - you run the script twice into the same DST, or
  # - your sanitise() collapses distinct names into the same name.
  #
  # Since you said you don't want numeric suffixes, we use a short hash fallback.
  if [[ -e "$out_path" ]]; then
    # Create a stable, short identifier from the full relative path.
    # macOS has shasum by default.
    short="$(printf "%s" "$rel" | shasum -a 256 | awk '{print substr($1,1,8)}')"
    out_path="$DST/${prefix}${DELIM}${short}${DELIM}${clean_fname}"
  fi

  transfer "$f" "$out_path"
done < <(find "$SRC" -type f -print0)

echo "Done. Output in: $DST"