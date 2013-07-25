#!/usr/sbin/dtrace -q -s

ruby*:::*-create
{
  @a[copyinstr(arg0), copyinstr(arg1), arg2] = count();
}

END
{
  printa("%@8u %s %s:%d\n", @a);
}
