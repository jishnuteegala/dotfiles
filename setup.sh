#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Setup Script (stow-based; works on MSYS2, macOS, and Linux)
# ==============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR" || exit

echo "Starting dotfiles setup..."

# 1. Check for stow
if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is not installed."
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*) echo "  Install: pacman -S stow (MSYS2)" ;;
        Darwin*)              echo "  Install: brew install stow" ;;
        *)                    echo "  Install: sudo apt install stow (or your package manager)" ;;
    esac
    exit 1
fi

# 2. Windows specific checks (if running in MSYS2)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "Windows environment detected."
    if [[ "$MSYS" != *"winsymlinks:nativestrict"* ]]; then
        echo "WARNING: Strict native symlinks are not enabled in your current session!"
        echo "Ensure 'export MSYS=winsymlinks:nativestrict' is in your ~/.bashrc and reload."
    fi
fi

# 3. Pre-create target directories so Stow never fails on a missing parent.
#    Example kept even though vscode/ is not currently stowed: VS Code needs
#    its deep settings dir to exist before a settings.json symlink can land.
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) mkdir -p "$HOME/AppData/Roaming/Code/User" ;;
    Darwin*)              mkdir -p "$HOME/Library/Application Support/Code/User" ;;
    *)                    mkdir -p "$HOME/.config/Code/User" ;;
esac

# 4. Stow the packages (each directory maps into $HOME)
PACKAGES=(
    "bash"
    "git"
    "vscode"
)

echo "Stowing configurations..."
for pkg in "${PACKAGES[@]}"; do
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
        echo "  -> Stowing $pkg..."
        stow -R -t "$HOME" "$pkg"
    else
        echo "  -> Skipping $pkg (directory not found)"
    fi
done

echo "Setup complete. Restart your terminal for changes to take effect."
echo
echo "Machine-specific config stays OUTSIDE this repo:"
echo "  ~/.gitconfig.local  - signingkey, gpgsign, credential overrides (gitconfig includes it)"
echo "  ~/.agents/          - private ai-config; bashrc sources it via one include line"
