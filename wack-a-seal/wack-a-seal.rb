#!/usr/bin/env ruby
require 'colored'
require 'ap'
require 'thread'
require 'fileutils'

NUM_THREADS=5
FORCE_REMOVE=false
$threads = Array.new
$lock = Mutex.new

def log(msg)
  puts ">> #{msg}"
end

def boom(msg)
  puts "#### BOOM >>> ".red + msg
  exit 1
end

def process_image(input)
  # confirm image exists
  
  # create output dir if it doesn't exist
  # remove existing output image if exists
  # generate output image 
  if File.exists?(input)
    output_dir = File.join(File.dirname(input),'tif')
    if not File.directory?(output_dir)
      $lock.synchronize do 
        FileUtils.mkdir(output_dir) unless File.directory?(output_dir)
      end
    end
    output = File.join(output_dir,File.basename(input,'.*')+".tif")
    output = File.join(File.dirname(input),'tif',File.basename(input,'.*')+".tif")
    puts "input file is : #{input}"
    puts "output file is: #{output}"
    if File.exists?(output) 
      if FORCE_REMOVE

        FileUtils.rm(output) 
      else
        log "skipped: #{output}"
        return
      end
    end
    cmd = "gdalwarp -tr 0.04 0.04 -s_srs EPSG:3338 -t_srs EPSG:3338 " +
          "-r cubic -co 'TFW=YES' -co 'COMPRESS=LZW' -multi"
    #system(cmd,input,output)
    sleep rand(10)
    FileUtils.touch(output)
    #system
  end
end


top_dir = ARGV.shift || boom("give me a top dir to crunch on")

Dir.chdir(top_dir)

# I want an array of all the jpgs that are the targets
# test/YYYY/YYYYMMDD/*.jpg
#

targets = Dir.glob("*/*/*.jpg")
total = targets.size
complete = Array.new

NUM_THREADS.times do |i|
  puts "starting #{i} thread"
  $threads << Thread.new do 
    while( targets.size > 0 ) do
      target_jpeg = ""
      $lock.synchronize do
        target_jpeg = targets.pop
        puts "removing #{target_jpeg} from stack.  #{targets.size} left"
      end
      process_image(target_jpeg)
      $lock.synchronize do
        complete.push target_jpeg
        puts "puts completed #{complete.size} out of #{total}"
      end
    end
  end
end

$threads.each(&:join)
