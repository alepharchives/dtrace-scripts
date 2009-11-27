#pragma D option mangled
#pragma D option switchrate=10hz
#pragma D option bufsize=1g
 
pid$target:firefox-bin::entry
{
  @a[probefunc] = min(timestamp);
}

END
{
  printa("%s\n", @a);
}
