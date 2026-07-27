# ZSH


# Oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="frisk" # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
#    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


# Android
# Platform tools
PATH=$PATH:/home/avlalekhin/Android/Sdk/platform-tools


# Dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME/'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/.local/bin:$PATH"

# Yazi
# Zoxide
eval "$(zoxide init zsh)"

# Fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Aliases
alias suresetnwm='sudo systemctl restart NetworkManager; sudo systemctl restart systemd-resolved'
