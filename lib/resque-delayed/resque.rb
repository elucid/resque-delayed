module Resque
  class << self
    def enqueue_at(time, *args)
      Resque::Delayed.create_at time, *args
    end

    def enqueue_in(offset, *args)
      Resque::Delayed.create_in offset, *args
    end
  end
end
