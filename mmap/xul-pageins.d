fbt::vnode_pagein:entry
{
  self->v_name = stringof(((vnode_t)arg0)->v_name);
}

fbt::vnode_pagein:entry
/self->v_name == "XUL"/
{
  self->log = 1;
  self->offset = arg3;
  self->size = arg4;
  self->then = timestamp;
}

fbt::vnode_pagein:return
/self->log/
{
  self->now = timestamp;
  self->log = 0;
  printf("vnode_pagein: %s, offset: %u, size: %u, time: %u\n", 
    self->v_name, self->offset, self->size, self->now - self->then);
}
