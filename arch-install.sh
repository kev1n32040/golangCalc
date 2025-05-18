[main]
term=xterm-256color
font=JetBrainsMono Nerd Font:size=11
shell=/bin/bash
cursor-shape=block
pad=10x10
dpi-aware=yes
bold-is-bright=yes

[scrollback]
lines=10000
indicator=auto

[colors]
background=282828
foreground=ebdbb2
regular0=282828
regular1=cc241d
regular2=98971a
regular3=d79921
regular4=458588
regular5=b16286
regular6=689d6a
regular7=a89984
bright0=928374
bright1=fb4934
bright2=b8bb26
bright3=fabd2f
bright4=83a598
bright5=d3869b
bright6=8ec07c
bright7=ebdbb2

[cursor]
style=block
blink=no

[key-bindings]
spawn-terminal=Control+Shift+Return
copy-clipboard=Control+Shift+C
paste-clipboard=Control+Shift+V
toggle-fullscreen=F11
font-increase=Control+Shift+Plus
font-decrease=Control+Shift+Minus
font-reset=Control+Shift+0
search-start=Control+Shift+F
search-next=Control+F3
search-prev=Shift+F3
search-exit=Escape

mkdir -p ~/.config/foot
cp /usr/share/doc/foot/examples/foot.ini ~/.config/foot/foot.ini
