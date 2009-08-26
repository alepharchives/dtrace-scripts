#pragma D option quiet

profile-997
/execname == "firefox-bin"/
{
  @[execname] = count();
}

tick-10sec 
{ 
  exit(0);
}
