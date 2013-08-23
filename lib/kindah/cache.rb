module Kindah
  class Cache
    def self.[](*args)
      storage[args]
    end

    def self.[]=(*args, last)
      storage[args] = last
    end

    def self.storage
      @storage ||= {}
    end

    def self.clear!
      @storage = {}
    end
  end
end
