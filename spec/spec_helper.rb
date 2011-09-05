# based on https://github.com/defunkt/resque/blob/e01bece0ccfd561909333d51b28813d59777183d/test/test_helper.rb

require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

# this is necessary because of
# https://github.com/carlhuda/bundler/issues/1096
require 'resque'

# make sure we can run redis
if !system("which redis-server")
  puts '', "** can't find `redis-server` in your path"
  abort ''
end

dir = File.dirname(File.expand_path(__FILE__))

# start our own redis when the tests start,
# kill it when they end
at_exit do
  pid = File.read("#{dir}/redis-test.pid").chomp
  puts "Killing test redis server..."
  Process.kill("KILL", pid.to_i)
  File.unlink "#{dir}/redis-test.pid"
end

puts "Starting redis for testing at localhost:9736..."
`redis-server #{dir}/redis-test.conf`
Resque.redis = 'localhost:9736'

require "#{dir}/support/extensions.rb"

class SomeJob
  @queue = :jobs
end

class SomeOtherJob
  @queue = :other_jobs
end
