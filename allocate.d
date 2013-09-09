#!/usr/sbin/dtrace -q -s

ruby*:::object-create
{
  @o[copyinstr(arg0), copyinstr(arg1), arg2] = count();
}

ruby*:::array-create
{
  @a["Array", arg0, copyinstr(arg1), arg2] = count();
}

ruby*:::hash-create
{
  @a["Hash", arg0, copyinstr(arg1), arg2] = count();
}

ruby*:::string-create
{
  @a["String", arg0, copyinstr(arg1), arg2] = count();
}

END
{
  printa("%@8u %s %s:%d\n", @o);
  printa("%@8u %s(%d) %s:%d\n", @a);
}
