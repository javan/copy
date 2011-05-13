require 'uri'

module Copy
  module Storage
    autoload :Mongodb, 'copy/storage/mongodb'
    autoload :Redis,   'copy/storage/redis'
    
    def self.connect!(connection_url)
      uri = URI.parse(connection_url)
      @@storage = Copy::Storage.const_get(uri.scheme.capitalize).new(connection_url)
    end
    
    def self.get(name)
      @@storage.get(name)
    end
    
    def self.set(name, content)
      @@storage.set(name, content)
    end
  end
end