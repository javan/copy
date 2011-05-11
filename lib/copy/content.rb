module Copy
  class Content
    include MongoMapper::Document
    
    key :name, String, :required => true
    key :body, String
    timestamps!
  end
end