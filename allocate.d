#!/usr/sbin/dtrace -q -s

/***
  Columns: Count, Class(length) file:line_number
  Sample:
       1 File /Users/eric/.rvm/scripts/irbrc.rb:32
       1 RubyToken::TkINTEGER /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/irb/ruby-token.rb:97
       1 RubyToken::TkLPAREN /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/irb/ruby-token.rb:95
       1 RubyToken::TkRBRACE /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/irb/ruby-token.rb:95
       1 RubyToken::TkRPAREN /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/irb/ruby-token.rb:95
       1 RubyToken::TkSTRING /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/irb/ruby-token.rb:97
       1 RubyToken::TkfLBRACE /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/irb/ruby-token.rb:95
   28702 Array(3) /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/mongo-1.7.1/lib/mongo/util/core_ext.rb:46
   33000 Hash(0) /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/treetop-1.4.14/lib/treetop/runtime/compiled_parser.rb:66
   33600 String(4) /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/activerecord-2.3.18/lib/active_record/attribute_methods.rb:1
   35868 Array(3) /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/active_record_shards-2.7.4/lib/active_record_shards/shard_selection.rb:37
   41150 Array(1) /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/mail-2.5.4/lib/mail/header.rb:273
   85400 String(1) /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/treetop-1.4.14/lib/treetop/runtime/compiled_parser.rb:100
  100042 Array(2) /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/treetop-1.4.14/lib/treetop/runtime/compiled_parser.rb:110
  186065 Array(3) /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/activesupport-2.3.18/lib/active_support/memoizable.rb:32
  186065 String(17) /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/activesupport-2.3.18/lib/active_support/memoizable.rb:32
***/

/* arg0=classname, arg1=filename, arg2=line number */
ruby*:::object-create
{
  @o[copyinstr(arg0), copyinstr(arg1), arg2] = count();
}

/* arg0=length */
ruby*:::array-create
{
  @a["Array", arg0, copyinstr(arg1), arg2] = count();
}

/* arg0=length */
ruby*:::hash-create
{
  @a["Hash", arg0, copyinstr(arg1), arg2] = count();
}

/* arg0=length */
ruby*:::string-create
{
  @a["String", arg0, copyinstr(arg1), arg2] = count();
}

END
{
  printa("%@8u %s %s:%d\n", @o);
  printa("%@8u %s(%d) %s:%d\n", @a);
}
