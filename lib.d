/*
 * We will discard whatever we captured unless
 * we have a dlopen -> open -> mmap call chain.
 */  

BEGIN
{
  d = 0; /* depth */
}

pid$target::dlopen:entry
/arg0/
{
  printf("opening %s\n", copyinstr(arg0));
}

pid$target::dlopen:entry
/arg0/
{
  self->path[d] = copyinstr(arg0);
  self->spec[d] = speculation();
  d++;
  speculate(self->spec[d]);

  printf("\n\n");
  printf("dlopen(\"%s\", ...)\n", self->path[d]);
}

pid$target::open:entry
/self->spec[d] && self->path[d] != 0 && self->path[d] == copyinstr(arg0)/
{ 
  speculate(self->spec[d]);
  self->savefd[d] = 1;
}

pid$target::open:return
/self->spec[d] && self->savefd[d]/
{
  speculate(self->spec[d]);
  self->fd[d] = arg1;
  printf("  -> open(\"%s\", ...) = %d\n", self->path[d], self->fd[d]);
}

pid$target::mmap:entry
/self->spec[d] && self->fd[d] && self->fd[d] == arg4/
{
  speculate(self->spec[d]);
  self->mmap_addr[d] = arg0;
  self->mmap_len[d] = arg1;
  self->mmap_fd[d] = arg4;
  self->mmap_offset[d] = arg5;
  printf("   -> mmap(%x, %u, ..., ..., %d, %u)\n", 
    self->mmap_addr[d], self->mmap_len[d], 
    self->mmap_fd[d], self->mmap_offset[d]);
}

pid$target::dlopen:return
/self->spec[d] && self->fd[d]/
{
  commit(self->spec[d]);
  self->spec[d] = 0;
}

pid$target::dlopen:return
/self->spec[d]/
{
  discard(self->spec[d]);
  self->spec[d] = 0;
}

pid$target::dlopen:return
{
  self->path[d] = 0;
  self->savefd[d] = 0;
  self->fd[d] = 0;
}

pid$target::dlopen:return
/d > 0/
{
  d--;
}




