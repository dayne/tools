#!/usr/local/bin/ruby
# A simple index generator that I'd like to expand
# You're .htaccess will need something like:
#   Options Indexes
#   DirectoryIndex index.html /cgi-bin/index.cgi
require 'erb'
require 'cgi'
require 'yaml'
cgi = CGI.new('html4')

dir = File.join( ENV['DOCUMENT_ROOT'], ENV['REQUEST_URI'] )

Dir.chdir(dir)

e = Dir.entries(dir)
e.reject! { |i| i[0] == ?.  }
e.reject! { |i| i == "index.html" }
#e.reject! { |i| i == "README" }

files = e.collect { |f| f if File.file?(f) }.compact.sort
dirs = e.collect { |f| f if File.directory?(f) }.compact.sort

page = %{
  <center><h1><a style="text-decoration: none" href="../">.. /</a> <%= File.basename(dir) %> /</h1></center>
<% if File.exists?('README') %>
<div style="border: 1px solid #CCC; padding: 1em; margin: 1em;">
<%= File.open('README').read %>
</div>
<% end %>
<% if dirs.size > 0 %>
  <h1> DIRS </h1>
  <h2>
  <tt>
<ul><% dirs.each do |i| %>
  <li><a href='<%= i %>'> <%= i %> </a></li><% end %>
</ul>
<% end %>

<% if files.size > 0 %>
  <h1> FILES </h1>
<ul><% files.each do |i| %>
  <li>(t) <a href='<%= i %>'> <%= i %> </a> (size) (modified) (desc)
  </li><% end %>
</ul>
<% end %> 
  
  </tt>
  </h2>
  <hr />
  <a href=".list">file.list</a>
}

template = ERB.new(page)

template.run

cgi.out {
  cgi.head {
    cgi.title { ENV['REQUEST_URI']  } 
  } + cgi.body {
    target + "<br /><hr />" +
    template.run
  }
}
