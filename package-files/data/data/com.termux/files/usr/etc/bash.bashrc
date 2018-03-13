###############################################################
##
##  Profile for interactive bash
##
###############################################################

## make sure that shell is non-interactive
[[ $- != *i* ]] && return

export HISTFILE="${HOME}/.bash_history"
export HISTSIZE=1024
export HISTFILESIZE=16384
export HISTCONTROL="ignoreboth"

## set X/Termux terminal title
case "${TERM}" in
    xterm*|rxvt*)
        PROMPT_COMMAND="echo -ne \"\e]0;Termux (host)\a\""
        ;;
    *)
        ;;
esac

PS1="\[\e[1;34m\][\[\e[m\]\[\e[1;31m\]termux\[\e[m\]\
\[\e[1;34m\]]\[\e[m\]\[\e[34m\]:\[\e[m\]\[\e[1;32m\]\
\w\[\e[m\]\[\e[1;34m\]:\[\e[m\]\[\e[1;37m\]\\$\[\e[m\] "
PS2='> '
PS3='> '
PS4='+ '

shopt -s checkwinsize
shopt -s cmdhist
shopt -s globstar
shopt -s histappend
shopt -s histverify

###############################################################
##
##  Setup aliases
##
###############################################################

## useful shortcuts
alias dir='ls'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lo='ls -la'
alias vdir='ls -l'

# for safety
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

###############################################################
##
##  Show a little help about using minimal environment
##
###############################################################

if shopt -q login_shell && [ -z "${SSH_TTY}" ]; then
    echo
    echo " Welcome to the Termux-VM host environment"
    echo
    echo " This is a busybox-based that has a small amount of tools"
    echo " which could be useful for advanced configuration or"
    echo " troubleshooting of the Termux VM."
    echo
    echo " Here is some tools which you can use:"
    echo
    echo "  * hexedit           - binary editor"
    echo "  * htop              - process monitor"
    echo "  * nano              - text/code editor"
    echo "  * qemu-img          - for managing QEMU disk images"
    echo "  * qemu-mon          - for connecting to the QEMU monitor"
    echo "  * shellcheck        - static analyser for shell scripts"
    echo "  * sshd              - OpenSSH server"
    echo "  * termux-container  - for using the original Termux environment"
    echo "  * unowned-files     - find files that not owned by any package"
    echo
    echo " If you want to change behaviour of login script,"
    echo " you need to edit file '\${PREFIX}/etc/login_overrides.sh'."
    echo
fi
