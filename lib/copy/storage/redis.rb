require 'redis'

module Copy
  module Storage
    class Redis
      def initialize(connection_url)
        @redis = ::Redis.new(connection_url)
      end
      
      def get(name)
        @redis.get("copy:content:#{name}")
      end
      
      def set(name, content)
        @redis.set("copy:content:#{name}", content)
      end
    end
  end
end
