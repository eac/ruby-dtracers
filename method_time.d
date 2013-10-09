#!/usr/sbin/dtrace -qs

/***
  Measure CPU time per method:
  Sample:
      27 OpenSSL::SSL::SSLSocket connect /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/http.rb:918
     147 OpenSSL::X509::Store set_default_paths /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/faraday-0.8.8/lib/faraday/adapter/net_http.rb:104
     147 Faraday::Adapter::NetHttp ssl_cert_store /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/faraday-0.8.8/lib/faraday/adapter/net_http.rb:106
     147 Faraday::Adapter::NetHttp configure_ssl /Users/eric/.rvm/gems/ruby-2.0.0-p195/gems/faraday-0.8.8/lib/faraday/adapter/net_http.rb:98
     408 TCPSocket initialize /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/http.rb:878
     408 IO open /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/http.rb:878
     436 Timeout timeout /Users/eric/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/timeout.rb:52

  <off cpu> (IO)                                                19071
***/

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
        self->off = timestamp;
}

sched:::on-cpu
/self->off/
{
        @idle_time["<off cpu> (IO)"] = sum(timestamp - self->off);
        self->off = 0;
}

END
{
  normalize(@idle_time, 1000000);
  trunc(@time, 1000);
  normalize(@time, 1000000);
  printa("%@8u %s %s %s:%d\n", @time);
}
