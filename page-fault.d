typedef struct nameidata* nameidata_t;

pid$target::dlopen:entry
/arg0/
{
  self->ppath = arg0;
  self->path = "";
}

pid$target::dlopen:return
/self->path != ""/
{
  self->path = "";
}

pid$target::dyld??loadPhase5*:entry
{
  self->path = copyinstr(arg0);
}

pid$target::dyld??loadPhase5*:entry
/self->path != 0/
{
  self->func = probefunc;
}

pid$target::dyld??loadPhase5*:return
/self->func != 0 && self->func == probefunc/
{
  self->func = 0;
  self->path = "";
}

/* file name memory should be wired in by now */

pid$target::open:entry
/self->ppath && self->path == ""/
{
  self->path = copyinstr(self->ppath);
}

/* opening the same file */

/*
pid$target::open:entry
/self->path != 0 && self->path == copyinstr(arg0)/
{
  self->savefd = 1;
}
*/

fbt::vn_open_auth:entry
{
  this->ndp = arg0;
}

fbt::vn_open_auth:return
/self->path == ((nameidata_t)this->ndp)->ni_pathbuf/
{
  printf("Got a match on %s\n", self->path);
  this->vp = (vnode_t)((nameidata_t)this->ndp)->ni_vp;
  this->lib = stringof((this->vp)->v_name);
  self->vnode[this->vp] = this->lib;
  self->fullpath[this->vp] = self->path;
}

fbt::vnode_pagein:entry
/self->vnode[(vnode_t)arg0] != 0/
{
  printf("vnode_pagein(vnode ptr: %x = %s, upl: %x, upl_offset: %u, f_offset: %u, size: %u, flags: %d, ...)\n", arg0, self->vnode[(vnode_t)arg0], arg1, arg2, arg3, arg4, arg5);
}
