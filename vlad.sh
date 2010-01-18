#!/bin/sh

FF=/Volumes/Fujitsu80Gb

NAME=$*
TIME=$NAME.time

function run {
  ./purge.sh
  $FF/Minefield$NAME.app/Contents/MacOS/firefox-bin -no-remote -P clean file://$FF/startup.html#`python -c 'import time; print int(time.time() * 1000);'`
}

rm -f $TIME

# ignore 1st run because of component registration overhead

for i in {1..101}; do
  run | grep ELAPSED | cut -d" " -f2 >> $TIME
done
