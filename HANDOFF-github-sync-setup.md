# Handoff: Personal Context Portfolio — GitHub Sync Setup

## Objective

Set up the Personal Context Portfolio as a private GitHub repository so it stays in sync between Mark's two machines (MacBook in Mooresville and Mac Mini in Southport via Tailscale SSH). Both machines run Claude Code and/or Cowork, and both need read/write access to the same set of context files. Updates made on either machine should automatically sync without manual intervention.

## What This Portfolio Is

A set of markdown files that provide AI tools (Claude Code, Cowork) with deep personal and professional context about Mark DiPietro, his businesses (SoundVision and Sound Decisions), leadership style, tools, domain knowledge, and active projects. These files are referenced by AI sessions to deliver relevant, accurate, personalized assistance.

## Current File List

All files are markdown (.md):

- identity.md — Who Mark is, leadership style, what he's known for
- role-and-responsibilities.md — Core responsibilities, meeting cadence, EOS structure, reporting
- current-projects.md — Active business and personal projects with status
- decision-log.md — Key decisions and reasoning
- preferences-and-constraints.md — Hard rules, time boundaries, budget rules, communication preferences, decision speed
- tools-and-systems.md — All business and personal tools/platforms in use
- domain-knowledge.md — Deep expertise areas (AV, security, finance, trading, AI, business management)
- communication-style.md — How Mark communicates and how AI should respond
- goals-and-priorities.md — Business and personal goals
- team-and-relationships.md — Key people, roles, and relationships
- HANDOFF.md — Original handoff document from portfolio creation

## IMPORTANT: The Files Already Exist

All the markdown files listed above are already written and finalized. They live in this folder — the same folder you are reading this handoff from. Do NOT create new files or templates. Use the existing .md files in this directory as the content for the repository.

## Steps to Complete

### 1. Find the Local Path of This Folder

This handoff is being read from a Cowork-mounted folder. Before doing anything, determine the actual macOS filesystem path of this folder. You can do this by checking the mount path or asking Mark. The folder is called "Personal Context Portfolio" and lives on the MacBook.

### 2. Create the Private GitHub Repository

Create a new private repository on Mark's GitHub account. Suggested name: `personal-context-portfolio`. No template, no README (we have our own files).

```bash
gh repo create personal-context-portfolio --private --description "Personal context files for AI tools (Claude Code, Cowork)" --confirm
```

### 3. Initialize Git in This Folder and Push

Navigate to this folder's actual macOS path and initialize it as a git repo. Add all the existing .md files and push.

```bash
cd /actual/path/to/Personal\ Context\ Portfolio  # USE THE REAL PATH — ask Mark if unsure
git init
git add *.md
git commit -m "Initial commit — Personal Context Portfolio"
git branch -M main
git remote add origin git@github.com:GITHUB_USERNAME/personal-context-portfolio.git
git push -u origin main
```

**Note:** Replace `GITHUB_USERNAME` with Mark's actual GitHub username. Do NOT use `git add .` — use `git add *.md` to avoid accidentally committing non-portfolio files.

### 4. Clone on the Mac Mini

SSH into the Mac Mini via Tailscale and clone the repo to a known location.

```bash
ssh mac-mini  # or whatever the Tailscale hostname is
cd ~  # or wherever Mark prefers to keep project repos
git clone git@github.com:GITHUB_USERNAME/personal-context-portfolio.git
```

### 5. Set Up Automatic Sync (Both Machines)

Create a shell script and a cron job on each machine that pulls changes, commits any local changes, and pushes — once per day.

**Create the sync script** (save as `~/scripts/sync-portfolio.sh` or similar on each machine):

```bash
#!/bin/bash
REPO_DIR="/path/to/personal-context-portfolio"  # Set correct path per machine

cd "$REPO_DIR" || exit 1

# Pull latest changes (rebase to keep history clean)
git pull --rebase origin main 2>/dev/null

# Check for local changes
if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -m "Auto-sync: $(hostname) — $(date '+%Y-%m-%d %H:%M')"
    git push origin main
fi
```

Make it executable:

```bash
chmod +x ~/scripts/sync-portfolio.sh
```

**Set up the cron job** (runs daily at 6:00 AM):

```bash
crontab -e
```

Add this line:

```
0 6 * * * /Users/USERNAME/scripts/sync-portfolio.sh >> /tmp/portfolio-sync.log 2>&1
```

Replace `/Users/USERNAME/` with the actual home directory path on each machine.

### 6. Configure Claude Code to Reference the Portfolio

On each machine, make sure Claude Code knows where to find these files. The simplest approach is to add a reference in the existing CLAUDE.md file (or the .claude/ directory if that's the structure in use).

**Option A — Add a pointer in CLAUDE.md:**

Add a section like:

```markdown
## Personal Context Portfolio
My personal context files are located at /path/to/personal-context-portfolio/
These files contain my identity, preferences, domain knowledge, active projects, and decision history.
When you need context about who I am, how I work, or what I'm working on, read the relevant file from that directory.
```

**Option B — Symlink into .claude/ directory:**

```bash
ln -s /path/to/personal-context-portfolio ~/.claude/personal-context
```

**Confirm which approach works best by checking how Claude Code currently loads context on the Mac Mini.** Look for a CLAUDE.md file or a .claude/ directory in the home directory or project roots.

### 7. Configure Cowork Access

When starting a Cowork session on the MacBook, mount the local clone of the repository as the working folder. This gives Cowork direct read/write access to all portfolio files.

## Conflict Handling

The daily sync script uses `git pull --rebase` which handles most cases cleanly. If both machines edit the same file on the same day (rare), git will flag a merge conflict. In that case, resolve manually or have Claude Code resolve it.

## Verification

After setup, confirm:

1. Both machines can `git pull` and `git push` without errors
2. A change made on the MacBook appears on the Mac Mini after sync (and vice versa)
3. Claude Code on both machines can read the portfolio files
4. Cowork can mount and access the portfolio folder on the MacBook
