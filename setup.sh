#!/bin/bash

# ==============================================================================
# Dotfiles Setup Script
# ==============================================================================

# Ensure we are in the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR" || exit

echo "🚀 Starting Dotfiles Setup..."

# 1. Check for stow
if ! command -v stow &> /dev/null; then
    echo "❌ Error: GNU Stow is not installed."
    echo "Please install it first (e.g., 'pacman -S stow' in MSYS2, or 'sudo apt install stow' in Ubuntu)."
    exit 1
fi

# 2. Windows specific checks (if running in MSYS2)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "🪟 Windows environment detected."
    if [[ "$MSYS" != *"winsymlinks:nativestrict"* ]]; then
        echo "⚠️  WARNING: Strict native symlinks are not enabled in your current session!"
        echo "Please ensure 'export MSYS=winsymlinks:nativestrict' is in your ~/.bashrc and reload."
    fi
fi

# 3. Pre-create target directories to prevent Stow errors
echo "📁 Ensuring target directories exist..."
# (VS Code requires its deep AppData directory to exist before we can symlink the settings.json file into it)
mkdir -p "$HOME/AppData/Roaming/Code/User"

# 4. Stow the packages
echo "🔗 Stowing configurations..."

# Array of packages to stow (folder names in your repo)
PACKAGES=(
    "bash"
    "git"
    "vscode"
)

for pkg in "${PACKAGES[@]}"; do
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
        echo "  -> Stowing $pkg..."
        # -S stows, -R restows (refreshes), -t sets the target to your $HOME
        stow -R -t "$HOME" "$pkg"
    else
        echo "  -> ⏭️  Skipping $pkg (Directory not found)"
    fi
done

echo "✅ Setup complete! Restart your terminal for changes to take effect."
