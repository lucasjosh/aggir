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
      
      def get(key)
        REDIS[key]
      end
      
      def delete(key)
        REDIS.delete(key)
      end
      
      def push_to_front(key, value)
        REDIS.push_head(key, value)
      end
      
      def push_to_end(key, value)
        REDIS.push_tail(key, value)
      end
      
      def get_next_id(key)
        REDIS.set_unless_exists key, 1000
        REDIS.incr key        
      end
    end
  end
end