#pragma D option quiet

dtrace:::BEGIN
{
  start1 = timestamp;
  start2 = 0;
  init = 0;
  printf("starting in process %d\n", pid);
}

pid$target:XUL:XRE_main:entry
{
  start2 = timestamp;
}

pid$target::fork:entry
{
  printf("fork in process %d\n", pid);
}

pid$target::fork:return
{
  printf("fork returned in process %d\n", pid);
}

pid$target::dlopen:entry,
pid$target::NSAddImage:entry
{
  self->lib = copyinstr(arg0);
}

pid$target::NSLinkModule:entry
{
  self->lib = copyinstr(arg1);
}

pid$target::ImageLoader??runInitializers*:entry
/self->lib != 0/
{
  self->ts = vtimestamp;
}

pid$target::ImageLoader??runInitializers*:return 
/self->ts && self->lib != 0/
{
  this->delta = vtimestamp - self->ts;
  @initint = sum(this->delta / 1000000000);
  @initfrac = sum(this->delta % 1000000000);
  @int[self->lib] = sum(this->delta / 1000000000);
  @frac[self->lib] = sum(this->delta % 1000000000);
  self->lib = 0;
  self->ts = 0;
}

/* Stop tracing when BrowserStartup() returns. */

javascript*:::function-return
/copyinstr(arg2) == "BrowserStartup"/
{
  printf("probe %s firing in process %d\n", probename, pid);
  exit(0);
}

dtrace:::END
{
  printf("finishing in process %d\n", pid);
  t = timestamp;
  this->total = t - start1;
  this->startup = t - start2;
  this->init = start2 - start1;
  printf("Static initialization:\n");
  printa("%@u.%@09us for %s\n", @int, @frac);
  printf("---------------\n");
  printa("= %@u.%@03us\n\n", @initint, @initfrac);
  printf("Initialization: %u.%03us\n", this->init / 1000000000, this->init % 1000000000);
  printf("Startup       : %u.%03us\n", this->startup / 1000000000, this->startup % 1000000000);
  printf("---------------\n");
  printf("= %u.%03us\n", this->total / 1000000000, this->total % 1000000000);
}
