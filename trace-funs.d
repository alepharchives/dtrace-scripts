BEGIN
{
  trace_start = timestamp;
}

pid$target:::entry
{
  self->trace_ts = timestamp;
}

pid$target:::return
/self->trace_ts/
{
  this->trace_delta = timestamp - self->trace_ts;
  @trace_elapsed1[probefunc] = sum(this->trace_delta / 1000000);
  @trace_elapsed2[probefunc] = sum(this->trace_delta % 1000000);
  @trace_total1 = sum(this->trace_delta / 1000000);
  @trace_total2 = sum(this->trace_delta % 1000000);
  @trace_count[probefunc] = count();
  self->trace_ts = 0;
}

END
{
  this->trace_t = timestamp;
  /*
  trunc(@trace_elapsed1, 25);
  trunc(@trace_elapsed2, 25);
  trunc(@trace_count, 25);
  */
  this->trace_total = this->trace_t - trace_start;
  printf("Top user functions by elapsed time:\n");
  printa("%@ 10u.%@06ums for %s\n", @trace_elapsed1, @trace_elapsed2);
  printf("---------------\n");
  printa("= %@u.%@06ums\n", @trace_total1, @trace_total2);
  printf("Total: %u.%06ums\n", this->trace_total / 1000000, this->trace_total % 1000000);
}
