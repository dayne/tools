#!/usr/bin/env ruby
require 'yaml'
require 'bdnslib'


$log = Logger.new(STDERR) unless $log
$log.level = Logger::INFO 
$log.datetime_format = "%H:%M:%S" 


def pull_records(domain)
  records = []
  result = `dig axfr #{domain}`
  result.each_line do |l|
    next if l[0].chr == ';'
    vars = l.split
    next if vars.size < 5
    source, timeout, thing, type, target = vars
    records.push({:source => source, :type => type, :target => target })
  end
  records
end
domain = ARGV.shift
records = pull_records(domain)
#puts records.to_yaml
records.each { |r| check(r) }

