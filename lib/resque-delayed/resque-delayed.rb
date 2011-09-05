module Resque
  module Delayed
    class << self
      def random_uuid
        UUIDTools::UUID.random_create.to_s.gsub('-', '')
      end

      def clear
        Resque.redis.del :delayed
      end

      def count
        Resque.redis.zcard :delayed
      end

      def create_at(time, *args)
        klass, *args = args
        queue = Resque.queue_from_class klass
        # validate here so that the Resque::Delayed worker doesn't have
        # to worry about it before enqueueing
        Resque.validate(klass, queue)
        Resque.redis.zadd :delayed, time.to_i, encode(queue, klass, *args)
      end

      def create_in(offset, *args)
        create_at Time.now + offset, *args
      end

      def encode(queue, klass, *args)
        "#{random_uuid}|#{Resque.encode([queue, klass.to_s, *args])}"
      end

      def decode(encoded_job)
        Resque.decode encoded_job.split('|', 2).last
      end

      def next
        next_at Time.now
      end

      def next_at(time)
        job = peek_at_serialized(time)

        # it is possible that another process will pull this job out of the
        # queue before this process has a chance. if that happens, return nil
        # so that we don't end up duplicating the job.
        return unless job and Resque.redis.zrem(:delayed, job)

        Resque::Delayed.decode job
      end

      def peek
        peek_at Time.now
      end

      def peek_at(time)
        job = peek_at_serialized(time)
        job and Resque::Delayed.decode(job)
      end

      def peek_at_serialized(time)
        Resque.redis.
          zrangebyscore(:delayed, '-inf', time.to_i, :limit => [0, 1]).first
      end
    end
  end
end
