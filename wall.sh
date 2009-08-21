#!/bin/bash 

cmd="./Minefield.app/Contents/MacOS/firefox-bin -no-remote -foreground -P 1"

sync && purge && dtrace -x dynvarsize=64m -x evaltime=exec -c "$cmd" -Zs wall.d

