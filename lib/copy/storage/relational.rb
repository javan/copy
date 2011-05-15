require 'data_mapper'

module Copy
  module Storage
    class Relational
      class Document
        include DataMapper::Resource
        
        storage_names[:default] = 'copy_documents'
    
        property :id,         Serial
        property :name,       String, :unique_index => true
        property :content,    Text
      end
      
      def initialize(connection_url)
        DataMapper.setup(:default, connection_url)
        DataMapper.finalize
        DataMapper.auto_upgrade!
      end
      
      def get(name)
        doc = Document.first(:name => name)
        doc.content unless doc.nil?
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