#!/usr/bin/env bash
# ==============================================================================
# One-click installer for motion-explainer and companion skills
# (motion-design, review-loop) on macOS and Linux.
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_MODE=false
CUSTOM_DEST=""
FORCE_MODE=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --workspace|-w) WORKSPACE_MODE=true ;;
        --dest|-d) CUSTOM_DEST="$2"; shift ;;
        --force|-f) FORCE_MODE=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "=========================================================="
echo " 🎬 Installing Motion Explainer 3-in-1 Skill Suite        "
echo "    - motion-explainer (End-to-End Animation Pipeline)    "
echo "    - motion-design    (HyperFrames Taste & Easing Rules) "
echo "    - review-loop      (Visual Contact Sheet Audit)       "
echo "=========================================================="

TARGET_DIRS=()
if [ -n "$CUSTOM_DEST" ]; then
    TARGET_DIRS+=("$CUSTOM_DEST")
elif [ "$WORKSPACE_MODE" = true ]; then
    TARGET_DIRS+=("$(pwd)/.agents/skills")
    TARGET_DIRS+=("$(pwd)/.gemini/skills")
else
    TARGET_DIRS+=("$HOME/.gemini/config/skills")
    TARGET_DIRS+=("$HOME/.claude/skills")
    if [ -n "$CODEX_HOME" ]; then
        TARGET_DIRS+=("$CODEX_HOME/skills")
    else
        TARGET_DIRS+=("$HOME/.codex/skills")
    fi
fi

for ROOT in "${TARGET_DIRS[@]}"; do
    mkdir -p "$ROOT"
    echo ""
    echo ">>> Target Skills Root: $ROOT"

    # 1. motion-explainer
    ME_TARGET="$ROOT/motion-explainer"
    if [ -d "$ME_TARGET" ] && [ "$FORCE_MODE" = false ]; then
        echo "  [-] motion-explainer already exists at $ME_TARGET (Use --force to overwrite)"
    else
        mkdir -p "$ME_TARGET"
        cp -f "$SCRIPT_DIR/SKILL.md" "$ME_TARGET/"
        [ -d "$SCRIPT_DIR/scripts" ] && cp -rf "$SCRIPT_DIR/scripts" "$ME_TARGET/"
        [ -d "$SCRIPT_DIR/references" ] && cp -rf "$SCRIPT_DIR/references" "$ME_TARGET/"
        [ -d "$SCRIPT_DIR/templates" ] && cp -rf "$SCRIPT_DIR/templates" "$ME_TARGET/"
        echo "  [+] Installed motion-explainer successfully!"
    fi

    # 2. motion-design
    MD_TARGET="$ROOT/motion-design"
    if [ -d "$MD_TARGET" ] && [ "$FORCE_MODE" = false ]; then
        echo "  [-] motion-design already exists at $MD_TARGET (Use --force to overwrite)"
    else
        mkdir -p "$MD_TARGET"
        cp -rf "$SCRIPT_DIR/companion-skills/motion-design/"* "$MD_TARGET/"
        echo "  [+] Installed motion-design successfully!"
    fi

    # 3. review-loop
    RL_TARGET="$ROOT/review-loop"
    if [ -d "$RL_TARGET" ] && [ "$FORCE_MODE" = false ]; then
        echo "  [-] review-loop already exists at $RL_TARGET (Use --force to overwrite)"
    else
        mkdir -p "$RL_TARGET"
        cp -rf "$SCRIPT_DIR/companion-skills/review-loop/"* "$RL_TARGET/"
        echo "  [+] Installed review-loop successfully!"
    fi
done

echo ""
echo "✅ Installation completed successfully! You can now use /motion-explainer in your AI agent."
