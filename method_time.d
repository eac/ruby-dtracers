#!/usr/sbin/dtrace -o method_time.out -qs

#pragma D option bufsize=1000m

ruby*:::*method-entry
{
  self->time = vtimestamp;
}

ruby*:::*method-return
{
  this->took = (vtimestamp - self->time);
  @time[copyinstr(arg0), copyinstr(arg1), copyinstr(arg2), arg3] = sum(this->took);
}


sched:::off-cpu
/pid == $target/
{
        self->off = vtimestamp;
}

sched:::on-cpu
/self->off/
{
        @idle_time["<off cpu>"] = sum(vtimestamp - self->off);
        self->off = 0;
}

END
{
  printf("Time breakdown (milliseconds):\n");
  normalize(@idle_time, 1000000);
  trunc(@time, 1000);
  normalize(@time, 1000000);
}
