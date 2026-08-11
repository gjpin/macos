# https://github.com/dreamsofautonomy/zensh/blob/main/.zshrc

# Add Homebrew's zsh completions before initializing completion.
FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"

# Load completions.
autoload -Uz compinit
compinit

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey "\e[1;3D" backward-word
bindkey "\e[1;3C" forward-word
bindkey "^[[1;9D" beginning-of-line
bindkey "^[[1;9C" end-of-line
bindkey "^[[3~" delete-char
bindkey "^?" backward-delete-char

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Enable bash-style globbing
setopt NO_NOMATCH          # Do not raise an error if a glob does not match any files
setopt GLOB_SUBST          # Perform substitutions in globs
setopt NO_GLOB_DOTS        # Do not match leading dots with wildcards
unsetopt EXTENDED_GLOB     # Disable extended globbing

# Enable comments in interactive sessions
setopt INTERACTIVE_COMMENTS

# Aliases
alias ls='ls --color'

# Shell integrations
eval "$(fzf --zsh)"

# Source .zshrc.d files
for file in ~/.zshrc.d/*; do
    source "$file"
done

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
    then
        PATH="$HOME/.local/bin:$HOME/bin:$PATH"
    fi
export PATH

# Load Homebrew-installed zsh plugins after local widget and keybinding setup.
brew_prefix="$(brew --prefix)"

source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$brew_prefix/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$brew_prefix/share/zsh-syntax-highlighting/highlighters"
source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Initialize Oh My Posh last so it sees all shell configuration and aliases.
eval "$(oh-my-posh init zsh --config "${HOME}/.omp.json" --strict)"
