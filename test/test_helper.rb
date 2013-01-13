dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'rubygems'
require 'test/unit'
begin
  require 'turn'
rescue LoadError
end
require 'mocha/setup'
require 'copy'

class Test::Unit::TestCase
  def self.test(name, &block)
    define_method("test_#{name.gsub(/\W/,'_')}", &block) if block
  end

  def self.setup(&block)
    define_method(:setup, &block)
  end

  def self.teardown(&block)
    define_method(:teardown, &block)
  end
end

module CopyAppSetup
  def app
    Copy::Server
  end

  def setup
    app.config do
      set :views, File.dirname(File.expand_path(__FILE__)) + '/test_app/views'
    end
  end

  def setup_auth(user, pass)
    app.config do
      set :copy_username, user
      set :copy_password, pass
    end
  end

  def authorize!
    setup_auth 'super', 'secret'
    authorize  'super', 'secret'
  end
end