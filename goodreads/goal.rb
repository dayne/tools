#!/usr/bin/env ruby
require 'net/http'
require 'rubygems'
require 'xmlsimple'

# TODO: load id/key from a yaml file
id  = # the id of the user you want to
key = # your api key from goodreads
url = "http://www.goodreads.com/review/list/#{id}.xml?key=#{key}&v=2&per_page=100&sort=date_read"
xml_data = Net::HTTP.get_response(URI.parse(url)).body
data = XmlSimple.xml_in(xml_data)


require 'time'
now = Time.now
year_ago = Time.at( Time.now - 31556926 )
last_year = 0

puts "parse time"
#r = data['reviews'][0]['review'].each { |r| puts r['read_at'] if r['read_at'] }; nil
data['reviews'][0]['review'].each do |r| 
  if r['read_at'] and r['read_at'][0]
    begin
      t = Time.parse(r['read_at'][0])
      last_year += 1 if t > year_ago
    rescue Exception => error
      puts "failed parse :\n #{error}"
    end
  end
end

puts "you have read #{last_year} books in the last 52 weeks"
if last_year > 52
  puts "awesome: goal current of a book a week currently achived" if last_year > 52
else
  puts "read faster! read #{53 - last_year} books in the next week"
end
