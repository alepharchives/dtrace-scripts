pid$target::nsMenuX??MenuConstruct*:entry
{
  ts[probefunc] = timestamp;
  vts[probefunc] = vtimestamp;
}

pid$target::nsMenuX??MenuConstruct*:return
/ts[probefunc]/
{
  this->ts = timestamp - ts[probefunc];
  this->vts = vtimestamp - vts[probefunc];
  
  @tsint[probefunc] = sum(this->ts / 1000000);
  @tsfrac[probefunc] = sum(this->ts % 1000000);
  @vtsint[probefunc] = sum(this->vts / 1000000);
  @vtsfrac[probefunc] = sum(this->vts % 1000000);
  @count[probefunc] = count();
  
  ts[probefunc] = 0;
  vts[probefunc] = 0;
}

END
{
  printa("elapsed: %@u.%@06ums\n", @tsint, @tsfrac);
  printa("cpu    : %@u.%@06ums\n", @vtsint, @vtsfrac);
  printa("count  : %@u times\n", @count);
}
