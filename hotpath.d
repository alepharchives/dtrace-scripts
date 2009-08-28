#pragma D option quiet

profile-997
/pid == $target/
{
  @[ufunc(arg0)] = count();
}

END
{
  trunc(@, 25)
}
