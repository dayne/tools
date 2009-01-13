require 'open-uri'

class DgsUser
  SITE='http://www.dragongoserver.net/quick_status.php?user='

  attr_reader :username, :quick_status, :current_games, :last_games
  def initialize(nick)
    @username = nick
    @current_games = []
    @last_games = []
    @quick_status = ""
  end

  def check
    @quick_status = open(SITE+@username).read
  end
#'G', 463050, 'xath', 'W', '2009-01-13 09:41 GMT'
#'G', 462539, 'ChambersFamily', 'W', '2009-01-13 09:41 GMT'
  def parse
    lines = @quick_status.split("\n")
    errors = lines.collect {|l| l if l =~ /^#Error/ }.uniq
    games = lines.collect {|l| l.split(', ') if l[1].chr == 'G' }
    raise "Error for #{@username} - #{errors.inspect}" if errors[0]
    @last_games = @current_games
    @current_games = []
    games.each do |g|
      next unless g
      @current_games.push( :id => g[1].to_i, :opponent => g[2][1..-2], :date => g[4][1..-2]  )
    end
  end
end

if __FILE__ == $0
  u = DgsUser.new('bish0p')
  loop do 
    u.check
    u.parse
    new = u.current_games - u.last_games
    if new.size > 0
      puts "----------------- #{Time.now} ---------------"
      puts new.inspect 
    end
    sleep 30
  end
end
