#
# http://redhanded.hobix.com/bits/packetTooChunkyOnPort0xbac0.html#comments
require'socket';s=TCPServer.new 80;loop{c=s.accept;c<<"\n"+IO.read(
c.gets[/\/(.*) /,1].gsub(/\.{2,}/){})rescue 404;c.close}
