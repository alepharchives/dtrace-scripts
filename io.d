/* Based on iosnoop by Brendan Gregg */

#pragma D option quiet
#pragma D option switchrate=10hz

/* print header */
 
BEGIN 
{
  last_event[""] = 0;
  ticks = 0;
  
  printf("%-10s %-10s %1s %7s %s\n",
    "DELTA", "DTIME", "D", "SIZE", "PATHNAME");
}

/*
 * Check event is being traced
 */
 
io:::start
{ 
  ($target == pid) ? self->ok = 1 : 1;
}

/*
 * Reset last_event for disk idle -> start
 * this prevents idle time being counted as disk time.
 */
 
io:::start
/! pending[args[1]->dev_statname] /
{
  /* save last disk event */
  last_event[args[1]->dev_statname] = timestamp;
}

/* store entry details */
 
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

/* process and print completion */

io:::done
/start_time[args[0]->b_edev, args[0]->b_blkno] /
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

  /* memory cleanup */
  start_time[this->dev, this->blk] = 0;

  /* print details */

  printf("%-10d %-10d ", this->delta/1000, this->dtime/1000);
  
  printf("%1s %7d ", args[0]->b_flags & B_READ ? "R" : "W", args[0]->b_bcount);
  printf("%s\n", args[2]->fi_pathname);

  /* save last disk event */
  last_event[args[1]->dev_statname] = timestamp;
}

/*
 * Prevent pending from underflowing
 * this can happen if this program is started during disk events.
 */
 
io:::done
/pending[args[1]->dev_statname] < 0 /
{
  pending[args[1]->dev_statname] = 0;
}

/* exit promptly */

tick-10sec
/ticks == 1/
{ 
  exit(0);
}

tick-10sec
{
  ticks++;
}
