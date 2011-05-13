require 'mongo'
require 'bson_ext'
require 'uri'

module Copy
  module Storage
    class Mongodb
      def initialize(connection_url)
        uri  = URI.parse(connection_url)
        conn = ::Mongo::Connection.from_uri(connection_url)
        db   = conn.db(uri.path.gsub(/^\//, ''))
        @collection = db['copy-content']
        @collection.ensure_index([['name', Mongo::ASCENDING]], :unique => true)
        @collection
      end
      
      def get(name)
        doc = @collection.find('name' => name)
        doc['content'] unless doc.nil?
      end
      
      def set(name, content)
        @collection.insert('name' => name, 'content' => content)
      end
    end
  end
end