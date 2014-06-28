require 'net/ftp'
require 'net/ftp/list'
class Ftp
  
  HOST     = CONFIG['ftp']['host']
  USER     = CONFIG['ftp']['user']
  PASS     = CONFIG['ftp']['pass']
  BASE_DIR = CONFIG['ftp']['directory']

  def initialize
    @ftp = Net::FTP.new(HOST)
    @ftp.login(USER, PASS)
  end

  def file_list(dir = BASE_DIR)
    files = []
    @ftp.list(dir.gsub(' ','\ ')).each do |e|
      entry = Net::FTP::List.parse(e)
      next if ['.','..'].include?(entry.basename)
      if entry.file?
        files << "#{dir}/#{entry.basename}"
      elsif entry.directory?
        file_list = file_list("#{dir}/#{entry.basename}")
        files.concat(file_list) unless file_list.empty?
      end
    end
    files
  end

  def size(file)
    @ftp.size(file)
  end

  def close
    @ftp.close
  end

end