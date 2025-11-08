#!/usr/bin/env bash
set -euo pipefail

# Minimal repo-secrets updater from .env (no auto-login)
# - Detects owner/repo from origin (ssh/https; strips .git)
# - Uses existing gh auth; exits if not logged in
# - For each KEY=VALUE in .env, sets secret named KEY (or KEY without trailing _VAL)

die(){ echo "ERROR: $*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "'git' not found"
command -v gh  >/dev/null 2>&1 || die "'gh' (GitHub CLI) not found. Install: https://cli.github.com/"

# 1) Detect repo (owner/name) from origin
remote_url="$(git remote get-url origin 2>/dev/null || true)"
[ -z "$remote_url" ] && die "No git remote found. Run inside a cloned repo."

if [[ "$remote_url" =~ ^git@[^:]+:([^/]+)/([^/]+)(\.git)?$ ]]; then
  REPO="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
elif [[ "$remote_url" =~ ^https?://[^/]+/([^/]+)/([^/]+)(\.git)?$ ]]; then
  REPO="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
else
  die "Unrecognized remote URL: $remote_url"
fi
REPO="${REPO%.git}"

echo "🔧 Target repo: $REPO"

# 2) Require existing gh auth (no prompts)
if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  die "gh not logged into github.com. Run: gh auth login --hostname github.com --web"
fi

# Optional: quick permission check (non-fatal if API reachable)
if ! gh repo view "$REPO" >/dev/null 2>&1; then
  die "Cannot access $REPO with current gh auth. Ensure you have WRITE/ADMIN on the repo."
fi

# 3) Ensure .env exists
[ -f ".env" ] || die ".env not found in current directory."

# 4) Process .env lines
success=0; skipped=0; total=0
while IFS= read -r line || [ -n "$line" ]; do
  # skip blanks/comments
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
  # only KEY=VALUE pairs
  [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || continue

  total=$((total+1))
  key="${line%%=*}"
  val="${line#*=}"

  # strip surrounding quotes if present
  val="${val%\"}"; val="${val#\"}"
  val="${val%\'}"; val="${val#\'}"

  # map KEY_VAL -> KEY (strip one trailing _VAL if present)
  secret="${key%_VAL}"

  if [[ -z "$val" ]]; then
    echo "⊘ Skipping $secret (empty value)"
    skipped=$((skipped+1))
    continue
  fi

  if gh secret set "$secret" --repo "$REPO" --body "$val" >/dev/null 2>&1; then
    echo "✓ Set secret: $secret"
    success=$((success+1))
  else
    die "Failed to set secret: $secret"
  fi
done < .env

echo "— Done —"
echo "  Total parsed: $total"
echo "  Updated:      $success"
echo "  Skipped:      $skipped"
echo "View secrets: https://github.com/$REPO/settings/secrets/actions"