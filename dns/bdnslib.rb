#!/usr/bin/env ruby
require 'socket'
require 'logger'

unless $log
  $log = Logger.new(STDERR)
  $log.level = Logger::INFO
  $log.datetime_format = "%H:%M:%S"
end

def getname(address)
    a = Socket.gethostbyname(address)
    # a = [ canonical hostname, host aliases, address family, address of sockaddr ] 
    $log.debug "#{address} = #{a[0]}"
    res = Socket.gethostbyaddr(a[3],a[2])[0]
  rescue Exception=>error
    $log.debug "ERROR getname(#{address}) #{error}"
    address
end

def getaddr(name)
    a = IPSocket.getaddress(name)
  rescue Exception=>error
    $log.debug "ERROR getaddr(#{name}) #{error}"
    nil
end


def check(r)
  case r[:type]
  when 'A'
    check_a(r[:source],r[:target])
  when 'CNAME'
    check_cname(r[:source],r[:target])
  when 'PTR'
    check_ptr(r[:source],r[:target])
  end
end

def check_a(source, target)
  # ping test # mac collect #
  source = source.downcase.chomp('.'); target = target.downcase.chomp('.')
  n = getname(target).downcase.chomp('.')
  $log.debug "A CHECK: #{source} -> #{target} -> #{n}" 
  if n != source
    if n == target
      printf("MISSING REVERSE : %35s -> %-35s (no host found)\n",source,target)
    else
      printf("MISMATCH ENTRY  : %35s != %-35s (%s)\n",source, n,target) 
    end
  end
end

def check_cname(source,target)
  source = source.downcase.chomp('.'); target = target.downcase.chomp('.')
  $log.debug "C CHECK: #{source} -> #{target}"
  t = getname(target).downcase.chomp('.')
  if t == target
    #puts "#{t} == #{target}"
  else
    printf("BAD CNAME ENTRY : %35s != %-35s (%s)\n",t,target,source)
  end
end

def check_ptr(source,target)
  source = source.downcase.chomp('.'); target = target.downcase.chomp('.')
  $log.debug "P CHECK: #{source} -> #{target}"
  revs = getaddr(target)
  revs = revs.downcase.chomp('.').split('.').reverse.join('.') + ".in-addr.arpa" if revs
  puts "PTR FAIL #{source} -> #{target} -> #{revs}" unless source == revs
end

