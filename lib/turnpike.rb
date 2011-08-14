require 'redis'
require 'turnpike/queue'

# = Turnpike
#
# A Redis-backed queue.
module Turnpike
  class << self
    # Returns a cached or new queue.
    def [](queue)
      @queues[queue] ||= Queue.new(queue)
    end

    # Sets Redis connection options.
    def connect(options)
      @options = options
    end

    # Redis connection options.
    attr :options
  end

  @options, @queues = {}, {}
end
