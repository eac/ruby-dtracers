A collection of dtrace scripts and analysis tools for use with dtrace on Ruby 2. Contributions welcome.

## Scripts

### Allocate.d
Details object allocations:
```
   28702 Array(3) ruby-2.0.0-p195/gems/mongo-1.7.1/lib/mongo/util/core_ext.rb:46
   33000 Hash(0) ruby-2.0.0-p195/gems/treetop-1.4.14/lib/treetop/runtime/compiled_parser.rb:66
   33600 String(4) ruby-2.0.0-p195/gems/activerecord-2.3.18/lib/active_record/attribute_methods.rb:1
   35868 Array(3) ruby-2.0.0-p195/gems/active_record_shards-2.7.4/lib/active_record_shards/shard_selection.rb:37
   41150 Array(1) ruby-2.0.0-p195/gems/mail-2.5.4/lib/mail/header.rb:273
   85400 String(1) ruby-2.0.0-p195/gems/treetop-1.4.14/lib/treetop/runtime/compiled_parser.rb:100
  100042 Array(2) ruby-2.0.0-p195/gems/treetop-1.4.14/lib/treetop/runtime/compiled_parser.rb:110
  186065 Array(3) ruby-2.0.0-p195/gems/activesupport-2.3.18/lib/active_support/memoizable.rb:32
  186065 String(17) ruby-2.0.0-p195/gems/activesupport-2.3.18/lib/active_support/memoizable.rb:32
```

### Flow.d
Outputs a simple human readable call flow graph.
```
  -> OpenSSL::Buffering`read_nonblock
   -> OpenSSL::SSL::SSLSocket`sysread_nonblock
    -> Class`new
     -> Exception`initialize
     <- Exception`initialize
    <- Class`new
    -> Exception`exception
    <- Exception`exception
    -> Exception`backtrace
    <- Exception`backtrace
   <- OpenSSL::SSL::SSLSocket`sysread_nonblock
  <- OpenSSL::Buffering`read_nonblock
```

### Method Count.d
Counts all method calls.
```
     149 Net::BufferedIO readuntil /rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/protocol.rb:131
     156 String index /rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/protocol.rb:133
     165 Net::BufferedIO rbuf_consume /rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/protocol.rb:171
     165 String slice! /rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/protocol.rb:172
     236 String [] /rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/http/response.rb:56
    1980 Symbol == /rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/http.rb:885
```

### Method Time.d
Measures CPU time per method.
```
      27 OpenSSL::SSL::SSLSocket connect /rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/http.rb:918
     147 OpenSSL::X509::Store set_default_paths ruby-2.0.0-p195/gems/faraday-0.8.8/lib/faraday/adapter/net_http.rb:104
     147 Faraday::Adapter::NetHttp ssl_cert_store ruby-2.0.0-p195/gems/faraday-0.8.8/lib/faraday/adapter/net_http.rb:106
     147 Faraday::Adapter::NetHttp configure_ssl ruby-2.0.0-p195/gems/faraday-0.8.8/lib/faraday/adapter/net_http.rb:98
     408 TCPSocket initialize /rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/http.rb:878
     408 IO open /rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/net/http.rb:878
     436 Timeout timeout /rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/timeout.rb:52

  <off cpu> (IO)                                                19071
```

## Analysis

### Browsing Allocations
Object allocations tend to point to the most expensive Ruby code. 
./browse_allocations simplifies exploring allocation data.

```
 Usage:
./allocate.d -p <pid> -o cached.out

 APP_PATH=zendesk/zendesk ./browse_allocations cached.out
 Options:
 --package: Allocations by package
 --file: Allocations by file
 --line: Allocations by line (most detailed)
 --size: Allocated size per package

 Examples:

 APP_PATH=zendesk/zendesk ./browse_allocations cached.out --package
 Packages by allocation count
 ----------------------------
 93976 active_record_shards-2.7.4
 110082 actionpack-2.3.18
 460727 treetop-1.4.14
 547922 activerecord-2.3.18
 590897 activesupport-2.3.18
 880476 mail-2.5.4
 Total: 3419286
```

### Flamegraph
Flamegraphs are a good starting point when trying to get a sense of where the application is spending its time.
In the following example, we can see that most of `Faraday::Connection#get` time is spent making an HTTP call.

```
 Usage:
./flamegraph.d -p <pid> -o http.out
GRAPHER=~/FlameGraph/flamegraph.pl ./analyze/generate_flamegraph http.out
```

![example flamegraph](/examples/flamegraph.png)

Due to inaccurate return probes in Ruby (or perhaps bugs in this script) the output isn't 100% accurate. 
It does give a fairly good sense of the most heavily used code paths, 
and is a good guide for where to focus more accurate profiling methods (e.g. object allocations).

## Tips
* Often the biggest wins will come from reducing object allocations.
* For applications, try to mimic your production environment as much as possible. This includes things like setting the correct log level, sending a couple warmup requests, and making sure your app isn't in some error state (like throwing a bunch of memcached errors).

## References
* http://tenderlovemaking.com/2011/12/05/profiling-rails-startup-with-dtrace.html
* https://github.com/ruby/ruby/tree/trunk/test/dtrace
* https://bugs.ruby-lang.org/projects/ruby/wiki/DTraceProbes
* https://github.com/brendangregg/FlameGraph
