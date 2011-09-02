require "resque-delayed/version"

module Resque
  module Delayed
    class << self
      def clear
        Resque.redis.del :delayed
      end

      def count
        Resque.redis.zcard :delayed
      end

      def create_at(time, *args)
        job_class, rest = *args
        Resque.redis.zadd :delayed, time.to_i, encode(*args)
      end

      def create_in(offset, *args)
        create_at Time.now + offset, *args
      end

      def encode(job_class, *args)
        Resque.encode [job_class.to_s, *args]
      end

      def next
        next_at Time.now
      end

      def next_at(time)
        job = Resque.redis.
          zrangebyscore(:delayed, '-inf', time.to_i, :limit => [0, 1]).first

        # it is possible that another process will pull this job out of the
        # queue before this process has a chance. if that happens, return nil
        # so that we don't end up duplicating the job.
        return unless job and Resque.redis.zrem :delayed, job

        Resque.decode job
      end
    end
  end
end
