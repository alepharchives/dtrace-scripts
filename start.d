BEGIN
{
  start = timestamp;
}

END
{
  end = timestamp;
  elapsed = end - start;
  printf("total run time: %u.%06ums\n\n", elapsed / 1000000, elapsed % 1000000);
}
