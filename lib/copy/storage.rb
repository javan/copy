require 'uri'

module Copy
  module Storage
    autoload :Mongodb,    'copy/storage/mongodb'
    autoload :Redis,      'copy/storage/redis'
    autoload :Relational, 'copy/storage/relational'
    
    def self.connect!(connection_url)
      scheme = URI.parse(connection_url).scheme
      klass  = scheme.capitalize
      if %w(sqlite mysql postgres).include?(scheme)
        klass = 'Relational'
      end
      @@storage = Copy::Storage.const_get(klass).new(connection_url)
    end
    
    def self.connected?
      !defined?(@@storage).nil?
    end
    
    def self.get(name)
      @@storage.get(name.to_s)
    end
    
    def self.set(name, content)
      @@storage.set(name.to_s, content)
    end
  end
end