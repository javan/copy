require 'test_helper'
require 'rack/test'

class ServerTest < Test::Unit::TestCase
  include CopyAppSetup
  include Rack::Test::Methods
  
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
  
  test "connects to storage when setting present" do
    connection_url = 'redis://localhost:1234'
    app.config { set :storage, connection_url }
    Copy::Storage.expects(:connect!).with(connection_url).once.returns(true)
    get '/'
    assert last_response.ok?
  end
end

class ServerCopyHelperTest < Test::Unit::TestCase
  include CopyAppSetup
  include Rack::Test::Methods
  
  test "copy helper displays content from storage" do
    Copy::Storage.stubs(:connected?).returns(true)
    Copy::Storage.expects(:get).with(:facts).returns("truth")
    
    get 'with_copy_helper'
    assert last_response.ok?
    assert_match "truth", last_response.body
  end
  
  test "copy helper saves defaults text when content is not in storage and renders it" do
    Copy::Storage.stubs(:connected?).returns(true)
    Copy::Storage.expects(:get).with(:facts).returns(nil)
    Copy::Storage.expects(:set).with(:facts, "_Default Text_\n").returns(true)
    
    get 'with_copy_helper'
    assert last_response.ok?, last_response.errors
    assert_match %Q(<div class="_copy_editable" data-name="facts"><p><em>Default Text</em></p></div>), last_response.body
  end
  
  test "copy helper shows default text when not connected" do
    Copy::Storage.expects(:connected?).twice.returns(false)
    
    get 'with_copy_helper'
    assert last_response.ok?
    assert_match %Q(<div class="_copy_editable" data-name="facts"><p><em>Default Text</em></p></div>), last_response.body
  end
  
  test "copy helper renders single line content correctly" do
    Copy::Storage.expects(:connected?).twice.returns(false)
    
    get 'with_copy_helper_one_line'
    assert last_response.ok?
    assert_match %Q(<span class="_copy_editable" data-name="headline">Important!</span>), last_response.body
  end
  
  test "copy helper indented in view" do
    Copy::Storage.stubs(:connected?).returns(true)
    Copy::Storage.expects(:get).with(:three).returns(nil)
    Copy::Storage.expects(:set).with(:three, "three\n").returns(true)
    
    get 'indented'
    assert last_response.ok?, last_response.errors
    assert_match %Q(<div class="_copy_editable" data-name="three"><p>three</p></div>), last_response.body
  end
  
  test "partial rendering" do
    get 'renders_partials'
    assert last_response.ok?, last_response.errors
    assert_match "before\none\ntwo\nthree\nafter", last_response.body
  end
end

class ServerAdminTest < Test::Unit::TestCase
  include CopyAppSetup
  include Rack::Test::Methods
  
  test "GET /_copy is protected when no user/pass are set" do
    get '/_copy'
    assert_equal 401, last_response.status
  end
  
  test "GET /_copy protected when user/pass are set, but supplied incorrectly" do
    setup_auth 'good', 'girl'
    authorize 'bad', 'boy'
    get '/_copy'
    assert_equal 401, last_response.status
  end
  
  test "GET /_copy with valid credentials" do
    authorize!
    get '/_copy'
    assert last_response.ok?
    assert_match 'Edit Copy', last_response.body
  end
  
  test "GET /_copy.js" do
    authorize!
    get '/_copy.js'
    assert last_response.ok?, last_response.errors
    assert_match 'jQuery JavaScript Library', last_response.body
  end
  
  test "GET /_copy/:name" do
    Copy::Storage.stubs(:connected?).returns(true)
    Copy::Storage.expects(:get).with('fun').returns("<b>party\n")
    
    authorize!
    get '/_copy/fun'
    assert last_response.ok?, last_response.errors
    assert_match "&lt;b&gt;party\n</textarea>", last_response.body
  end
  
  test "PUT /_copy/:name" do
    Copy::Storage.stubs(:connected?).returns(true)
    Copy::Storage.expects(:set).with('fun', '_party_').returns(true)
    Copy::Storage.expects(:get).with('fun').returns('_party_')
    
    authorize!
    put '/_copy/fun', :content => '_party_', :wrap_tag => 'article'
    assert last_response.ok?, last_response.errors
    assert_match %Q(<article class="_copy_editable" data-name="fun"><em>party</em></article>), last_response.body
  end
end