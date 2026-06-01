# Created by newuser for 5.9
#============================================
# ~/.zshrc - Clean & Optimized
#============================================

#============================================
# Zinit Bootstrap
#============================================
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
	print -P "%F{33}Installing Zinit...%f"
	command mkdir -p "$HOME/.local/share/zinit" && command chmod -g-rwX "$HOME/.local/share/zinit"
	command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

#===========================================
# Zinit Plugins
#===========================================
zinit light-mode for \
	zdharma-continuum/zinit-annex-as-monitor \
	zdharma-continuum/zinit-annex-bin-gem-node \
	zdharma-continuum/zinit-annex-patch-dl \
	zdharma-continuum/zinit-annex-rust

zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-history-substring-search

#============================================
# Completion System
#============================================
autoload -Uz compinit
compinit -d ~/.zcompdump

_comp_options+=(globdots)
zstyle ':completion:*' special-dirs true

#===========================================
# fzf Integration
#===========================================
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
	source /usr/share/fzf/key-bindings.zsh
fi
if [[ -f /usr/share/fzf/completion.zsh ]]; then
	source /usr/share/fzf/completion.zsh
fi

#===========================================
# zoxide (smart cd)
#===========================================
eval "$(zoxide init zsh)"
alias cd="z"

#===========================================
# History
#===========================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

eval "$(starship init zsh)"

bindkey '&[[A' history-substring-search-up
bindkey '$[[B' history-substring-search-down

alias ls='eza --icons'
alias ll='eza -lah --icons'
alias lt='eza --tree --level=2 --icons'

#=========================================
# End of ~/zshrc
#=========================================
