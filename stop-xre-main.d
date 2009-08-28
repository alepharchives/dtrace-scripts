/* stop tracing here */

pid$target::XRE_main:entry
{
  exit(0);
}
