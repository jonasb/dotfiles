# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
export ZSH_THEME="arrow"

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# export DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git github history-substring-search command-not-found rvm vagrant npm)
if [[ "$VENDOR" == "apple" ]]; then
	plugins=("${plugins[@]}" brew osx) # add
	plugins=("${(@)plugins:#command-not-found}") # remove
fi

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
if [[ "$VENDOR" == "apple" ]]; then
	#alias vim='mvim -v'
	alias sed='/usr/local/bin/gsed'
	alias tmux='tmux -2'
	export PATH=/usr/local/bin:$PATH
fi

fpath=(/usr/local/share/zsh-completions $fpath)

# Enable vi-mode
bindkey -v

# from http://ft.bewatermyfriend.org/tmp/zsh.minimal
typeset -A key
key=(
    Home     "${terminfo[khome]}"
    End      "${terminfo[kend]}"
    Insert   "${terminfo[kich1]}"
    Delete   "${terminfo[kdch1]}"
    Up       "${terminfo[kcuu1]}"
    Down     "${terminfo[kcud1]}"
    Left     "${terminfo[kcub1]}"
    Right    "${terminfo[kcuf1]}"
    PageUp   "${terminfo[kpp]}"
    PageDown "${terminfo[knp]}"
)

function bind2maps () {
    local i sequence widget
    local -a maps

    while [[ "$1" != "--" ]]; do
        maps+=( "$1" )
        shift
    done
    shift

    sequence="${key[$1]}"
    widget="$2"

    [[ -z "$sequence" ]] && return 1

    for i in "${maps[@]}"; do
        bindkey -M "$i" "$sequence" "$widget"
    done
}

bind2maps emacs             -- Home   beginning-of-line
bind2maps       viins vicmd -- Home   vi-beginning-of-line
bind2maps emacs             -- End    end-of-line
bind2maps       viins vicmd -- End    vi-end-of-line
bind2maps emacs viins       -- Insert overwrite-mode
bind2maps             vicmd -- Insert vi-insert
bind2maps emacs             -- Delete delete-char
bind2maps       viins vicmd -- Delete vi-delete-char
#bind2maps emacs viins vicmd -- Up     up-line-or-history
#bind2maps emacs viins vicmd -- Down   down-line-or-history
bind2maps emacs viins vicmd -- Up     history-substring-search-up
bind2maps emacs viins vicmd -- Down   history-substring-search-down
bind2maps emacs             -- Left   backward-char
bind2maps       viins vicmd -- Left   vi-backward-char
bind2maps emacs             -- Right  forward-char
bind2maps       viins vicmd -- Right  vi-forward-char

if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' ${terminfo[smkx]}
    }
    function zle-line-finish () {
        printf '%s' ${terminfo[rmkx]}
    }
fi
zle -N zle-line-init
zle -N zle-line-finish

unfunction bind2maps

export LANG=en_US.UTF-8
