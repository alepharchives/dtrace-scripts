BEGIN
{
  self->ts = 0;
  self->vts = 0;
}

pid$target::nsMenuX??MenuConstruct*:entry
{
  self->ts = timestamp;
  self->vts = vtimestamp;  
}

pid$target::nsMenuX??MenuConstruct*:return
/self->ts/
{
  this->ts = timestamp - self->ts;
  this->vts = vtimestamp - self->vts;
  @tsint = sum(this->ts / 1000000);
  @tsfrac = sum(this->ts % 1000000);
  @vtsint = sum(this->vts / 1000000);
  @vtsfrac = sum(this->vts % 1000000);
  @n = count();
  self->ts = 0;
  self->vts = 0;
  /*ustack();*/
}

END
{
  t = timestamp;
  printa("elapsed: %@u.%@06ums\n", @tsint, @tsfrac);
  printa("cpu    : %@u.%@06ums\n", @vtsint, @vtsfrac);
  printa("count  : %@u times\n", @n);
}
