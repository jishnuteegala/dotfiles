# ~/.bashrc - cross-platform bash config (stow-managed from ~/dotfiles).
# Machine- or repo-private shell config does NOT live here: the ai-config
# block is sourced from ~/.agents via the include line at the bottom.

# --- shared -----------------------------------------------------------------

showpath() {
    # Prints the PATH variable with each entry on a new line for easy reading
    echo -e "${PATH//:/\\n}"
}

# ls - GNU flags where supported (BSD/macOS ls lacks --color/--group-directories-first)
if ls --color=auto --group-directories-first / >/dev/null 2>&1; then
    alias l='ls -lh --color=auto --group-directories-first'
    alias ls='ls -h --color=auto --group-directories-first'
    alias la='ls -lah --color=auto --group-directories-first'
else
    alias l='ls -lh'
    alias ls='ls -h'
    alias la='ls -lah'
fi
alias grep='grep --color=auto'

alias lastmod='find . -type f -not -path "*/\.*" -exec ls -lrt {} +'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit --amend --no-edit'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias glog='git log --oneline --decorate --graph'
alias gshow="git show --name-only --pretty=format:'commit %H%nAuthor: %an <%ae>%nDate: %ad%nSubject: %s' HEAD"
alias gsig="git log -1 --show-signature --pretty=format:'%H%n%G? %GS%n%an <%ae>%n%ad%n%s' HEAD"

# bash-completion framework
if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# fzf: use fd for faster file discovery with native --exclude support
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --exclude=.git --exclude=node_modules'
    export FZF_ALT_C_COMMAND='fd --type d --exclude=.git --exclude=node_modules'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# --- Windows / MSYS2 only ----------------------------------------------------

case "$(uname -s 2>/dev/null)" in
MINGW*|MSYS*|CYGWIN*)
    # Enable native symlink support in MSYS2
    export MSYS=winsymlinks:nativestrict

    # Prefer msys2 git binaries when present
    add_msys2_git_paths() {
        local msys2_prefixes=(
            /ucrt64/bin
            /mingw64/bin
        )
        local prefix
        local current_path=":$PATH:"
        local added_paths=()
        for prefix in "${msys2_prefixes[@]}"; do
            if [ -d "$prefix" ] && [[ "$current_path" != *":$prefix:"* ]]; then
                added_paths+=("$prefix")
            fi
        done
        if [ ${#added_paths[@]} -gt 0 ]; then
            PATH="$(IFS=:; printf '%s' "${added_paths[*]}"):$PATH"
            export PATH
        fi
    }
    add_msys2_git_paths

    # WinGet shims (mise, etc.)
    MISE_WINGET_DIR="${LOCALAPPDATA:-$HOME/AppData/Local}/Microsoft/WinGet/Links"
    if [ -d "$MISE_WINGET_DIR" ]; then
        case ":$PATH:" in
            *":$MISE_WINGET_DIR:"*) ;;
            *) export PATH="$MISE_WINGET_DIR:$PATH" ;;
        esac
    fi

    # MSYS2 Python vs Windows Python PATH handling
    # MSYS2 prepends /ucrt64/bin to PATH, causing MSYS2 Python to shadow Windows Python.
    # Keep MSYS2 Python first for system tools; use 'py' for Windows Python.
    # Override the install dir via WINDOWS_PYTHON_DIR env var.
    WINDOWS_PYTHON_DIR="${WINDOWS_PYTHON_DIR:-${LOCALAPPDATA:-$HOME/AppData/Local}/Programs/Python/Python312}"
    if [ -d "$WINDOWS_PYTHON_DIR" ]; then
        case ":$PATH:" in
            *":$WINDOWS_PYTHON_DIR:"*) ;;
            *) export PATH="$PATH:$WINDOWS_PYTHON_DIR" ;;
        esac
    fi
    py() { "$WINDOWS_PYTHON_DIR/python.exe" "$@"; }
    py3() { "$WINDOWS_PYTHON_DIR/python.exe" "$@"; }

    # fzf completion & key bindings (msys2 package paths)
    if [ -f /ucrt64/share/fzf/completion.bash ]; then
        source /ucrt64/share/fzf/completion.bash
        source /ucrt64/share/fzf/key-bindings.bash
    fi

    # Local tool paths - env-overridable, guarded on existence
    SWIFT_BIN="${SWIFT_BIN:-${LOCALAPPDATA:-$HOME/AppData/Local}/Programs/Swift/Toolchains/6.3.3+Asserts/usr/bin}"
    [ -d "$SWIFT_BIN" ] && export PATH="$PATH:$SWIFT_BIN"

    DEVIN_BIN="${DEVIN_BIN:-${LOCALAPPDATA:-$HOME/AppData/Local}/devin/cli/bin}"
    [ -d "$DEVIN_BIN" ] && export PATH="$DEVIN_BIN:$PATH"
    ;;
esac

# --- private shell config (ai-config) ---------------------------------------
# ~/.agents is a separate private repo; only this include line is public.
[ -f "$HOME/.agents/harness/shell.sh" ] && . "$HOME/.agents/harness/shell.sh"
