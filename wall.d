#pragma D option quiet

dtrace:::BEGIN
{
  start = timestamp;
}


/**
 * Stop tracing when BrowserStartup() returns.
 */
javascript*:::function-return
/copyinstr(arg2) == "BrowserStartup"/
{
  exit(0);
}

dtrace:::END
{
  this->end = timestamp - start;
  printf("Startup time: %u.%03us\n", this->end / 1000000000, this->end % 1000000000);
}
