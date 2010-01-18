BEGIN
{
  self->offset = 0;
  self->size = 0;
}

fbt::vnode_pagein:entry
{
  self->v_name = stringof(((vnode_t)arg0)->v_name);
}

fbt::vnode_pagein:entry
/self->v_name == "firefox-bin"/
{
  self->log = 1;
  self->last = self->offset + self->size;
  self->offset = arg3;
  self->size = arg4;
}

fbt::vnode_pagein:return
/self->log/
{
  self->log = 0;
  printf("offset: %u,\tsize: %u,\t+/-: %d\n", 
    self->offset / 4096, self->size / 4096, 
    (self->offset - self->last) / 4096);
}
