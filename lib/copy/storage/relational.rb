require 'data_mapper'

module Copy
  module Storage
    class Relational
      class Document
        include DataMapper::Resource

        property :id,         Serial
        property :name,       String, :unique_index => true
        property :content,    Text  
        property :created_at, DateTime
        property :updated_at, DateTime
      end
      
      def initialize(connection_url)
        DataMapper.setup(:default, connection_url)
        DataMapper.finalize
        DataMapper.auto_upgrade!
      end
      
      def get(name)
        Document.first(:name => name)
      end
      
      def set(name, content)
        doc = Document.first(:name => name)
        if doc
          doc.update(:content => content)
        else
          Document.create(:name => name, :content => content)
        end
      end
    end
  end
end