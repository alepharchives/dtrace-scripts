/* exit in 20s */

BEGIN 
{
  ticks = 0;
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

