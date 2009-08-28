BEGIN
{
  printf("kill -CONT %d\n", $target);
  system("kill -CONT %d\n", $target);
}