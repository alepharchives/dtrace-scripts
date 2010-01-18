#!/bin/sh

FF=/Volumes/Fujitsu80Gb

./purge.sh

$FF/Minefield$*.app/Contents/MacOS/firefox-bin -no-remote -P clean file://$FF/startup.html#`python -c 'import time; print int(time.time() * 1000);'`
