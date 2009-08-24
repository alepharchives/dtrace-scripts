#pragma D option quiet

dtrace:::BEGIN
{
  start1 = timestamp;
  start2 = 0;
  init = 0;
}

pid$target:XUL:XRE_main:entry
{
  start2 = timestamp;
}

pid$target::dlopen:entry,
pid$target::NSAddImage:entry
{
  self->lib = arg0;
}

pid$target::NSLinkModule:entry
{
  self->lib = arg1;
}

pid$target::ImageLoader??runInitializers*:entry
/self->lib != 0/
{
  self->ts = timestamp;
}

pid$target::ImageLoader??runInitializers*:return 
/self->ts && self->lib != 0/
{
  this->lib = copyinstr(self->lib);
  this->delta = timestamp - self->ts;
  @initint = sum(this->delta / 1000000000);
  @initfrac = sum(this->delta % 1000000000);
  @int[this->lib] = sum(this->delta / 1000000000);
  @frac[this->lib] = sum(this->delta % 1000000000);
  self->lib = 0;
  self->ts = 0;
}

/* Stop tracing when BrowserStartup() returns. */

javascript*:::function-return
/copyinstr(arg2) == "BrowserStartup"/
{
  exit(0);
}

dtrace:::END
{
  t = timestamp;
  this->total = t - start1;
  this->startup = t - start2;
  this->init = start2 - start1;
  printf("Static initialization:\n");
  printa("%@u.%@09us for %s\n", @int, @frac);
  printf("---------------\n");
  printa("= %@u.%@09us\n\n", @initint, @initfrac);
  printf("Initialization: %u.%09us\n", this->init / 1000000000, this->init % 1000000000);
  printf("Startup       : %u.%09us\n", this->startup / 1000000000, this->startup % 1000000000);
  printf("---------------\n");
  printf("= %u.%09us\n", this->total / 1000000000, this->total % 1000000000);
}
