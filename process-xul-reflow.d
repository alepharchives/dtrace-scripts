BEGIN
{
  self->ts = 0;
  self->vts = 0;
}

mozilla$target:::process-xul-reflow-entry
{
  self->ts = timestamp;
  self->vts = vtimestamp;  
  self->roots = arg0;
}

mozilla$target:::process-xul-reflow-return
/self->ts/
{
  this->ts = timestamp - self->ts;
  this->vts = vtimestamp - self->vts;
  
  printf("\n");
  printf("# roots: %u\n", self->roots);
  printf("elapsed: %u.%06ums\n", this->ts / 1000000, this->ts % 1000000);
  printf("cpu    : %u.%06ums\n", this->vts / 1000000, this->vts % 1000000);

  @tsint = sum(this->ts / 1000000);
  @tsfrac = sum(this->ts % 1000000);
  @vtsint = sum(this->vts / 1000000);
  @vtsfrac = sum(this->vts % 1000000);
  @n = count();
  
  self->ts = 0;
  self->vts = 0;
  
  ustack();
}

END
{
  t = timestamp;
  printf("\n\n----------------------\n");
  printa("elapsed: %@u.%@06ums\n", @tsint, @tsfrac);
  printa("cpu    : %@u.%@06ums\n", @vtsint, @vtsfrac);
  printa("count  : %@u times\n", @n);
}
