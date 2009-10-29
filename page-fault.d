typedef struct nameidata* nameidata_t; /* sys/namei.h */

pid$target::dlopen:entry
/arg0/
{
  self->ppath = arg0;
  self->dylib = 1;
}

pid$target::dyld??loadPhase5*:entry
/arg0/
{
  self->path = copyinstr(arg0);
  self->func = probefunc;
  self->dylib = 1;
}

pid$target::dlopen:return
{
  self->dylib = 0;
}

pid$target::dyld??loadPhase5*:return
/self->func != 0 && self->func == probefunc/
{
  self->dylib = 0;
}

/* file name memory should be wired in by now */

pid$target::open:entry
/self->dylib && self->ppath && self->path == 0/
{
  self->path = copyinstr(self->ppath);
}

fbt::vn_open_auth:entry
{
  self->ndp = (nameidata_t)arg0;
}

/* wait to make sure ndp and vnode are fully populated */

fbt::vn_open_auth:return
/self->path != 0/
{
  self->curpath = stringof((self->ndp)->ni_pathbuf);
}

/* make sure we are opening the same file */

fbt::vn_open_auth:return
/self->curpath != 0 && self->path == self->curpath/
{
  this->vp = (vnode_t)(self->ndp)->ni_vp;
  this->lib = stringof((this->vp)->v_name);
  self->lib[this->lib] = self->path;
  self->vnode[this->lib] = this->vp; 
  /*
  printf("match = %s\, lib = %s, vnode: %x\n", 
    self->curpath, this->lib, (long)this->vp);
  */
}

fbt::vn_open_auth:return
{
  self->path = 0;
  self->ppath = 0;
  self->curpath = 0;
  self->ndp = 0;
  self->func = 0;
}

fbt::vnode_pagein:entry
{
  self->v_name = stringof(((vnode_t)arg0)->v_name);
}

/* vnode pointers should match but v_name seems more secure */

fbt::vnode_pagein:entry
/self->lib[self->v_name] != 0/
{
  printf("vnode_pagein: %s, offset: %u, size: %u\n", 
    self->v_name, arg3, arg4);
}
