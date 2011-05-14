require 'test_helper'

# Maybe TODO: Should the tests require a running redis, mongo, mysql
# instance and actually test getting, setting data?

class StorageTest < Test::Unit::TestCase
  test "mongodb connect!" do
    connection_url ='mongodb://copy:secret@localhost/copy-content'
    Copy::Storage::Mongodb.expects(:new).with(connection_url).returns(true)
    
    assert Copy::Storage.connect!(connection_url)
  end
  
  test "redis connect!" do
    connection_url ='redis://localhost:6379'
    Copy::Storage::Redis.expects(:new).with(connection_url).returns(true)
    
    assert Copy::Storage.connect!(connection_url)
  end
  
  test "mysql connect!" do
    connection_url = 'mysql://localhost/copy_content'
    Copy::Storage::Relational.expects(:new).with(connection_url).returns(true)
    
    assert Copy::Storage.connect!(connection_url)
  end
  
  test "postgres connect!" do
    connection_url = 'postgres://localhost/copy_content'
    Copy::Storage::Relational.expects(:new).with(connection_url).returns(true)
    
    assert Copy::Storage.connect!(connection_url)
  end
  
  test "sqlite connect!" do
    connection_url = 'sqlite:///path/to/copy_content.db'
    Copy::Storage::Relational.expects(:new).with(connection_url).returns(true)
    
    assert Copy::Storage.connect!(connection_url)
  end
  
  test "get and set" do
    connection_url ='redis://localhost:6379'
    Copy::Storage::Redis.expects(:new).with(connection_url).returns(stub(:get => :result1, :set => :result2))
    
    Copy::Storage.connect!(connection_url)
    assert_equal :result1, Copy::Storage.get('name')
    assert_equal :result2, Copy::Storage.set('name', 'content')
  end
end