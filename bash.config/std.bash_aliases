alias cln='find . -name "*~" -type f -exec rm {} \;; find . -name "DEADJOE" -type f -exec rm {} \;'
alias dir='ls --color=auto -la'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias gh='history | grep -v "^grep" | grep --color=auto'
alias grep='grep --color=auto'
alias joe='joe -tab 2 -autoindent --wordwrap'
alias journalctl='journalctl --no-pager'
alias la='ls --color=auto -A'
alias lla='ls -la --color=auto --time-style=long-iso'
alias ll='ls -l --color=auto --time-style=long-iso'
alias l='ls --color=auto -CF'
alias lsd='lsd -L 1 -u'
alias ls='ls --color=auto --time-style=long-iso'
alias ok0='ssh root@okusi0'
alias ok1='ssh root@okusi1'
alias ok2='ssh root@okusi2'
alias okbali='ssh root@okusi0-bali'
alias okbatam='ssh root@okusi0-batam'
alias oketrade='ssh root@okusi0-etrade'
alias okgraha='ssh root@okusi0-graha'
alias okusi0='ssh root@okusi1 ssh root@okusi0 \'\'''\''iptables -F && echo $HOSTNAME:$PWD'\''\'\'' && ssh root@okusi0 '\''echo "welcome back, Sir."'\'''