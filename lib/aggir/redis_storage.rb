module Aggir
  class RedisStorage
    REDIS = Redis.new
  
  
    class << self
      def all(key, klass)
        ret = Array.new
        t_all = REDIS.list_range(key, 0, -1)
        t_all.each do |t|
          ret << klass.send(:find_by_hash, t)
        end
        ret      
      end
    end
  end
end