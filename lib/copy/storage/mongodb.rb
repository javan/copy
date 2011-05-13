require 'mongo'
require 'uri'

module Copy
  module Storage
    class Mongodb
      def initialize(connection_url)
        uri         = URI.parse(connection_url)
        connection  = ::Mongo::Connection.from_uri(connection_url)
        database    = connection.db(uri.path.gsub(/^\//, ''))
        
        @collection = database['copy-content']
        @collection.ensure_index([['name', Mongo::ASCENDING]], :unique => true)
        @collection
      end
      
      def get(name)
        doc = find(name)
        doc['content'] unless doc.nil?
      end
      
      def set(name, content)
        doc = find(name)
        if doc
          doc['content'] = content
          @collection.update({ '_id' => doc['_id'] }, doc)
        else
          @collection.insert('name' => name, 'content' => content)
        end
      end
      
      private
        def find(name)
          docs = @collection.find('name' => name)
          docs.first if docs.respond_to?(:first)
        end
    end
  end
end