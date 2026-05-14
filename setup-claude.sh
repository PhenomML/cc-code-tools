#!/usr/bin/env bash
# setup-claude.sh — install or update cc-code-tools for Claude Code
#   - Manages the cc-code-tools section in ~/.claude/CLAUDE.md (sentinel-based, idempotent)
#   - Symlinks skills from skills/ into ~/.claude/commands/ (updates on git pull)
#   - With --project [dir]: add code-wiki permissions to .claude/settings.local.json
# Requires cc-tools. Safe to run multiple times.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SECTION="$SCRIPT_DIR/claude-md-section.md"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
BEGIN="<!-- cc-code-tools:begin -->"
END="<!-- cc-code-tools:end -->"

# ── Dependency check ──────────────────────────────────────────────────────────

if ! command -v cc-webfetch &>/dev/null; then
    echo "setup-claude: WARNING: cc-tools does not appear to be installed"
    echo "  cc-code-tools requires cc-tools — install it first:"
    echo "  https://github.com/PhenomML/cc-tools"
fi

# ── --project mode ────────────────────────────────────────────────────────────
# Usage: setup-claude.sh --project [dir]
# Adds code-wiki permissions to .claude/settings.local.json in the target directory.
# Run cc-tools setup-claude.sh --project first to get the base allowlist.

if [[ "${1:-}" == "--project" ]]; then
    PROJECT_DIR="${2:-$(pwd)}"
    mkdir -p "$PROJECT_DIR"
    PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
    SETTINGS_DIR="$PROJECT_DIR/.claude"
    SETTINGS_FILE="$SETTINGS_DIR/settings.local.json"
    mkdir -p "$SETTINGS_DIR"
    python3 - "$SETTINGS_FILE" << 'PYEOF'
import json, sys, pathlib

path = pathlib.Path(sys.argv[1])
standard = [
    "Bash(git log *)",
    "Bash(git diff *)",
    "Bash(git show *)",
    "Bash(git blame *)",
    "Bash(git grep *)",
    "Bash(gh issue view *)",
    "Bash(gh issue list *)",
    "Bash(gh pr view *)",
    "Bash(gh pr list *)",
    "Bash(find *)",
    "Bash(grep *)",
    "Bash(rg *)",
]

data = json.loads(path.read_text()) if path.exists() else {}
allow = data.setdefault("permissions", {}).setdefault("allow", [])
added = [e for e in standard if e not in allow]
allow.extend(added)
path.write_text(json.dumps(data, indent=2) + "\n")

if added:
    print(f"setup-claude: added {len(added)} entr{'y' if len(added)==1 else 'ies'} to {path}")
    for e in added:
        print(f"  + {e}")
else:
    print(f"setup-claude: {path} already up to date")
PYEOF
    exit 0
fi

# ── CLAUDE.md ────────────────────────────────────────────────────────────────

mkdir -p "$HOME/.claude"

if [[ ! -f "$CLAUDE_MD" ]]; then
    printf '# Claude Code Global Configuration\n\n' > "$CLAUDE_MD"
fi

if grep -qF "$BEGIN" "$CLAUDE_MD"; then
    CLAUDE_MD="$CLAUDE_MD" SECTION="$SECTION" python3 - <<'PYEOF'
import os, re, pathlib
path    = pathlib.Path(os.environ["CLAUDE_MD"])
section = pathlib.Path(os.environ["SECTION"]).read_text()
text    = path.read_text()
begin   = "<!-- cc-code-tools:begin -->"
end     = "<!-- cc-code-tools:end -->"
block   = begin + "\n" + section.strip() + "\n" + end
result  = re.sub(
    re.escape(begin) + r".*?" + re.escape(end),
    lambda m: block,
    text,
    flags=re.DOTALL,
)
path.write_text(result)
PYEOF
    echo "setup-claude: updated cc-code-tools section in $CLAUDE_MD"
else
    {
        printf '\n%s\n' "$BEGIN"
        cat "$SECTION"
        printf '%s\n' "$END"
    } >> "$CLAUDE_MD"
    echo "setup-claude: added cc-code-tools section to $CLAUDE_MD"
fi

# ── Skills ───────────────────────────────────────────────────────────────────

SKILLS_SRC="$SCRIPT_DIR/skills"
COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"

count=0
for skill in "$SKILLS_SRC"/*.md; do
    [[ -f "$skill" ]] || continue
    name="$(basename "$skill")"
    target="$COMMANDS_DIR/$name"
    if [[ -L "$target" ]]; then
        ln -sf "$skill" "$target"
    elif [[ -e "$target" ]]; then
        echo "setup-claude: skipping $name — exists and is not a symlink (user-created file?)"
        continue
    else
        ln -s "$skill" "$target"
    fi
    (( count++ )) || true
done
echo "setup-claude: $count skill(s) linked to $COMMANDS_DIR"
