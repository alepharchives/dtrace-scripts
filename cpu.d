#pragma D option quiet

BEGIN
{
  ticks = 0;
}

profile-997
/pid == $target/
{
  @[execname] = count();
}

tick-10sec
/ticks == 1/
{ 
  exit(0);
}

tick-10sec
{
  ticks++;
}
