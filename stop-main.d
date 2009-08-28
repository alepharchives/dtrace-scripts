#pragma D option quiet

/* stop tracing here */

mozilla$target:::main-entry
{
  exit(0);
}
