#!/bin/bash

NAME=$*
TIME=$NAME.csv


function run {
  ./purge.sh
  /home/moco/Work/$1/dist/firefox/firefox -no-remote -P clean file:///home/moco/Work/firefox-startup/startup.html#`python -c 'import time; print int(time.time() * 1000);'`
}

rm -f $TIME

# ignore 1st run because of component registration overhead

for i in {1..101}; do
  run $1 | grep ELAPSED | cut -d" " -f2 >> $TIME
done
