# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Path to custom themes and plugins
ZSH_CUSTOM=$HOME/.dotfiles/oh-my-zsh-custom

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"
AGNOSTER_DIR_FG=black

# Hide username in prompt
DEFAULT_USER=`whoami`

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git composer macos brew laravel)

source $ZSH/oh-my-zsh.sh

# Removed old RVM path
#set numeric keys
# 0 . Enter
bindkey -s "^[Op" "0"
bindkey -s "^[Ol" "."
bindkey -s "^[OM" "^M"
# 1 2 3
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
# 4 5 6
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
# 7 8 9
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
# + -  * /
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"

# Load the shell dotfiles, and then some:
# * ~/.dotfiles-custom can be used for other settings you don’t want to commit.
for file in ~/.dotfiles/home/.{exports,aliases,functions}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done

for file in ~/.dotfiles-custom/shell/.{exports,aliases,functions,zshrc}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Directory jumping now handled by zoxide (see modern tools section below)


# Sudoless npm https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md
NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$PATH:$NPM_PACKAGES/bin"
# Preserve MANPATH if you already defined it somewhere in your config.
# Otherwise, fall back to `manpath` so we can inherit from `/etc/manpath`.
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"

export PATH=$HOME/.dotfiles/bin:$PATH

# Import ssh keys in keychain
ssh-add --apple-use-keychain 2>/dev/null;

# Setup xdebug
export XDEBUG_CONFIG="idekey=PHPSTORM"

# Enable autosuggestions (installed via brew)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# Extra paths
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.yarn/bin:$PATH"


#export PATH=/Users/Shared/DBngin/postgresql/17.0/bin:$PATH

export PATH=$HOME/bin:~/.config/phpmon/bin:$PATH
export JAVA_HOME="$(brew --prefix)/opt/openjdk@17"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Initialize modern tools
# zoxide - smarter cd
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# fnm - Node.js version manager
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

# bun completions
[ -s "/Users/freek/.bun/_bun" ] && source "/Users/freek/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit
