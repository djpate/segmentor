require 'digest/md5'
require 'ruby-progressbar'
class FtpFile
  
  THREAD_COUNT = 10

  def initialize(file, ftp)
    @file = file
    @ftp = ftp
    @threads = []
    @completed_part = 0
  end

  def download!
    puts "Downloading #{filename} - #{human_size} mb"
    @pb = ProgressBar.create(:total => size, :format => '%a |%b>%i| %p%% %t | %e | %r KB/sec', :rate_scale => lambda { |rate| rate / 1024 })
    prepare_threads
    do_threads
    join_parts
  end


  def size
    @size ||= @ftp.size(@file)
  end

  def human_size
    size / 1048576
  end

  private

  def watcher
    Thread.new {
      while downloading? do
        downloaded_size = 0
        THREAD_COUNT.times do |i|
          if File.exist?("/tmp/#{md5}_part_#{i}")
            downloaded_size += File.size("/tmp/#{md5}_part_#{i}")
          end
        end
        @pb.progress = downloaded_size
        sleep 1
      end
    }
  end

  def packet_size
    @packet_size ||= size / THREAD_COUNT
  end

  def range(from, to)
    "#{from}-#{to}"
  end

  def completed_part
    @completed_part += 1
  end

  def downloading?
    @completed_part < THREAD_COUNT
  end

  def prepare_threads
    clear_part_files
    THREAD_COUNT.times do |i|
      from_packet = i * packet_size
      to_packet   = from_packet + packet_size - 1
      @threads << Thread.new {
        curl(@file, range(from_packet, to_packet), i)
      }
    end
    @threads << watcher
  end

  def do_threads
    @threads.map(&:join)
  end


  def curl(file, range, index)
    `curl "ftp://#{Ftp::USER}:#{Ftp::PASS}@#{Ftp::HOST}/#{file}" -r #{range} -o /tmp/#{md5}_part_#{index} >/dev/null 2>&1`
  end

  def filename
    File.basename(@file)
  end

  def directory
    File.dirname(@file)
  end

  def create_directory
    `mkdir "/home/pate/triage/#{directory}" -p`
  end

  def join_parts
    create_directory
    `cat /tmp/#{md5}_part_* > "/home/pate/triage/#{@file}"`
    clear_part_files
  end

  def clear_part_files
    `rm /tmp/#{md5}_part_* -f`
  end

  def md5
    Digest::MD5.hexdigest(@file)
  end

end