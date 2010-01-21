#!/bin/sh

./linux-purge.sh 

/home/moco/Work/$1/dist/firefox/firefox -no-remote -P clean file:///home/moco/Work/firefox-startup/startup.html#`python -c 'import time; print int(time.time() * 1000);'`
