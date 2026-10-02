#!/usr/bin/env bash
# ProjectKit bootstrap -- instantiate or refresh the kit in a project directory.
#
# One command, from the project root (no clone of ProjectKit needed):
#   Claude Code: curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash -s -- claude
#   Cursor:      curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash -s -- cursor
#   Both:        curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash
#
# Or from a local kit / a repo created from the template:
#   bash scripts/bootstrap.sh [claude|cursor|both] [target-dir]
#
# Tools:
#   claude  .claude/skills/ (real folder) + CLAUDE.md -> AGENTS.md
#   cursor  .cursor/skills/ + .cursor/wiki-root (Cursor reads AGENTS.md natively)
#   both    .cursor/skills/ (SSOT) + CLAUDE.md + .claude/skills link (git-ignored)   [default]
#   all     + .gitattributes (*.sh LF, *.ps1 CRLF) so skill scripts run after a Windows checkout
#           + .gitignore <tool-dir>/brainstorm/ (visual-companion scratch sessions)
#
# Idempotent. Kit-owned skills are refreshed; AGENTS.md, the wiki and CLAUDE.md
# are created only when missing -- never overwritten.
set -euo pipefail

REPO_URL="https://github.com/Bathalum/ProjectKit.git"
RAW_PS="https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1"
RAW_SH="https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh"
IGNORE_COMMENT="# ProjectKit: local link to .cursor/skills (recreate with scripts/bootstrap)"
IGNORE_ENTRY=".claude/skills"
BRAINSTORM_COMMENT="# ProjectKit: brainstorm visual-companion sessions (mockups, server logs)"
GITATTR_COMMENT="# ProjectKit: keep skill scripts runnable on Windows checkouts"
GITATTR_LINES=("*.sh text eol=lf" "*.ps1 text eol=crlf")

TOOL="both"
case "${1:-}" in claude|cursor|both) TOOL="$1"; shift ;; esac
TARGET="$(cd "${1:-.}" && pwd)"

case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) WIN=1 ;; *) WIN=0 ;; esac

one_liners() {
  if [ "$1" = both ]; then
    printf -- '- PowerShell: `irm %s | iex`\n- bash: `curl -fsSL %s | bash`\n' "$RAW_PS" "$RAW_SH"
  else
    printf -- '- PowerShell: `& ([scriptblock]::Create((irm %s))) %s`\n- bash: `curl -fsSL %s | bash -s -- %s`\n' "$RAW_PS" "$1" "$RAW_SH" "$1"
  fi
}

# Append the lines missing from a text file (created if absent) under one
# comment; existing lines are kept. Prints the added lines, comma-separated.
add_missing_lines() {
  local file="$1" comment="$2" l
  shift 2
  local missing=()
  for l in "$@"; do
    { [ -f "$file" ] && tr -d '\r' < "$file" | grep -qxF -- "$l"; } || missing+=("$l")
  done
  [ "${#missing[@]}" -gt 0 ] || return 0
  if [ -s "$file" ] && [ -n "$(tail -c1 "$file")" ]; then echo >> "$file"; fi
  { echo "$comment"; printf '%s\n' "${missing[@]}"; } >> "$file"
  (IFS=,; echo "${missing[*]}")
}

# Remove a directory link (symlink or junction) without touching its target.
remove_dir_link() {
  if [ "$WIN" = 1 ]; then
    MSYS2_ARG_CONV_EXCL='*' cmd /c rmdir "$(cygpath -w "$TARGET/$1")" >/dev/null
  else
    rm "$1"
  fi
}

# Kit source: the kit this script lives in, else a fresh shallow clone.
SRC=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  [ -f "$here/Constitution/AGENTS.md" ] && SRC="$here"
fi
if [ -z "$SRC" ]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  git clone -q --depth 1 "$REPO_URL" "$TMP/ProjectKit"
  SRC="$TMP/ProjectKit"
fi

cd "$TARGET"
echo "ProjectKit ($TOOL) -> $TARGET"

# 1. Skills: kit owns them -- refresh (extra project-local skills are kept).
if [ "$TOOL" = claude ]; then SKILLS=".claude/skills"; else SKILLS=".cursor/skills"; fi
if [ "$TOOL" = claude ] && [ -L .claude/skills ]; then
  remove_dir_link .claude/skills
  echo "  link        removed (.claude/skills is now a real folder)"
fi
if [ "$SRC/.cursor/skills" != "$TARGET/$SKILLS" ]; then
  mkdir -p "$SKILLS"
  cp -R "$SRC/.cursor/skills/." "$SKILLS/"
  echo "  skills      refreshed ($SKILLS)"
fi
if [ "$TOOL" != claude ] && [ ! -e .cursor/wiki-root ]; then
  cp "$SRC/.cursor/wiki-root" .cursor/wiki-root
fi

# 2. Law + wiki: project owns them -- add only what is missing.
WIKI_ROOT="docs"
for f in .cursor/wiki-root .claude/wiki-root; do
  [ -f "$f" ] || continue
  # First non-comment line, trimmed; Windows-style separators normalised to '/'.
  line="$(tr -d '\r' < "$f" | grep -v '^[[:space:]]*#' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' | head -n1 | tr '\\' '/' || true)"
  if [ -n "$line" ]; then WIKI_ROOT="${line%/}"; break; fi
done
WIKI_PARENT="$(dirname "$WIKI_ROOT")"
if [ "$WIKI_PARENT" = "." ]; then AGENTS_REL="AGENTS.md"; else AGENTS_REL="$WIKI_PARENT/AGENTS.md"; fi
mkdir -p "$WIKI_ROOT"   # monorepo: creates the package dir AGENTS.md lives in
if [ ! -e "$AGENTS_REL" ]; then
  cp "$SRC/Constitution/AGENTS.md" "$AGENTS_REL"
  echo "  law         created ($AGENTS_REL)"
fi
cp -Rn "$SRC/Constitution/docs/." "$WIKI_ROOT/" 2>/dev/null || true
echo "  wiki        missing stubs added ($WIKI_ROOT/)"

# 3. Claude Code bridge: CLAUDE.md thin pointer (AGENTS.md "Tool bridge").
if [ "$TOOL" != cursor ] && [ ! -e CLAUDE.md ]; then
  if [ "$TOOL" = claude ]; then
    note='Kit skills live in `.claude/skills/` (from ProjectKit). To refresh them or repair a missing piece, run from the repo root:'
  else
    note='Kit skills live in `.cursor/skills/` (SSOT). `.claude/skills` is a local link to it and is git-ignored.
If `.claude/skills` is missing (fresh clone), run from the repo root:'
  fi
  {
    printf '# CLAUDE.md\n\nThin pointer -- the law lives in [`%s`](./%s) (SSOT). Do not fork rules here.\n\n@%s\n\n## Skills\n\n%s\n\n' \
      "$AGENTS_REL" "$AGENTS_REL" "$AGENTS_REL" "$note"
    one_liners "$TOOL"
  } > CLAUDE.md
  echo "  claude      created (CLAUDE.md -> AGENTS.md)"
fi

# 4. both: .claude/skills -> .cursor/skills (link, not a copy), git-ignored.
if [ "$TOOL" = both ]; then
  if [ -L .claude/skills ]; then
    echo "  link        ok (.claude/skills)"
  elif [ -e .claude/skills ]; then
    echo "  WARNING: .claude/skills is a real folder -- left alone. Move its skills into .cursor/skills and re-run." >&2
  else
    mkdir -p .claude
    if [ "$WIN" = 1 ]; then
      # Git Bash 'ln -s' silently copies; use native links. Junction needs no admin.
      wlink="$(cygpath -w "$TARGET/.claude/skills")"
      wtarget="$(cygpath -w "$TARGET/.cursor/skills")"
      MSYS2_ARG_CONV_EXCL='*' cmd /c mklink /D "$wlink" '..\.cursor\skills' >/dev/null 2>&1 \
        || MSYS2_ARG_CONV_EXCL='*' cmd /c mklink /J "$wlink" "$wtarget" >/dev/null
    else
      ln -s ../.cursor/skills .claude/skills
    fi
    echo "  link        created (.claude/skills -> .cursor/skills)"
  fi

  # git on Windows checks symlinks out as text files -- keep the link per-machine.
  added="$(add_missing_lines .gitignore "$IGNORE_COMMENT" "$IGNORE_ENTRY")"
  if [ -n "$added" ]; then echo "  gitignore   added $added"; fi
elif [ "$TOOL" = claude ] && [ -f .gitignore ] && tr -d '\r' < .gitignore | grep -qxF "$IGNORE_ENTRY"; then
  # Real skills folder now -- it must not stay git-ignored.
  tr -d '\r' < .gitignore | grep -vxF -e "$IGNORE_ENTRY" -e "$IGNORE_COMMENT" > .gitignore.tmp || true
  if [ -s .gitignore.tmp ]; then mv .gitignore.tmp .gitignore; else rm -f .gitignore.tmp .gitignore; fi
  echo "  gitignore   removed .claude/skills"
fi

# 5. Brainstorm sessions (mockups, server logs) are scratch -- keep them out of git.
case "$TOOL" in
  claude) BS_DIRS=(".claude/brainstorm/") ;;
  cursor) BS_DIRS=(".cursor/brainstorm/") ;;
  *)      BS_DIRS=(".cursor/brainstorm/" ".claude/brainstorm/") ;;
esac
added="$(add_missing_lines .gitignore "$BRAINSTORM_COMMENT" "${BS_DIRS[@]}")"
if [ -n "$added" ]; then echo "  gitignore   added $added"; fi

# 6. Line endings: skill .sh scripts break in bash if a Windows checkout makes them CRLF.
added="$(add_missing_lines .gitattributes "$GITATTR_COMMENT" "${GITATTR_LINES[@]}")"
if [ -n "$added" ]; then echo "  gitattrib   added $added"; fi

# 7. Leftovers from the other tool are reported, never deleted.
if [ "$TOOL" = claude ] && [ -e .cursor ]; then
  echo "  note        .cursor/ exists -- delete it if this project does not use Cursor"
fi
if [ "$TOOL" = cursor ] && { [ -e CLAUDE.md ] || [ -e .claude/skills ]; }; then
  echo "  note        CLAUDE.md / .claude/skills exist -- delete them if this project does not use Claude Code"
fi

echo "Done."
