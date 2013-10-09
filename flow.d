#!/usr/sbin/dtrace -qs

/***
  Outputs a simple human readable call flow graph.
  Notes:
   - Doesn't seem to be 100% accurate due to probes not always returning as expected.
   - Given the volume of data, it's probably best to output to a file for later analysis:
     e.g.: sudo ./flow.d -p 75884 -o flow.out

  Sample:
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
***/

BEGIN {
  whitespace[0] = " ";
  depth = 0;
}

ruby*:::*method-entry
{
  depth = depth + 1;
  whitespace[depth] = strjoin(whitespace[depth - 1], " ");
  printf("%s -> %s\n", whitespace[depth], strjoin(strjoin(copyinstr(arg0), "`"), copyinstr(arg1)));
}

ruby*:::*method-return
{
  printf("%s <- %s\n", whitespace[depth], strjoin(strjoin(copyinstr(arg0), "`"), copyinstr(arg1)));
  whitespace[depth] = 0;
  depth             = depth - 1;
}
