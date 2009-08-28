#!/bin/bash 

progname=$1
shift

scripts="-s sigcont.d"

for i in $*; do scripts="$scripts -s $i"; done

opts="-Zqw -x dynvarsize=64m -x evaltime=exec"

dtrace='

inline string progname="'$progname'";
inline string scripts="'$scripts'";
inline string opts="'$opts'";

proc:::exec-success
/execname == progname/
{
  stop();
  printf("dtrace %s -p %d %s\n", opts, pid, scripts);
  system("dtrace %s -p %d %s\n", opts, pid, scripts);
  exit(0);
}
'

sync && purge && dtrace $opts -n "$dtrace"
