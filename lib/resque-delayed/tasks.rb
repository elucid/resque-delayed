# require 'resque-delayed/tasks'
namespace :resque_delayed do

  desc "Start a Resque::Delayed worker"
  task :work do
    require 'resque-delayed'

    begin
      worker = Resque::Delayed::Worker.new
      worker.verbose = ENV['LOGGING'] || ENV['VERBOSE']
      worker.very_verbose = ENV['VVERBOSE']
    end

    if ENV['PIDFILE']
      File.open(ENV['PIDFILE'], 'w') { |f| f << worker.pid }
    end

    worker.log "Starting Resque::Delayed worker #{worker}"

    worker.work(ENV['INTERVAL'] || 5) # interval, will block
  end
end
