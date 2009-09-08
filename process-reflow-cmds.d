pid$target::PresShell??ProcessReflowCommands*:entry
{
  self->flag = 1;
}

pid$target::PresShell??ProcessReflowCommands*:return
/self->flag/
{
  @n = count();
  ustack();
  self->flag = 0;
}

END
{
  printa("count  : %@u times\n", @n);
}
