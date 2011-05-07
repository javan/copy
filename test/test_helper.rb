dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'test/unit'
require 'rubygems'
require 'mocha'
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