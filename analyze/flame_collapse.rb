# Collapses duplicate flamegraph.out lines into a single entry that's compatible with flamegraph.pl
# Example output:
# Faraday::Connection`get;Faraday::Connection`run_request;Faraday::Request::UrlEncoded`call;Module`=== 3
# Faraday::Connection`get;Faraday::Connection`run_request;Faraday::Request::UrlEncoded`call;IO`select 3
PUSH = '->'
POP  = '<-'

def collapse
  file = File.read(ARGV[0])
  lines = file.lines.to_a
  pattern       = /\A-?(\d+)(->|<-)(.*?)\Z/
  calls         = Hash.new(0)
  stack         = []
  ascending     = true

  file.lines.each do |line|
    next if line == "\n"
    line =~ pattern
    depth     = $1
    direction = $2
    method_id = $3

    raise line.inspect if !depth || !direction || !method_id

    if direction == PUSH
      stack.push(method_id)
      ascending = true
    else # POP
      # We've hit the peak of the stack. Record it
      if ascending
        calls[stack.join(";")] += 1
      end
      ascending = false

      stack.pop
    end
  end

  calls[stack.join(";")] += 1
  calls.each do |call, count|
    puts "#{call} #{count}"
  end
end

collapse
