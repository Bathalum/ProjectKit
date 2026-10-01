#!/usr/bin/env bash
# ProjectKit bootstrap -- instantiate or refresh the kit in a project directory.
#
# One command, from the project root (no clone of ProjectKit needed):
#   curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash
#
# Or from a local kit / a repo created from the template:
#   bash scripts/bootstrap.sh [target-dir]
#
# Idempotent. Kit-owned skills are refreshed; AGENTS.md, the wiki and CLAUDE.md
# are created only when missing -- never overwritten.
set -euo pipefail

REPO_URL="https://github.com/Bathalum/ProjectKit.git"
ONE_LINER_PS='irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1 | iex'
ONE_LINER_SH='curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash'

TARGET="$(cd "${1:-.}" && pwd)"

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
echo "ProjectKit -> $TARGET"

# 1. Skills: kit owns them -- refresh (extra project-local skills are kept).
if [ "$SRC" != "$TARGET" ]; then
  mkdir -p .cursor/skills
  cp -R "$SRC/.cursor/skills/." .cursor/skills/
  [ -e .cursor/wiki-root ] || cp "$SRC/.cursor/wiki-root" .cursor/wiki-root
  echo "  skills      refreshed (.cursor/skills)"
fi

# 2. Law + wiki: project owns them -- add only what is missing.
WIKI_ROOT="docs"
if [ -f .cursor/wiki-root ]; then
  line="$(grep -v '^[[:space:]]*#' .cursor/wiki-root | grep -v '^[[:space:]]*$' | head -n1 | tr -d '\r' | xargs || true)"
  [ -n "$line" ] && WIKI_ROOT="${line%/}"
fi
WIKI_PARENT="$(dirname "$WIKI_ROOT")"
if [ "$WIKI_PARENT" = "." ]; then AGENTS_REL="AGENTS.md"; else AGENTS_REL="$WIKI_PARENT/AGENTS.md"; fi
if [ ! -e "$AGENTS_REL" ]; then
  cp "$SRC/Constitution/AGENTS.md" "$AGENTS_REL"
  echo "  law         created ($AGENTS_REL)"
fi
mkdir -p "$WIKI_ROOT"
cp -Rn "$SRC/Constitution/docs/." "$WIKI_ROOT/" 2>/dev/null || true
echo "  wiki        missing stubs added ($WIKI_ROOT/)"

# 3. Claude Code bridge: CLAUDE.md thin pointer (AGENTS.md "Tool bridge").
if [ ! -e CLAUDE.md ]; then
  cat > CLAUDE.md <<EOF
# CLAUDE.md

Thin pointer -- the law lives in [\`$AGENTS_REL\`](./$AGENTS_REL) (SSOT). Do not fork rules here.

@$AGENTS_REL

## Skills

Kit skills live in \`.cursor/skills/\` (SSOT). \`.claude/skills\` is a local link to it and is git-ignored.
If \`.claude/skills\` is missing (fresh clone), run from the repo root:

- PowerShell: \`$ONE_LINER_PS\`
- bash: \`$ONE_LINER_SH\`
EOF
  echo "  claude      created (CLAUDE.md -> AGENTS.md)"
fi

# 4. Claude Code bridge: .claude/skills -> .cursor/skills (link, not a copy).
if [ -L .claude/skills ]; then
  echo "  link        ok (.claude/skills)"
elif [ -e .claude/skills ]; then
  echo "  WARNING: .claude/skills is a real folder -- left alone. Move its skills into .cursor/skills and re-run." >&2
else
  mkdir -p .claude
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      # Git Bash 'ln -s' silently copies; use native links. Junction needs no admin.
      wlink="$(cygpath -w "$TARGET/.claude/skills")"
      wtarget="$(cygpath -w "$TARGET/.cursor/skills")"
      MSYS2_ARG_CONV_EXCL='*' cmd /c mklink /D "$wlink" '..\.cursor\skills' >/dev/null 2>&1 \
        || MSYS2_ARG_CONV_EXCL='*' cmd /c mklink /J "$wlink" "$wtarget" >/dev/null
      ;;
    *)
      ln -s ../.cursor/skills .claude/skills
      ;;
  esac
  echo "  link        created (.claude/skills -> .cursor/skills)"
fi

# 5. Keep the link out of git (git on Windows checks symlinks out as text files).
if ! { [ -f .gitignore ] && grep -qxF '.claude/skills' .gitignore; }; then
  if [ -s .gitignore ] && [ -n "$(tail -c1 .gitignore)" ]; then echo >> .gitignore; fi
  printf '# ProjectKit: local link to .cursor/skills (recreate with scripts/bootstrap)\n.claude/skills\n' >> .gitignore
  echo "  gitignore   added .claude/skills"
fi

echo "Done."
