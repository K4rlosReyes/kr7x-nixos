# Zsh Configuration
# K4rlosReyes dotfiles

# Plugins
plugins=(
  git
  docker
  kubectl
  zsh-autosuggestions
  zsh-syntax-highlighting
  history-substring-search
  direnv
)

# User configuration
export EDITOR='nvim'
export BROWSER='brave'
export TERM='kitty'

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Application-specific
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go"

# Path additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# NixOS aliases
alias nrs='sudo nixos-rebuild switch --flake ~/.kr_flake'
alias nrt='sudo nixos-rebuild test --flake ~/.kr_flake'
alias nrb='sudo nixos-rebuild boot --flake ~/.kr_flake'
alias nu='nix flake update ~/.kr_flake'
alias ng='nix-collect-garbage -d'
alias nsh='nix-shell'

# Dotfiles management
alias dots='cd ~/.kr_flake/.dotfiles'
alias dotfiles='cd ~/.kr_flake/.dotfiles'

# Custom functions
mkcd() { mkdir -p "$1" && cd "$1"; }

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Load direnv if available
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
