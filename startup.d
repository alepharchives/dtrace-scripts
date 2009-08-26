#pragma D option quiet

BEGIN
{
  start = timestamp;
}

/* stop tracing here */

mozilla$target:::main-entry
{
  exit(0);
}

END
{
  this->total = timestamp - start;
  printf("Total: %u.%06ums\n", this->total / 1000000, this->total % 1000000);
}
