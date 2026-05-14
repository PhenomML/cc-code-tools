# cc-code-tools

Claude Code tools for research coders — orientation, navigation, and issue work in scientific and technical codebases.

**Requires [cc-tools](https://github.com/PhenomML/cc-tools).** Install cc-tools first.

## What it adds

`/wiki-codebase` — builds a persistent, navigable wiki for a code repository. For scientific codebases it also ingests associated papers via `cc-arxiv` and writes a paper–code correspondence page tracking where the math meets the implementation.

## Install

```bash
git clone git@github.com:PhenomML/cc-code-tools.git ~/Projects/PhenomML/cc-code-tools
bash ~/Projects/PhenomML/cc-code-tools/setup-claude.sh
```

To add code-wiki permissions to a specific project (run after cc-tools `--project`):

```bash
bash ~/Projects/PhenomML/cc-code-tools/setup-claude.sh --project /path/to/project/wiki
```

## Update

```bash
git pull && bash ~/Projects/PhenomML/cc-code-tools/setup-claude.sh
```

## Usage

Run from inside a `wiki/` directory that lives within the code repo:

```bash
mkdir myrepo/wiki && cd myrepo/wiki
/wiki-codebase          # build wiki only
/wiki-codebase 42       # build wiki, then work issue #42
```
