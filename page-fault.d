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
/arg0/
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

fbt::vn_open_auth:entry
{
  this->ndp = arg0;
}

fbt::vn_open_auth:return
/self->path == ((nameidata_t)this->ndp)->ni_pathbuf/
{
  this->vp = (vnode_t)((nameidata_t)this->ndp)->ni_vp;
  this->lib = stringof((this->vp)->v_name);
  self->lib[this->lib] = self->path;
  self->vnode[this->lib] = this->vp; /* unused */
}

fbt::vnode_pagein:entry
{
  self->v_name = stringof(((vnode_t)arg0)->v_name);
}

/* vnode pointers match but v_name seems more secure */

fbt::vnode_pagein:entry
/self->lib[self->v_name] != 0/
{
  printf("vnode_pagein: %s, offset: %u, size: %u\n", 
    self->v_name, arg3, arg4);
}
