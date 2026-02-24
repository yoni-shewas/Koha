#!/bin/bash
# ==============================================================
# Koha Testing Docker (KTD) - Environment Setup Script
# ==============================================================
# Run this script once on a new machine to configure the
# environment variables needed for KTD.
#
# Usage:
#   chmod +x setup-ktd.sh
#   ./setup-ktd.sh
#
# Prerequisites:
#   - Docker Engine installed (https://docs.docker.com/engine/install/)
#   - Docker Compose v2.33.1+ (https://docs.docker.com/compose/install/)
#   - User added to docker group: sudo usermod -aG docker $USER
# ==============================================================

set -e

# Detect the directory where this script lives (= the Koha repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SYNC_REPO="$SCRIPT_DIR"
KTD_HOME="$SCRIPT_DIR/ktd"

# Detect shell config file
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "$(which zsh 2>/dev/null)" ]; then
    SHELL_RC="$HOME/.zshenv"
    SHELL_NAME="zsh"
else
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
fi

echo "============================================"
echo "  KTD Environment Setup"
echo "============================================"
echo ""
echo "Detected paths:"
echo "  SYNC_REPO  = $SYNC_REPO"
echo "  KTD_HOME   = $KTD_HOME"
echo "  Shell RC   = $SHELL_RC ($SHELL_NAME)"
echo ""

# Check if already configured
if grep -q "KTD_HOME" "$SHELL_RC" 2>/dev/null; then
    echo "⚠️  KTD environment variables already exist in $SHELL_RC"
    read -p "   Overwrite them? (y/N): " overwrite
    if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
        echo "Skipping. No changes made."
        exit 0
    fi
    # Remove old entries
    sed -i '/# KTD Environment/d' "$SHELL_RC"
    sed -i '/export SYNC_REPO=/d' "$SHELL_RC"
    sed -i '/export KTD_HOME=/d' "$SHELL_RC"
    sed -i '/export PATH=.*KTD_HOME/d' "$SHELL_RC"
    sed -i '/export LOCAL_USER_ID=/d' "$SHELL_RC"
fi

# Append environment variables
cat >> "$SHELL_RC" << EOF

# KTD Environment (added by setup-ktd.sh)
export SYNC_REPO="$SYNC_REPO"
export KTD_HOME="$KTD_HOME"
export PATH="\$PATH:\$KTD_HOME/bin"
export LOCAL_USER_ID=\$(id -u)
EOF

# Generate .env if not present
if [ ! -f "$KTD_HOME/.env" ] || [ ! -s "$KTD_HOME/.env" ]; then
    echo "Generating $KTD_HOME/.env from defaults..."
    cp "$KTD_HOME/env/defaults.env" "$KTD_HOME/.env"
fi

echo ""
echo "✅ Done! Environment variables added to $SHELL_RC"
echo ""
echo "Next steps:"
echo "  1. Reload your shell:  source $SHELL_RC"
echo "  2. Start KTD:          ktd up"
echo "  3. Access the shell:   ktd --shell"
echo "  4. Stop KTD:           ktd down"
echo ""
