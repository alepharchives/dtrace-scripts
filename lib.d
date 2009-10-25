/*
 * We will discard whatever we captured unless
 * we have a dlopen -> open -> mmap call chain.
 */  

BEGIN
{
  depth = 0;
}

pid$target::dlopen:entry
/arg0/
{
  self->path[depth] = copyinstr(arg0);
  self->spec[depth] = speculation();
  depth++;
  speculate(self->spec[depth]);

  printf("\n\n");
  printf("dlopen(\"%s\", ...)\n", self->path[depth]);
}

pid$target::open:entry
/self->spec[depth] && self->path[depth] != 0 && self->path[depth] == copyinstr(arg0)/
{ 
  speculate(self->spec[depth]);
  self->savefd[depth] = 1;
}

pid$target::open:return
/self->spec[depth] && self->savefd[depth]/
{
  speculate(self->spec[depth]);
  self->fd[depth] = arg1;
  printf("  -> open(\"%s\", ...) = %d\n", self->path[depth], self->fd[depth]);
}

pid$target::mmap:entry
/self->spec[depth] && self->fd[depth] && self->fd[depth] == arg4/
{
  speculate(self->spec[depth]);
  self->mmap_addr[depth] = arg0;
  self->mmap_len[depth] = arg1;
  self->mmap_fd[depth] = arg4;
  self->mmap_offset[depth] = arg5;
  printf("   -> mmap(%x, %u, ..., ..., %d, %u)\n", 
    self->mmap_addr[depth], self->mmap_len[depth], 
    self->mmap_fd[depth], self->mmap_offset[depth]);
}

pid$target::dlopen:return
/self->spec[depth] && self->fd[depth]/
{
  commit(self->spec[depth]);
  self->spec[depth] = 0;
}

pid$target::dlopen:return
/self->spec[depth]/
{
  discard(self->spec[depth]);
  self->spec[depth] = 0;
}

pid$target::dlopen:return
{
  self->path[depth] = 0;
  self->savefd[depth] = 0;
  self->fd[depth] = 0;
}

pid$target::dlopen:return
/depth > 0/
{
  depth--;
}




