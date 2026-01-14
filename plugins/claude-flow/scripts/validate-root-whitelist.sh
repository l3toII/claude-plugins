#!/bin/bash
# validate-root-whitelist.sh - Enforce strict root whitelist
# This hook runs on PreToolUse for Bash(git commit:*) and Bash(git add:*)
# Exit 2 = blocking (parasite files found), Exit 0 = allowed (clean root)

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# =============================================================================
# WHITELIST: Only these files/folders are allowed at root
# =============================================================================
WHITELIST=(
    "apps"
    "project"
    "engineering"
    "docs"
    ".claude"
    ".git"
    ".gitignore"
    ".github"
    "CLAUDE.md"
    "README.md"
    "LICENSE"
    "Makefile"
    "package.json"
)

# =============================================================================
# FORBIDDEN: These files MUST NOT exist at root (explicit check)
# =============================================================================
FORBIDDEN_FILES=(
    # TypeScript/JavaScript config
    "tsconfig.json"
    "tsconfig.*.json"
    "jsconfig.json"

    # Linting/Formatting
    ".eslintrc"
    ".eslintrc.*"
    "eslint.config.*"
    ".prettierrc"
    ".prettierrc.*"
    "prettier.config.*"
    ".stylelintrc"
    ".stylelintrc.*"

    # Build tools
    "vite.config.*"
    "next.config.*"
    "nuxt.config.*"
    "svelte.config.*"
    "astro.config.*"
    "webpack.config.*"
    "rollup.config.*"
    "esbuild.config.*"
    "babel.config.*"
    ".babelrc"
    ".babelrc.*"

    # CSS tools
    "tailwind.config.*"
    "postcss.config.*"

    # Testing
    "jest.config.*"
    "vitest.config.*"
    ".mocharc.*"
    "cypress.config.*"
    "playwright.config.*"

    # Monorepo tools (use Makefile instead)
    "turbo.json"
    "nx.json"
    "lerna.json"
    "pnpm-workspace.yaml"
    "rush.json"

    # Docker/DevOps (must be in apps/devops/)
    "Dockerfile"
    "Dockerfile.*"
    "docker-compose.yml"
    "docker-compose.yaml"
    "docker-compose.*.yml"
    "docker-compose.*.yaml"
    ".dockerignore"

    # Environment files (must be in apps/devops/env/)
    ".env"
    ".env.local"
    ".env.development"
    ".env.production"
    ".env.test"
    ".env.staging"

    # Lock files (regenerable)
    "package-lock.json"
    "yarn.lock"
    "pnpm-lock.yaml"
    "bun.lockb"

    # Build artifacts (regenerable)
    "dist"
    "build"
    ".next"
    ".nuxt"
    ".svelte-kit"
    "out"

    # Dependencies (regenerable)
    "node_modules"
    ".pnpm-store"
    ".yarn"

    # Test artifacts
    "coverage"
    ".nyc_output"

    # Code directories (must be in apps/)
    "src"
    "lib"
    "components"
    "pages"
    "api"
    "server"
    "client"
    "public"
    "assets"
    "styles"

    # Code files at root
    "index.ts"
    "index.js"
    "index.tsx"
    "index.jsx"
    "main.ts"
    "main.js"
    "app.ts"
    "app.js"
)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

is_whitelisted() {
    local item="$1"
    for allowed in "${WHITELIST[@]}"; do
        if [[ "$item" == "$allowed" ]]; then
            return 0
        fi
    done
    return 1
}

matches_pattern() {
    local file="$1"
    local pattern="$2"

    # Convert glob pattern to regex
    local regex=$(echo "$pattern" | sed 's/\./\\./g' | sed 's/\*/.*/g')

    if [[ "$file" =~ ^$regex$ ]]; then
        return 0
    fi
    return 1
}

is_forbidden() {
    local item="$1"
    for pattern in "${FORBIDDEN_FILES[@]}"; do
        if matches_pattern "$item" "$pattern"; then
            return 0
        fi
    done
    return 1
}

# =============================================================================
# MAIN VALIDATION
# =============================================================================

cd "$PROJECT_DIR"

# Check if this is a claude-flow managed project
if [[ ! -d ".claude" ]] && [[ ! -f "CLAUDE.md" ]]; then
    # Not a claude-flow project, skip validation
    exit 0
fi

# Collect violations
violations=()
forbidden_found=()

# Scan root directory
for item in * .*; do
    # Skip . and ..
    [[ "$item" == "." ]] && continue
    [[ "$item" == ".." ]] && continue

    # Skip if doesn't exist (glob didn't match)
    [[ ! -e "$item" ]] && continue

    # Check if whitelisted
    if is_whitelisted "$item"; then
        continue
    fi

    # Check if explicitly forbidden
    if is_forbidden "$item"; then
        forbidden_found+=("$item")
        continue
    fi

    # Not whitelisted and not explicitly forbidden = unknown parasite
    violations+=("$item")
done

# =============================================================================
# REPORT RESULTS
# =============================================================================

total_issues=$((${#forbidden_found[@]} + ${#violations[@]}))

if [[ $total_issues -eq 0 ]]; then
    # Clean root - allow action
    exit 0
fi

# Found issues - block action
echo "" >&2
echo "╔══════════════════════════════════════════════════════════════════════╗" >&2
echo "║  ❌ ROOT WHITELIST VIOLATION - COMMIT BLOCKED                        ║" >&2
echo "╚══════════════════════════════════════════════════════════════════════╝" >&2
echo "" >&2

if [[ ${#forbidden_found[@]} -gt 0 ]]; then
    echo "🚫 FORBIDDEN FILES AT ROOT (must move or delete):" >&2
    echo "" >&2
    for item in "${forbidden_found[@]}"; do
        # Suggest where it should go
        if [[ "$item" =~ ^(tsconfig|\.eslintrc|\.prettierrc|jest\.config|vite\.config|tailwind\.config|postcss\.config|babel\.config|webpack\.config) ]]; then
            echo "   ├── $item  →  apps/[name]/$item" >&2
        elif [[ "$item" =~ ^(Dockerfile|docker-compose) ]]; then
            echo "   ├── $item  →  apps/devops/docker/$item" >&2
        elif [[ "$item" =~ ^\.env ]]; then
            echo "   ├── $item  →  apps/devops/env/$item" >&2
        elif [[ "$item" =~ ^(node_modules|dist|build|coverage|\.next|package-lock|yarn\.lock|pnpm-lock) ]]; then
            echo "   ├── $item  →  DELETE (regenerable)" >&2
        elif [[ "$item" =~ ^(turbo\.json|nx\.json|lerna\.json|pnpm-workspace) ]]; then
            echo "   ├── $item  →  DELETE (use Makefile)" >&2
        elif [[ "$item" =~ ^(src|lib|components|pages|api|server|client) ]]; then
            echo "   ├── $item/  →  apps/[name]/$item/" >&2
        else
            echo "   ├── $item" >&2
        fi
    done
    echo "" >&2
fi

if [[ ${#violations[@]} -gt 0 ]]; then
    echo "❓ UNKNOWN FILES AT ROOT (not in whitelist):" >&2
    echo "" >&2
    for item in "${violations[@]}"; do
        if [[ -d "$item" ]]; then
            echo "   ├── $item/  (directory)" >&2
        else
            echo "   ├── $item" >&2
        fi
    done
    echo "" >&2
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "" >&2
echo "📋 ALLOWED AT ROOT (whitelist):" >&2
echo "   apps/, project/, engineering/, docs/, .claude/, .git/, .github/" >&2
echo "   .gitignore, CLAUDE.md, README.md, LICENSE, Makefile, package.json" >&2
echo "" >&2
echo "🔧 TO FIX:" >&2
echo "   1. Move config files to their app: mv tsconfig.json apps/[name]/" >&2
echo "   2. Move DevOps files: mv Dockerfile apps/devops/docker/" >&2
echo "   3. Delete regenerables: rm -rf node_modules dist" >&2
echo "   4. Or run: /onboard to auto-clean" >&2
echo "" >&2

exit 2
