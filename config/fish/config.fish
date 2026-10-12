# function fish_prompt
#     echo $PWD (set_color cyan) '> '
# end

function fish_prompt
    string join '' -- (set_color normal) (prompt_pwd) (set_color cyan) ' < '
end
set fish_greeting ""
if status is-interactive

fish_add_path ~/.spicetify
fish_add_path ~/.local/bin
fish_add_path ~/bin

alias cal='cal -m'
alias lv='lavat -c cyan -k red'
alias ff='fastfetch -l netbsd'
alias f='fastfetch'
alias tray='stalonetray --geometry 5x1+1720+0 --background "#000000" --icon-size 20'
alias nf='neofetch --ascii_distro netbsd'
alias n='neofetch'
alias w-real='bash -c w'
alias cma='cmatrix -rmu 6'
alias pf='pfetch'
alias qf='qfetch'
alias ls='eza -al --color=always --group-directories-first --icons=auto'

end
# Импорт цветовой схемы Pywal для Kitty
if test -e ~/.cache/wallust/sequences
    cat ~/.cache/wallust/sequences
end
set -g fish_color_autosuggestion blue
fish_add_path ~/.cargo/bin
alias rootHTTP "sudo chown -R http:http /srv/http/ && sudo chmod -R 755 /srv/http/"


