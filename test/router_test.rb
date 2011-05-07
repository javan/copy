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
    r1 = router('/about')
    r1.expects(:template_file).at_least_once.returns('./views/about.html.erb')
    assert_equal :'about.html', r1.template
    
    r2 = router('/about/nothing.html')
    r2.expects(:template_file).at_least_once.returns('./views/about/nothing.html.erb')
    assert_equal :'nothing.html', r2.template
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