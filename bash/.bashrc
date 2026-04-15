opencode() {
    # 1. Load the env file and export variables automatically
    if [ -f ~/.config/opencode/.env ]; then
        set -a
        source ~/.config/opencode/.env
        set +a
    fi

    # 2. Run directly in Windows Terminal ($WT_SESSION), use winpty in Mintty.
    #    - Windows Terminal: direct mode enables proper resize handling.
    #    - Mintty: winpty required for mouse tracking cleanup on exit.
    #    - Fallback to direct: for UCRT64/MSYS where winpty may not be installed.
    if [ -n "$WT_SESSION" ]; then
        opencode.cmd "$@"
    elif command -v winpty >/dev/null 2>&1; then
        winpty opencode.cmd "$@"
    else
        opencode.cmd "$@"
    fi
}

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

showpath() {
    # Prints the PATH variable with each entry on a new line for easy reading
    echo -e "${PATH//:/\\n}"
}

# some more ls aliases
# alias ll='ls -alF'
# alias la='ls -A'
# alias l='ls -CF'

# ls
# alias ls='ls --color=auto'
# alias ll='ls -la'
# alias la='exa -laghm@ --all --icons --git --color=always'
# alias la='ls -lathr'

alias l='ls -lh --color=auto --group-directories-first'
alias ls='ls -h --color=auto --group-directories-first'
alias la='ls -lah --color=auto --group-directories-first'
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

# Enable native symlink support in MSYS2 to avoid issues with symlinks in WSL
export MSYS=winsymlinks:nativestrict
