#!/usr/bin/env ruby
# 2008.05.06 - Dayne Broderson
# silly simple script to give me a terminal with the running average of the last 60
# DNS lookups for a given host.
# usage:  ruby dns-timing.rb  <host>  # defaults to 'www.gina.alaska.edu'

require 'socket'
require 'timeout'
class Array; def sum; inject(nil) { |sum,x| sum ? sum+x : x }; end; end
def avg(ar)
  ar.sum / ar.size.to_f
end

host = ARGV.shift || "www.gina.alaska.edu"
times = []
s = Time.now
e = Time.now
i = 0
sum = 0
errors = 0
loop do 
  puts "count:  timing   | average           | error count   |    the IP" if (i % 30)==0
  s = Time.now
  printf("%4d : ", i)
  STDOUT.flush
begin
  h = ''
  timeout(10) do
    h = IPSocket.getaddress(host) 
    #h = `host #{host}`.chomp
    #`dig #{host}`; h = ''
  end
rescue Exception => error
  errors += 1
end
  e = Time.now
  d = e - s
  times.push d
  sum += d
  printf(" d(%.3f) ",d)
  printf("| avg(%.3f for %2d) | errors(%3d) ",avg(times),times.size,errors)
  printf "  | %16s",h
  print "***" if d > 1
  print "\n"
  i += 1
  times.pop if times.size > 99
  sleeps = (s+4)-Time.now
  sleep sleeps  if sleeps > 0
end

