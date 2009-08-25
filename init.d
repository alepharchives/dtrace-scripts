#pragma D option quiet

BEGIN
{
  start = timestamp;
}

pid$target:::entry
{
  self->ts = timestamp;
}

pid$target:::return
/self->ts/
{
  this->delta = timestamp - self->ts;
  @elapsed1[probefunc] = sum(this->delta / 1000000);
  @elapsed2[probefunc] = sum(this->delta % 1000000);
  @total1 = sum(this->delta / 1000000);
  @total2 = sum(this->delta % 1000000);
  @count[probefunc] = count();
  self->ts = 0;
}

/* stop tracing here */

mozilla$target:::main__entry
{
  exit(0);
}

END
{
  this->t = timestamp;
  trunc(@elapsed1, 25);
  trunc(@elapsed2, 25);
  trunc(@count, 25);
  this->total = this->t - start;
  printf("Top user functions by elapsed time:\n");
  printa("%@ 10u.%@06ums for %s\n", @elapsed1, @elapsed2);
  printf("---------------\n");
  printa("= %@u.%@06ums\n\n", @total1, @total2);
  printf("Total: %u.%06ums\n", this->total / 1000000, this->total % 1000000);
}
