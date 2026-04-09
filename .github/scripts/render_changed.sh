#!/bin/bash
# .github/scripts/render_changed.sh
# Renders only .qmd files changed in the latest commit, then builds the full Quarto site.
# If _quarto.yml changed, forces a full re-render of all pages.
# Intended to be called from a GitHub Actions workflow.

set -euo pipefail

echo "==> Checking for _quarto.yml changes..."

if git diff --name-only HEAD~1 HEAD | grep -q '_quarto.yml'; then
  echo "_quarto.yml changed — forcing full site render."
  quarto render
  exit 0
fi

echo "==> Detecting changed .qmd files in the latest commit..."

CHANGED=$(git diff --name-only HEAD~1 HEAD -- '*.qmd')

if [ -z "$CHANGED" ]; then
  echo "No .qmd files changed. Skipping individual renders."
else
  echo "Changed files:"
  echo "$CHANGED"

  while IFS= read -r file; do
    if [ -f "$file" ]; then
      echo "==> Rendering: $file"
      quarto render "$file"
    else
      echo "==> Skipping (deleted or not found): $file"
    fi
  done <<< "$CHANGED"
fi

echo "==> Running full site render (project-level)..."
quarto render
