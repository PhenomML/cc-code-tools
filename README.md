# cc-code-tools

Claude Code tools for research coders — orientation, navigation, and issue work in scientific and technical codebases.

Peer of [cc-tools](https://github.com/PhenomML/cc-tools), which it depends on. cc-tools is for anyone reading scientific papers; cc-code-tools is the additional layer for researchers working codebases.

## What it adds

`/wiki-codebase` — builds a persistent, navigable wiki for a code repository. For scientific codebases it also ingests associated papers via `cc-arxiv` and writes a paper–code correspondence page tracking where the math meets the implementation.

## Getting started

### One-time machine setup

**1. Install `uv`** (Claude's package manager, separate from conda):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.zshrc   # or restart your shell
```

**2. Install cc-tools:**

```bash
git clone git@github.com:PhenomML/cc-tools.git ~/Projects/PhenomML/cc-tools
uv tool install --editable ~/Projects/PhenomML/cc-tools
bash ~/Projects/PhenomML/cc-tools/setup-claude.sh
```

**3. Install cc-code-tools:**

```bash
git clone git@github.com:PhenomML/cc-code-tools.git ~/Projects/PhenomML/cc-code-tools
bash ~/Projects/PhenomML/cc-code-tools/setup-claude.sh
```

**4. Start a fresh Claude Code session** to pick up the updated `~/.claude/CLAUDE.md`.

Optional system packages (for PDFs and full cc-tools capability):

```bash
brew install pandoc poppler tesseract
brew install --cask mactex   # skip if MacTeX already installed
```

### Keeping both up to date

```bash
cd ~/Projects/PhenomML/cc-tools && git pull && bash setup-claude.sh
cd ~/Projects/PhenomML/cc-code-tools && git pull && bash setup-claude.sh
```

### Per-project usage

```bash
cd ~/Projects/myrepo
mkdir -p wiki
cc-wiki-brief "MyRepo" "driving question or goal" --brief-dir wiki
```

That launches Claude Code scoped to the wiki directory. Inside the session:

```bash
/wiki-codebase        # build wiki only
/wiki-codebase 42     # build wiki and work issue #42
```

The skill handles per-project permission setup in Step 3.

## Relationship to cc-tools

The `setup-claude.sh` scripts are independent but both must be run for a full install. cc-code-tools references cc-tools paths directly — this dependency is intentional and documented. Tracked in cc-tools [issue #18](https://github.com/PhenomML/cc-tools/issues/18).
