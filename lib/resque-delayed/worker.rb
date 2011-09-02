module Resque::Delayed
  # a worker that harvests delayed jobs and queues them
  #
  # note: this is a modified version of
  # https://github.com/defunkt/resque/blob/e01bece0ccfd561909333d51b28813d59777183d/lib/resque/worker.rb
  # with nearly everything stripped out of it
  class Worker
    # Whether the worker should log basic info to STDOUT
    attr_accessor :verbose

    # Whether the worker should log lots of info to STDOUT
    attr_accessor  :very_verbose

    attr_writer :to_s

    # Can be passed a float representing the polling frequency.
    # The default is 5 seconds, but for a semi-active site you may
    # want to use a smaller value.
    def work(interval = 5.0)
      interval = Float(interval)
      $0 = "resque-delayed: harvesting"
      startup

      loop do
        break if shutdown?

        # harvest delayed jobs while they are available
        while job = Resque::Delayed.next do
          log "got: #{job.inspect}"
          payload_class_name, *args = job
          Resque::Job.create(:jobs, payload_class_name, *args)
        end

        break if interval.zero?
        log! "Sleeping for #{interval} seconds"
        sleep interval
      end
    end

    # Runs all the methods needed when a worker begins its lifecycle.
    def startup
      register_signal_handlers

      # Fix buffering so we can `rake resque-delayed:work > resque-delayed.log` and
      # get output from the worker
      $stdout.sync = true
    end

    # Registers the various signal handlers a worker responds to.
    #
    # TERM: Shutdown immediately, stop processing jobs.
    #  INT: Shutdown immediately, stop processing jobs.
    # QUIT: Shutdown after the current job has finished processing.
    def register_signal_handlers
      trap('TERM') { shutdown! }
      trap('INT')  { shutdown! }

      begin
        trap('QUIT') { shutdown }
      rescue ArgumentError
        warn "Signals TERM and/or QUIT not supported."
      end

      log! "Registered signals"
    end

    # Schedule this worker for shutdown. Will finish processing the
    # current job.
    def shutdown
      log 'Exiting...'
      @shutdown = true
    end

    # Kill the child and shutdown immediately.
    def shutdown!
      shutdown
    end

    # Should this worker shutdown as soon as current job is finished?
    def shutdown?
      @shutdown
    end

    def inspect
      "#<Resque::Delayed worker #{to_s}>"
    end

    # The string representation is the same as the id for this worker
    # instance. Can be used with `Worker.find`.
    def to_s
      @to_s ||= "#{hostname}:#{Process.pid}:resque-delayed"
    end
    alias_method :id, :to_s

    # chomp'd hostname of this machine
    def hostname
      @hostname ||= `hostname`.chomp
    end

    # Returns Integer PID of running worker
    def pid
      @pid ||= Process.pid
    end

    # Log a message to STDOUT if we are verbose or very_verbose.
    def log(message)
      if verbose
        puts "*** #{message}"
      elsif very_verbose
        time = Time.now.strftime('%H:%M:%S %Y-%m-%d')
        puts "** [#{time}] #$$: #{message}"
      end
    end

    # Logs a very verbose message to STDOUT.
    def log!(message)
      log message if very_verbose
    end
  end
end
