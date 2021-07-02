# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt nomatch notify
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/niru/.zshrc'

# sudo complete
zstyle ':completion::complete:*' gain-privileges 1

autoload -Uz compinit
compinit
kitty + complete setup zsh | source /dev/stdin
# End of lines added by compinstall
#
#
# pure prompt
autoload -U promptinit; promptinit

SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_TIME_SHOW=false
SPACESHIP_USER_SHOW=always
SPACESHIP_HOST_SHOW=true
SPACESHIP_CHAR_SYMBOL="$ "
SPACESHIP_VI_MODE_INSERT=❯
SPACESHIP_VI_MODE_NORMAL=❮
prompt spaceship

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.zsh
. /usr/share/LS_COLORS/dircolors.sh
alias ls='ls --color=auto'
#alias dir='dir --color=auto'
#alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias icat="kitty +kitten icat"
alias ssh="kitty +kitten ssh"

function cpr() {
  rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 "$@"
}
function mvr() {
  rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files "$@"
}

function scpr() {
  rsync -arvz -e 'ssh -p 4420' --partial --info=stats1,progress2 --modify-window=1 "$@"
}

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

if [ "$(pactl list | grep -c "record_mono")" -eq "0" ] 2> /dev/null && [ "$(pactl list | grep -c "alsa_input.usb-BEHRINGER_UMC204HD_192k-00.analog-stereo")" != "0" ]; then
  # remap mic to mono
  pactl load-module module-remap-source source_name=record_mono master=alsa_input.usb-BEHRINGER_UMC204HD_192k-00.analog-stereo channels=2 channel_map=mono,mono > /dev/null
  # set remapped mic default
  pactl set-default-source record_mono
fi
