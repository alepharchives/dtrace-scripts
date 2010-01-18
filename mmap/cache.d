inline string FILENAME = "XUL";

fbt::vnode_isnocache:entry,
fbt::vnode_setnocache:entry,
fbt::vnode_clearnocache:entry
{
  self->vnode = (vnode_t)arg0;
  self->vnode_name = stringof((self->vnode)->v_name);
}

fbt::vnode_setnocache:entry,
fbt::vnode_clearnocache:entry
{
  printf("%s(%s)\n", probefunc, self->vnode_name);
}

fbt::vnode_isnocache:return
/self->vnode_name == FILENAME/
{
  printf("%s(%s) = %u\n", probefunc, self->vnode_name, arg1);
}


