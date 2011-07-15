require 'redis'

# A Redis-backed queue.
class Turnpike
  REDIS_VERSION = Redis.current.info['redis_version']
  TIMEOUT       = ENV['TURNPIKE_TIMEOUT'] || 2

  # The name of the queue.
  attr :name

  # Creates a new queue.
  #
  # Takes an optional name.
  def initialize(name = 'default')
    @name = "turnpike:#{name}"
  end

  # Removes all queued items.
  def clear
    redis.del(name)
  end

  # Calls block once for each queued item.
  #
  # Takes an optional boolean argument to specify if the command should block
  # the connection when the queue is empty. This argument defaults to false.
  def each(blocking = false, &block)
    while item = shift(blocking)
      block.call(item)
    end
  end

  # Iterates the given block for each slice of `n` queued items.
  def each_slice(n, blocking = false, &block)
    slice = []

    each(blocking) do |item|
      slice << item
      if slice.size == n
        yield slice
        slice = []
      end
    end

    yield slice unless slice.empty?
  end

  # Returns `true` if the queue is empty.
  def empty?
    length == 0
  end

  # Returns the length of the queue.
  def length
    redis.llen(name)
  end
  alias size length

  # Returns an array of items currently queued.
  #
  # `start` is an integer and indicates the start offset, 0 being the first
  # queued item. If negative, it indicates the offset from the end, -1 being
  # the last queued item.
  #
  # `count` is also an integer and indicates the number of items to return.
  def peek(start, count)
    redis.lrange(name, start, count)
  end

  # Retrieves the last queued item.
  #
  # Takes an optional boolean argument to specify if the command should block
  # the connection when the queue is empty. This argument defaults to false.
  def pop(blocking = false)
    if blocking
      redis.brpop(name, TIMEOUT)[1] rescue nil
    else
      redis.rpop(name)
    end
  end

  # Pushes items to the end of the queue.
  def push(*items)
    # Up until Redis 2.3, `rpush` accepts a single value.
    if REDIS_VERSION < '2.3'
      items.each { |item| redis.rpush(name, item) }
    else
      redis.rpush(name, items)
    end
  end
  alias << push

  # Retrieves the first queued item.
  #
  # Takes an optional boolean argument to specify if the command should block
  # the connection when the queue is empty. This argument defaults to false.
  def shift(blocking = false)
    if blocking
      redis.blpop(name, TIMEOUT)[1] rescue nil
    else
      redis.lpop(name)
    end
  end

  # Pushes items to the front of the queue.
  def unshift(*items)
    # Up until Redis 2.3, `rpush` accepts a single value.
    if REDIS_VERSION < '2.3'
      items.each { |item| redis.lpush(name, item) }
    else
      redis.lpush(name, items)
    end
  end

  private

  def redis
    Redis.current
  end
end