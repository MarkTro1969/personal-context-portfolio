#!/bin/bash
# Auto-sync personal-context-portfolio to GitHub
# Runs daily via LaunchAgent — commits and pushes any local changes

REPO_DIR="$HOME/Projects/personal-context-portfolio"
LOG_FILE="$REPO_DIR/sync.log"

cd "$REPO_DIR" || exit 1

# Pull latest first (fast-forward only to avoid merge conflicts)
/usr/bin/git pull --ff-only origin main >> "$LOG_FILE" 2>&1

# Check for changes
if /usr/bin/git diff --quiet && /usr/bin/git diff --cached --quiet && [ -z "$(/usr/bin/git ls-files --others --exclude-standard)" ]; then
    echo "$(date): No changes to sync" >> "$LOG_FILE"
    exit 0
fi

# Stage, commit, push
/usr/bin/git add -A
/usr/bin/git commit -m "Auto-sync $(date +%Y-%m-%d)" >> "$LOG_FILE" 2>&1
/usr/bin/git push origin main >> "$LOG_FILE" 2>&1

echo "--- Sync completed at $(date) ---" >> "$LOG_FILE"
