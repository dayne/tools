#!/usr/bin/env ruby

#require 'rubygems'
#require 'hpricot'
#require 'mechanize'
require 'yaml'
require 'open-uri'

SITE='http://www.dragongoserver.net/quick_status.php?user='

c = YAML.load_file('users')


users = c[:users]
data = {}
for u in users
  puts "checking #{u}"  
  f = open(SITE+u)
  data[u] = f.read
  puts data[u]
end

data.each do |u,f|
  puts u
  status = f.split("\n") if f
  #puts "  count: #{status.count}"
  errors = status.collect {|l| l if l =~ /^#Error/ }.uniq
  puts "error for #{u} - #{errors.inspect}" if errors[0]
  games = 0
  users = []
  status.each do |l| 
    if l[0].chr != '#' 
      games += 1 
      users.push l.split(', ')[2][1..-2]
    end
  end
  puts "  games: #{games} : #{users.uniq.join(',')if users.size > 1}"
end
