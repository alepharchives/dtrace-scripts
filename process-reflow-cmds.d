mozilla$target:::process-reflow-do-work
{
  printf("\nthread id: %x\n", tid); 
  @n = count();
  ustack();
}

END
{
  printa("count  : %@u times\n", @n);
}
