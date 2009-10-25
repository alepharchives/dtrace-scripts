pid$target::dlopen:entry
/arg0/
{
  self->path = copyinstr(arg0);
}

pid$target::dlopen:return
/self->path != 0/
{
  self->path = 0;
}

/* opening the same file */

pid$target::open:entry
/self->path != 0 && self->path == copyinstr(arg0)/
{
  self->savefd = 1;
}

/* save file descriptor of a dlopen-ed library */

pid$target::open:return
/self->savefd/
{
  self->fd[arg1] = self->path;
  self->savefd = 0;
}

/* mmap-ing a library we know about */

pid$target::mmap:entry
/self->fd[arg4] != 0/
{
  self->mmap_addr = arg0;
  self->mmap_len = arg1;
  self->mmap_fd = arg4;
  self->mmap_offset = arg5;
  this->path = self->fd[arg4];
  
  printf("mapping %u bytes of %s from offset %d to address 0x%x\n\n",
    self->mmap_len, this->path, self->mmap_offset, self->mmap_addr);
}
