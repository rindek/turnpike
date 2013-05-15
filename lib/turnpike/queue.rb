require 'turnpike/base'

module Turnpike
  class Queue < Base
    # Pop one or more items from the queue.
    #
    # n - Integer number of items to pop.
    #
    # Returns a String item, an Array of items, or nil if the queue is empty.
    def pop(n = 1)
      items = []
      n.times do
        break unless item = redis.lpop(name)
        items << unpack(item)
      end

      n == 1 ? items.first : items
    end

    # Push items to the end of the queue.
    #
    # items - A splat Array of items.
    #
    # Returns nothing.
    def push(*items)
      redis.rpush(name, items.map { |i| pack(i) })
    end

    alias << push

    # Returns the Integer size of the queue.
    def size
      redis.llen(name)
    end

    # Push items to the front of the queue.
    #
    # items - A splat Array of items.
    #
    # Returns nothing.
    def unshift(*items)
      redis.lpush(name, items.map { |i| pack(i) })
    end
  end
end
