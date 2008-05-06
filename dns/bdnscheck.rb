#!/usr/bin/env ruby
require 'socket'
require 'logger'
$log = Logger.new(STDERR)
$log.level = Logger::INFO
$log.datetime_format = "%H:%M:%S"

def usage(msg=nil)
	puts msg if msg
	puts "urrg.  in correct usage.  try telling me what to do"
	exit
end

subnet = ARGV.shift || usage("Give me a class C subnet to check. like: 192.168.1")

def getname(address)
	begin
		a = Socket.gethostbyname(address)
		# a = [ canonical hostname, host aliases, address family, address of sockaddr ] 
		$log.debug "#{address} = #{a[0]}"
		res = Socket.gethostbyaddr(a[3],a[2])[0]
	rescue Exception=>error
		$log.debug "ERROR getname(#{address}) #{error}"
		address
	end
end

def getaddr(name)
	begin
		a = IPSocket.getaddress(name)
	rescue Exception=>error
		$log.debug "ERROR getaddr(#{name}) #{error}"
		nil
	end
end

(1..254).each { |i|
	mip = "#{subnet}.#{i}"
	$log.debug "looking up #{mip}"
	m_name = getname(mip)
	m_addr = getaddr(m_name) if m_name
	puts "MISMATCH #{mip} -> #{m_name} -> #{m_addr}"   if mip != m_addr
}
