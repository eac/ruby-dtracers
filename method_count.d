#!/usr/sbin/dtrace -qs

ruby*:::*method-entry
{
  @count[copyinstr(arg0), copyinstr(arg1), copyinstr(arg2), arg3] = count();
}

END
{
  printf("Top 1000 method calls:\n");
  trunc(@count, 1000);
}
