#!/usr/sbin/dtrace -qs

/*
  Columns: Count, Class, file:line_number
  Sample:
     149 Net::BufferedIO readuntil /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/protocol.rb:131
     156 String index /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/protocol.rb:133
     165 Net::BufferedIO rbuf_consume /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/protocol.rb:171
     165 String slice! /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/protocol.rb:172
     236 String [] /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/http/response.rb:56
    1980 Symbol == /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/http.rb:885
*/

/* classname, methodname, filename, lineno */
ruby*:::*method-entry
{
  @count[copyinstr(arg0), copyinstr(arg1), copyinstr(arg2), arg3] = count();
}

END
{
  printf("Top 1000 method calls:\n");
  trunc(@count, 1000);
  printa("%@8u %s %s %s:%d\n", @count);
}
