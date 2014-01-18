require 'aruba/cucumber'
require 'methadone/cucumber'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

def start_web
  require 'webrick'
  pid = fork do
    web_server = WEBrick::HTTPServer.new(:Port => 55555, :DocumentRoot => Dir.pwd + '/web')
    trap('INT') { web_server.shutdown }
    web_server.start
  end
  File.open(PIDFILE, 'w') { |f| f.write(pid) }
end

def end_web
  if File.exist?(PIDFILE)
    pid = File.open(PIDFILE, 'r').read.to_i
  else
    puts "Server not started... exiting"
    exit
  end

  begin
    Process.kill('INT', pid)
  rescue
    puts "Process not running"
  end
  File.unlink(PIDFILE)
end

Before do
  # Using "announce" causes massive warnings on 1.9.2
  @puts = true
  @original_rubylib = ENV['RUBYLIB']
  ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s

  FileUtils.mkdir("tmp/foo")
  start_web
end

After do
  ENV['RUBYLIB'] = @original_rubylib

  FileUtils.rm_r("tmp/foo")
  end_web
end

