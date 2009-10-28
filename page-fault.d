inline int PATHBUFLEN = 256;

struct nameidata {
        /*
         * Arguments to namei/lookup.
         */
        user_addr_t ni_dirp;            /* pathname pointer */
        enum    uio_seg ni_segflg;      /* location of pathname */
        /*
         * Arguments to lookup.
         */
        struct  vnode *ni_startdir;     /* starting directory */
        struct  vnode *ni_rootdir;      /* logical root directory */
        struct  vnode *ni_usedvp;       /* directory passed in via USEDVP */
        /*
         * Results: returned from/manipulated by lookup
         */
        struct  vnode *ni_vp;           /* vnode of result */
        struct  vnode *ni_dvp;          /* vnode of intermediate directory */
        /*
         * Shared between namei and lookup/commit routines.
         */
        u_int   ni_pathlen;             /* remaining chars in path */
        char    *ni_next;               /* next location in pathname */
        char    ni_pathbuf[PATHBUFLEN];
        u_long  ni_loopcnt;             /* count of symlinks encountered */

        struct componentname ni_cnd;
};

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

pid$target::open:entry
/self->path != 0 && self->path == copyinstr(arg0)/
{
  self->savefd = 1;
}

fbt::vn_open_auth:entry
{
  this->ndp = arg0;
}

/*
  printf("ndp->ni_vp: %x\n", (long)((struct nameidata*)this->ndp)->ni_vp);
  printf("ndp->ni_pathlen: %u\n", ((struct nameidata*)this->ndp)->ni_pathlen);
*/

fbt::vn_open_auth:return
/self->path == ((struct nameidata*)this->ndp)->ni_pathbuf/
{
  printf("Got a match on %s\n", self->path);
  this->vp = ((struct nameidata*)this->ndp)->ni_vp;
  printf("vp->v_name: %s\n", stringof(((struct vnode *)this->vp)->v_name));
  
  exit(0);
}

/*
fbt::vnode_pagein:entry
/i < 32/
{
  printf("vnode_pagein(vnode ptr: %x, upl: %x, upl_offset: %u, f_offset: %u, size: %u, flags: %d, ...)\n",
    arg0, arg1, arg2, arg3, arg4, arg5);
  i++;
}

fbt::vnode_pagein:entry
/i > 32/
{
  exit(0);
}
*/
