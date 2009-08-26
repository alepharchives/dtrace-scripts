#pragma D option quiet

profile-997
/pid == $target/
{
  @[ufunc(arg0)] = count();
}

/* stop tracing here */

mozilla$target:::main-entry
{
  exit(0);
}

END
{
  trunc(@, 25)
}
