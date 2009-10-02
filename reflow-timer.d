/* We want to keep the trace only if the reflow timer fired.
 * We log speculatively and discard output if the timer is cancelled.
 *
 * Usage: dtrace -x specsize=128m -x bufresize=auto -s reflow-timer.d -p 15030 > /tmp/reflow.log 2>&1
 */
 
mozilla$target:::reflow-timer-init
{
  self->init = timestamp;
  self->spec = speculation();
  speculate(self->spec);
  printf("\n>>> reflow timer initialized at %u to fire in %ums\n", self->init, arg0);
}

pid$target:XUL::entry
/self->spec/
{
  /* log the function name */
  speculate(self->spec);
}

mozilla$target:::reflow-timer-cancel
/self->spec/
{
  printf("\n>>> reflow timer cancelled\n");
}

mozilla$target:::reflow-timer-cancel
/self->spec/
{
  discard(self->spec);
  self->spec = 0;
}

mozilla$target:::reflow-timer-fire
/self->spec/
{
  self->start = timestamp;
  self->elapsed = self->start - self->init;
  printf("\n>>> reflow timer fired at %u, after %u.%06ums\n", 
    self->start, self->elapsed / 1000000, self->elapsed % 1000000); 
}

mozilla$target:::reflow-timer-fire
/self->spec/
{
  commit(self->spec);
  self->spec = 0;
}
