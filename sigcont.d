BEGIN
{
  system("kill -CONT %d &\n", $target);
}