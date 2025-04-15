# Cursor styles
set -gx fish_vi_force_cursor 1
set -gx fish_cursor_default block
set -gx fish_cursor_insert line blink
set -gx fish_cursor_visual block
set -gx fish_cursor_replace_one underscore

set -gx EDITOR (which nvim)
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

# Fish
set fish_emoji_width 2
alias ssh "TERM=xterm-256color command ssh"
alias mosh "TERM=xterm-256color command mosh"


# Oracle environment variables
set -x ORACLE_HOME /usr/lib/oracle/client64
set -x TNS_ADMIN /usr/lib/oracle/client64/network/admin
set -x LD_LIBRARY_PATH /usr/lib/oracle/client64/lib $LD_LIBRARY_PATH
set -x PATH $ORACLE_HOME/lib $PATH
set -x PATH /opt/nvim-linux-x86_64/bin $PATH
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
set -gx PATH "$HOME/.config/composer/vendor/bin" $PATH

# Set Go paths
set -x GOPATH $HOME/go
set -x PATH $PATH /usr/local/go/bin $GOPATH/bin


# Run proxy off command at startup
if status --is-login
    # echo "Turning proxy off at startup..."
    # proxy off

    set -e HTTP_PROXY
    set -e WSL_PAC_URL
    set -e http_proxy

end

# exa with icons aliases
alias ls='exa --icons'
alias ll='exa --icons -l'
alias la='exa --icons -la'
alias lt='exa --icons -T'
alias lta='exa --icons -Ta'
# Ensure proper support for Nerd Font icons
set -x LS_ICONS true


# Editor
abbr vim nvim
abbr vi nvim
abbr v nvim
abbr nano nvim
abbr sv sudoedit
abbr vudo sudoedit
alias lazyvim "NVIM_APPNAME=lazyvim nvim"
abbr lv lazyvim


alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
