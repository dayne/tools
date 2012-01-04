#http://redhanded.hobix.com/bits/stowingYerLibrariesOffInTheCutNPaste.html 

# no accidents now
exit 


#magic lines
require 'open-uri'
eval(open("http://d.cl1p.net/.rb").read)

# careful to keep breathing
$HTTP_LOAD_PATH << "http://code.whytheluckystiff.net/svn/parkplace/trunk/lib" 

require 'parkplace'
# i hope you have a stiff drink close at hand
ParkPlace.serve
