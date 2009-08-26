/* Based on iosnoop by Brendan Gregg */

#pragma D option quiet
#pragma D option switchrate=10hz

dtrace:::BEGIN 
{
  last_event[""] = 0;
}

/* check event is being traced */

io:::start
{ 
  ($target == pid) ? self->ok = 1 : 1;
}

/*
 * Reset last_event for disk idle -> start
 * this prevents idle time being counted as disk time.
 */
 
io:::start
/! pending[args[1]->dev_statname]/
{
  /* save last disk event */
  last_event[args[1]->dev_statname] = timestamp;
}

/*
 * Store entry details
 */
 
io:::start
/self->ok /
{
  /* these are used as a unique disk event key, */
  this->dev = args[0]->b_edev;
  this->blk = args[0]->b_blkno;

  /* save disk event details, */
  start_time[this->dev, this->blk] = timestamp;

  /* increase disk event pending count */
  pending[args[1]->dev_statname]++;

  self->ok = 0;
}

/* process */
 
io:::done
/start_time[args[0]->b_edev, args[0]->b_blkno]/
{
  /* decrease disk event pending count */
  pending[args[1]->dev_statname]--;

  /* fetch entry values */
  this->dev = args[0]->b_edev;
  this->blk = args[0]->b_blkno;
  this->stime = start_time[this->dev, this->blk];
  this->etime = timestamp; /* endtime */
  this->delta = this->etime - this->stime;
  this->dtime = last_event[args[1]->dev_statname] == 0 ? 0 :
    timestamp - last_event[args[1]->dev_statname];
  this->rw = args[0]->b_flags & B_READ ? "R" : "W";
  
  @delta[this->rw, args[2]->fi_pathname] = sum(this->delta/1000);
  @dtime[this->rw, args[2]->fi_pathname] = sum(this->dtime/1000);
  @count[this->rw, args[2]->fi_pathname] = sum(args[0]->b_bcount);
  
  /* memory cleanup */
  start_time[this->dev, this->blk] = 0;

  /* save last disk event */
  last_event[args[1]->dev_statname] = timestamp;
}

/*
 * Prevent pending from underflowing
 * this can happen if this program is started during disk events.
 */
 
io:::done
/pending[args[1]->dev_statname] < 0/
{
  pending[args[1]->dev_statname] = 0;
}
 
/* exit promptly */

tick-10sec 
{ 
  exit(0);
}

/* print details */

END
{
  printf("%-10s %-10s %7s %1s %s\n", "DELTA", "DTIME", "SIZE", "D", "PATHNAME");
  printa("%@-10d %@-10d %@7d %1s %s\n", @delta, @dtime, @count);
}