require 'yaml'
CONFIG = YAML.load_file("config.yml")

require './lib/ftp'
require './lib/file'
require 'digest/md5'


class Main

  CONFIG = YAML.load_file("config.yml")

  def initialize
    @ftp = Ftp.new
    queue.each do |file|
      FtpFile.new(file, @ftp).download!
    end
    @ftp.close
  end

  def queue
    @ftp.file_list - Dir.glob("#{CONFIG['download_dir']}/**/*").map{|file| file.gsub("#{CONFIG['download_dir']}/",'')}
  end

end

Main.new
