require 'mongo_mapper'

module Copy
  class Storage
    def self.connect!(mongo_url = ENV['MONGOHQ_URL'])
      if mongo_url
        MongoMapper.config = { RACK_ENV => { 'uri' => mongo_url } }
      else
        MongoMapper.config = { RACK_ENV => { 'uri' => 'mongodb://localhost/copy'} }
      end

      MongoMapper.connect(RACK_ENV)
      Copy::Content.ensure_index [[:name, 1]], :unique => true
    end
  end
end