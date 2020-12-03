#
# ~/.bashrc
#

. ~/.git-prompt.bash
[[ $- != *i* ]] && return
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true
if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi
    alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
fi

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less

set -o vi

export BROWSER="/usr/bin/brave"
export VISUAL=nvim
export EDITOR=nvim
export JAVA_HOME=/usr/lib/jvm/java-14-openjdk
export JDK_HOME=${JAVA_HOME}
alias v="nvim"
alias sv="sudo nvim"
alias la="ls -a"
alias findpid="pstree -p | grep"
alias vpn="sudo openvpn --config $HOME/.cache/kit.ovpn"
alias update="sudo pacman -Syyu"
alias prm="sudo pacman -Rs --color auto"
alias pins="sudo pacman -S --color auto"
alias psr="sudo pacman -Ss --color auto"
alias pdep="deps p"
alias pclean="sudo pacman -Rns \$(pacman -Qtdq)"
#grub update
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

export PATH=/home/niru/.scripts:$PATH
export PATH=/home/niru/.cache/Linux_Pentablet_V1.2.13.1:$PATH

#neofetch
alias setupdesktop="xrandr --output HDMI-0 --auto --left-of DP-0"
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
	GIT_PROMPT_THEME=TruncatedPwd_WindowTitle
    GIT_PROMPT_ONLY_IN_REPO=0
    source $HOME/.bash-git-prompt/gitprompt.sh
fi
