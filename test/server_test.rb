require 'test_helper'
require 'rack/test'

class ServerTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Copy::Server.config do
      set :views, File.dirname(File.expand_path(__FILE__)) + '/sample_app/views'
    end
  end
  
  test "GET index" do
    get '/'
    
    assert last_response.ok?
    assert_equal 'text/html;charset=utf-8', last_response.headers['Content-Type']
    assert_match "<title>I'm the layout!</title>", last_response.body
    assert_match "<p>I'm the index!</p>", last_response.body
  end
  
  test "GET path with index in folder" do
    %w(/about /about/).each do |path|
      get path
      
      assert last_response.ok?
      assert_match "<p>About!</p>", last_response.body
    end
  end
  
  test "GET path to template in folder" do
    %w(/about/us /about/us/).each do |path|
      get path
      
      assert last_response.ok?
      assert_match "<p>About us!</p>", last_response.body
    end
  end
  
  test "GET non-existent path" do
    get '/nope'
    assert last_response.status == 404
  end
  
  test "cache_time setting sets a Cache-Control header" do
    app.config { set :cache_time, 456 }
    get '/'
    assert_equal 'public, max-age=456', last_response.headers['Cache-Control']
    
    [0, nil, false].each do |time|
      app.config { set :cache_time, time }
      get '/'
      assert_equal 'no-cache', last_response.headers['Cache-Control']
    end
  end
  
  test "GET csv" do
    get 'data/people.csv'
    
    assert last_response.ok?
    assert_equal 'text/csv;charset=utf-8', last_response.headers['Content-Type']
    assert_equal File.read(app.settings.views + '/data/people.csv.erb'), last_response.body
  end
  
  test "GET xml" do
    get 'data/people.xml'
    
    assert last_response.ok?
    assert_equal 'application/xml;charset=utf-8', last_response.headers['Content-Type']
    assert_equal File.read(app.settings.views + '/data/people.xml.erb'), last_response.body
  end
end