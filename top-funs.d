#pragma D option aggsortrev

pid$target:XUL::entry
{
  ts[probefunc] = timestamp;
  vts[probefunc] = vtimestamp;
}

pid$target:XUL::return
/ts[probefunc]/
{
  @ts[probefunc] = sum(timestamp - ts[probefunc]);
  @vts[probefunc] = sum(vtimestamp - vts[probefunc]);
  @count[probefunc] = count();
  
  ts[probefunc] = 0;
  vts[probefunc] = 0;
}

END
{
  trunc(@ts, 30);
  trunc(@vts, 30);
  trunc(@count, 30);

  printf("%16s %s\n", "ELAPSED", "FUNCTION/METHOD");
  printa("%@16u %s\n", @ts);
  printf("\n");
  printf("%16s %s\n", "CPU", "FUNCTION/METHOD");
  printa("%@16u %s\n", @vts);
  printf("\n");
  printf("%16s %s\n", "COUNT", "FUNCTION/METHOD");
  printa("%@16u %s\n", @count);
}

