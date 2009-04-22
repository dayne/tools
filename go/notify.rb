#!/usr/bin/env ruby

require 'RNotify'
require 'dgs'

Notify.init("DGS")

u = DgsUser.new('bish0p')
loop do
  u.check
  u.parse
  new = u.current_games - u.last_games
  messages = []
  if new.size > 0
    new.each do |g|
      puts "#{g[:opponent]} has moved"
      msg = Notify::Notification.new("DGS", "#{g[:opponent]} has moved", nil, nil)      
      msg.timeout = 5000 # 3 seconds
      msg.show
      messages.push msg
    end
  end
  sleep 5
  messages.each {|m| m.close}
  sleep 30
end
