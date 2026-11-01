#!/usr/bin/env bash
set -euo pipefail

# Script to export the Godot 4 project to Web (WASM/WebGL2) and deploy to GitHub Pages.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "=== Exporting LEGO Star Wars: A Vader's Peace for Web ==="
cd "${PROJECT_ROOT}"

GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
if [[ ! -x "${GODOT_BIN}" ]]; then
    if command -v godot >/dev/null 2>&1; then
        GODOT_BIN="godot"
    else
        echo "Error: Godot executable not found at ${GODOT_BIN} or on PATH."
        exit 1
    fi
fi

mkdir -p build/web
"${GODOT_BIN}" --headless --path . --export-release "Web" build/web/index.html

echo "=== Injecting coi-serviceworker and .nojekyll for GitHub Pages ==="
cp web_shell/coi-serviceworker.min.js build/web/
touch build/web/.nojekyll

echo "=== Deploying to gh-pages branch ==="
WORKTREE_DIR=$(mktemp -d /tmp/vader-gh-pages-XXXXXX)
git worktree add --detach "${WORKTREE_DIR}" origin/gh-pages 2>/dev/null || git worktree add --detach "${WORKTREE_DIR}"
pushd "${WORKTREE_DIR}" >/dev/null
git checkout -B gh-pages
git rm -rf . >/dev/null 2>&1 || true
rm -rf * .godot .gitignore 2>/dev/null || true
cp -r "${PROJECT_ROOT}/build/web/"* .
cp "${PROJECT_ROOT}/build/web/.nojekyll" .
git add -A
if git diff-index --quiet HEAD --; then
    echo "No changes to deploy to gh-pages."
else
    git commit -m "Deploy latest Web export with coi-serviceworker to GitHub Pages [$(date -u +'%Y-%m-%d %H:%M:%SZ')]"
    git push origin gh-pages
    echo "Pushed new build to origin/gh-pages successfully."
fi
popd >/dev/null

git worktree remove "${WORKTREE_DIR}" --force || true
rm -rf "${WORKTREE_DIR}"

echo ""
echo "=== Deployment Complete ==="
echo "Live URL: https://jedix420.github.io/vadersvibes/"
