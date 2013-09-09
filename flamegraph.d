#!/usr/sbin/dtrace -qs

#pragma D option bufsize=1000m

BEGIN {
  depth = 0;
  self->gc_took = 0;
}

ruby*:::*method-entry
{
  self->time = vtimestamp;
}

ruby*:::*method-return
{
  self->took = (vtimestamp - self->time - self->gc_took);
  self->gc_took = 0;
}

ruby*:::gc*-begin {
  self->gc_time = vtimestamp;
}

ruby*:::gc*-end {
  self->gc_took = (vtimestamp - self->time);
}

ruby*:::*method-entry
/copyinstr(arg1) != "require"/
{
  depth = depth + 1;
  printf("%d->%s\n", depth, strjoin(strjoin(copyinstr(arg0), "`"), copyinstr(arg1)));
}

ruby*:::*method-return
/copyinstr(arg1) != "require"/
{
  printf("%d<-%s@%d\n", depth, strjoin(strjoin(copyinstr(arg0), "`"), copyinstr(arg1)), self->took);
  depth = depth - 1;
}
