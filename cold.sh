#!/bin/bash 

cmd="./Minefield.app/Contents/MacOS/firefox-bin -no-remote -foreground -P 2"
scripts=""

for i in $*; do scripts="$scripts -s $i"; done

sync && purge && dtrace -x dynvarsize=64m -x evaltime=exec -c "$cmd" -wZ $scripts

