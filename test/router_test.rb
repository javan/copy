require 'test_helper'

class RouterTest < Test::Unit::TestCase
  test "format defaults to html" do
    assert_equal :html, router('/something').format
    assert_equal :html, router('/a/b/c/').format
  end
  
  test "recognize format in path" do
    assert_equal :html, router('/something.html').format
    assert_equal :html, router('/about/something.html').format
    assert_equal :xml,  router('/index.xml').format
    assert_equal :csv,  router('/employees.csv').format
    assert_equal :rss,  router('/news/feed.rss').format
  end
  
  test "find template file" do
    Dir.expects(:glob).with('./views/about.html*').twice.returns(['./views/about.html.erb'])
    
    assert_equal './views/about.html.erb', router('/about', './views').template_file
    assert_equal './views/about.html.erb', router('/about.html', './views').template_file
  end
  
  test "find template file as index in dir" do
    Dir.expects(:glob).with('./views/about.html*').returns([])
    Dir.expects(:glob).with('./views/about/index.html*').returns(['./views/about/index.html.erb'])
    
    assert_equal './views/about/index.html.erb', router('/about', './views').template_file
  end
  
  test "find template file as index in dir when path has trailing slash" do
    Dir.expects(:glob).with('./views/about/us.html*').returns([])
    Dir.expects(:glob).with('./views/about/us/index.html*').returns(['./views/about/us/index.html.erb'])
    
    assert_equal './views/about/us/index.html.erb', router('/about/us/', './views').template_file
  end
  
  test "find template file in dir when path has trailing slash" do
    Dir.expects(:glob).with('./views/about/us.html*').returns(['./views/about/us.html.erb'])
    
    assert_equal './views/about/us.html.erb', router('/about/us/', './views').template_file
  end
  
  test "find index template file when empty path given" do
    Dir.expects(:glob).with('./views/index.html*').returns(['./views/index.html.erb'])
    
    assert_equal './views/index.html.erb', router('/', './views').template_file
  end
  
  test "renderer determined from template file extension" do
    r1 = router('/about')
    r1.expects(:template_file).returns('about.html.erb')
    assert_equal :erb, r1.renderer
    
    r2 = router('/about')
    r2.expects(:template_file).returns('about.html.haml')
    assert_equal :haml, r2.renderer
  end
  
  test "template determined from template file" do
    r1 = router('/about', './views')
    r1.expects(:template_file).at_least_once.returns('./views/about.html.erb')
    assert_equal :'about.html', r1.template
    
    r2 = router('/about/nothing.html', './views')
    r2.expects(:template_file).at_least_once.returns('./views/about/nothing.html.erb')
    assert_equal :'about/nothing.html', r2.template
  end
  
  test "layout for html format and presense of layout file" do
    r = router('/about', './views')
    r.expects(:template_file).returns('./views/about.html.erb')
    File.expects(:exists?).with('./views/layout.html.erb').returns(true)
    
    assert_equal :'layout.html', r.layout
  end
  
  test "layout is false when no layout file is found" do
    r = router('/about', './views')
    r.expects(:template_file).returns('./views/about.html.erb')
    File.expects(:exists?).with('./views/layout.html.erb').returns(false)
    
    assert_equal false, r.layout
  end
  
  test "layout is false with non-html format" do
    r = router('/people.csv', './views')
    assert_equal false, r.layout
  end
  
  test "success when template file found" do
    Dir.expects(:glob).with('./views/about.html*').returns(['./views/about.html.erb'])
    
    assert router('/about', './views').success?
  end
  
  test "no success when template file not found" do
    Dir.expects(:glob).with('./views/about.html*').returns([])
    Dir.expects(:glob).with('./views/about/index.html*').returns([])
    
    assert !router('/about', './views').success?
  end

  private
    def router(path, views = '')
      Copy::Router.new(path, views)
    end
end