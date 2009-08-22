#!/bin/bash 

cmd="./Minefield.app/Contents/MacOS/firefox-bin -no-remote -foreground -P 2"

sync && purge && dtrace -x dynvarsize=64m -x evaltime=exec -c "$cmd" -wZs startup.d

