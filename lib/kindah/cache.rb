module Kindah
  class Cache
    extend Forwardable

    def self.[](*args)
      storage[args]
    end

    def self.[]=(*args, last)
      storage[args] = last
    end

    def self.storage
      @storage ||= {}
    end
  end
end
