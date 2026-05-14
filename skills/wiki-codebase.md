Analyze a codebase and work on issues: $ARGUMENTS

`$ARGUMENTS` is an optional GitHub issue number, feature request, or goal. If omitted,
the skill builds the wiki only and stops at the end of Step 4b.

Run from inside `wiki/`. The code repo is at `../`.

## Navigation

The wiki sits inside the code repo. All code reads, edits, git operations, and test
runs use `../` paths. Verify location before every shell command.

```bash
pwd        # confirm you are in wiki/
ls ../     # confirm repo root contents before any code work
```

## Step 1 — Survey the repo

Save a filtered directory tree to `raw/`:

```bash
find .. -not -path '*/.git/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/vendor/*' \
        -not -path '*/.venv/*' \
        -not -path '*/target/*' \
        -not -path '*/__pycache__/*' \
        -not -path '*/build/*' \
        -not -path '*/dist/*' \
    > raw/directory-tree-<YYYY-MM-DD>.md
```

Detect the tech stack by reading key files if present:

| File | Indicates |
|---|---|
| `Gemfile` | Ruby / Rails |
| `package.json` | Node.js / React / TypeScript |
| `go.mod` | Go |
| `pyproject.toml` / `requirements.txt` | Python |
| `Cargo.toml` | Rust |
| `pom.xml` / `build.gradle` | Java / Kotlin |
| `mix.exs` | Elixir |

Read one or two entry-point files (e.g. `config/routes.rb`, `main.go`, `src/index.ts`)
to confirm the architecture before proposing sub-wikis.

Check for Jupyter notebooks and paper citations at survey time — both shape the
sub-wiki structure for scientific repos:

```bash
find .. -name "*.ipynb" -not -path '*/.ipynb_checkpoints/*' 2>/dev/null
grep -r "arxiv\|doi\.org\|arXiv" ../README.md ../CITATION.cff ../pyproject.toml \
    ../docs/ 2>/dev/null | head -20
```

## Step 2 — Determine sub-wiki structure

Propose sub-wikis that map to the code's natural domain boundaries. Starting points:

| Stack | Default sub-wikis |
|---|---|
| Rails | `architecture/`, `backend/`, `frontend/`, `api/`, `infrastructure/` |
| Python service | `architecture/`, `core/`, `api/`, `data/`, `workers/` |
| Go service | `architecture/`, `core/`, `api/`, `storage/` |
| Node / React | `architecture/`, `frontend/`, `backend/`, `api/` |
| Scientific Python | `architecture/`, `core/`, `experiments/`, `data/` |
| Generic | `architecture/`, `core/`, `api/`, `data/` |

Add sub-wikis freely when the codebase warrants it (e.g. `federation/` for ActivityPub,
`ml/` for model serving). Drop defaults that have no corresponding code.

If associated papers were found in Step 1, add a `papers/` sub-wiki to hold ingested
summaries and the paper-code correspondence page.

If the stack and structure are unambiguous, proceed without stopping to confirm.
Otherwise confirm with the researcher before scaffolding.

## Step 3 — Scaffold wiki

Write `CLAUDE.md` with three sections:

**Purpose:**
```markdown
# <Repo Name> Codebase Wiki

## Purpose

**Subject:** <Repo name> (codebase)
**Created:** <YYYY-MM-DD>
**Goal:** <driving goal or issue from $ARGUMENTS, or "initial codebase orientation">
```

**Sub-wikis table** (one row per sub-wiki, scope and related fields).

**Managed section:** insert current `~/Projects/PhenomML/cc-tools/templates/wiki-schema.md`
wrapped in sentinels:
```
<!-- cc-tools:wiki:begin -->
[wiki-schema.md content]
<!-- cc-tools:wiki:end -->
```

Create for each sub-wiki: the directory and `<dir>/index.md`.

Create at the wiki root if not present: `.gitignore` containing `raw/`, `log.md`.

Run:
```bash
bash ~/Projects/PhenomML/cc-tools/setup-claude.sh --project .
bash ~/Projects/PhenomML/cc-code-tools/setup-claude.sh --project .
```

## Step 4 — Build initial concept pages

Write `architecture/concepts/system-overview.md` first — it is the anchor all other
pages cross-link to. Cover: component map, technology choices, request lifecycle,
and background job or real-time lifecycle if present.

For each remaining sub-wiki, identify the key structural files, save code snapshots
to `raw/` with date-stamped slugs, then write one concept page:

```bash
cat ../app/lib/feed_manager.rb > raw/feed-manager-<YYYY-MM-DD>.md
```

Concept page coverage by sub-wiki type:
- `backend/`: core models, services, workers, key data flows
- `frontend/`: SPA structure, state management, build system
- `api/`: endpoint groups, WebSocket streams, authentication
- `infrastructure/`: database schema, job queues, deployment topology
- `federation/`: protocol flow, inbox/outbox, delivery workers
- `core/`: primary algorithms, key data structures, mathematical operations
- `experiments/`: experiment harness, configuration, result storage

**Notebooks as documentation.** If the repo contains Jupyter notebooks that serve
as tutorials, method walkthroughs, or primary demonstrations (not scratch work),
convert and use as concept page source:

```bash
cc-nbconvert --to markdown ../notebooks/<name>.ipynb --stdout \
    > raw/notebook-<name>-<YYYY-MM-DD>.md
```

For executed notebooks, use `/notebook-narrate` to produce a research narrative
rather than writing a concept page manually.

Update each sub-wiki's `index.md` and append to `log.md`.

## Step 4b — Ingest associated papers

Scientific codebases implement or build on one or more papers. Locate all references:

```bash
grep -rE "arxiv\.org|doi\.org|arXiv:[0-9]" \
    ../README.md ../CITATION.cff ../pyproject.toml ../docs/ 2>/dev/null
```

For each paper found, fetch its metadata:

```bash
cc-arxiv <arxiv-id-or-doi>
```

Run `/wiki-ingest` for papers that are directly implemented by or foundational to
the codebase. Ingested summaries land in `papers/`.

Write `architecture/concepts/paper-code-correspondence.md`:

```markdown
# Paper–Code Correspondence

| Paper | Claim | Code location | Status |
|---|---|---|---|
| Author YYYY, §N | [claim from paper] | `src/module.py:line` | checked / assumed / unknown |
```

Populate with the primary algorithmic claims from each ingested paper. Status:
- **checked** — implementation was read and matches the claim
- **assumed** — correspondence not verified; code structure suggests alignment
- **unknown** — no direct mapping found yet

This page is the living record of where the math meets the code. Update it as
understanding deepens. Start sparse — a stub with status `unknown` is honest;
an empty file is not.

**If no issue or goal was provided in `$ARGUMENTS`, stop here and report.** The wiki
is the deliverable; offer to work an issue when the researcher is ready.

## Step 5 — Work on an issue

Fetch the issue:

```bash
gh issue view <number>
```

Read the full issue: description, reproduction steps, expected vs. actual behavior,
any linked code or prior comments.

Cross-reference with wiki concept pages and `paper-code-correspondence.md` to
identify the likely code location. Read the relevant files via `../` paths.
Implement the fix.

Run existing tests if available:

```bash
cd .. && <test command>    # e.g. bundle exec rspec, go test ./..., pytest
```

## Step 6 — Update wiki

After a fix, update any concept pages whose description is now stale. Update
`paper-code-correspondence.md` if the fix touches a claimed implementation.
Append to `log.md`:

```
## [YYYY-MM-DD] issue #<N> | <one-line summary>
Fix: <what changed>. Concept pages updated: <list or none>.
Correspondence updated: <list or none>.
```

## Step 7 — Report

List every wiki file created or modified. If an issue was worked: issue number, bug
summary, files changed in the codebase, test status. Flag any sub-wikis that warrant
deeper concept pages before the next session. Note any paper claims whose
correspondence status changed.
