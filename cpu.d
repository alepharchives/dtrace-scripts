#pragma D option quiet

profile-997
/pid == $target/
{
  @[execname] = count();
}
