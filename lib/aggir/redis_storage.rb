module Aggir
  class RedisStorage
    REDIS = Redis.new
  
  
    class << self
      def all(key, klass)
        latest(key, klass, 0, -1)
      end
      
      def latest(key, klass, start, finish)
        ret = Array.new
        t_all = REDIS.list_range(key, start, finish)
        t_all.each do |t|
          ret << klass.send(:find_by_hash, t)
        end
        ret              
      end
      
      def exists?(key)
        REDIS.key?(key)
      end
      
      def save(key, value)
        REDIS[key] = value
      end
    end
  end
end