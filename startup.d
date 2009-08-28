BEGIN
{
  start = timestamp;
}

END
{
  this->total = timestamp - start;
  printf("Total: %u.%06ums\n", this->total / 1000000, this->total % 1000000);
}
