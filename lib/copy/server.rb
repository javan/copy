require 'sinatra/base'
require 'erb'
require 'redcarpet'

module Copy 
  class Server < Sinatra::Base
    enable :sessions
    
    set :views,  './views'
    set :public, './public'
    set :root, File.dirname(File.expand_path(__FILE__))
    set :text_formatting, :markdown
    
    helpers do
      def set_cache_control_header
        if settings.respond_to?(:cache_time) && settings.cache_time.is_a?(Numeric) && settings.cache_time > 0
          expires settings.cache_time, :public
        else
          cache_control :no_cache
        end
      end
      
      def copy(name, options = {}, &block)
        options[:wrap_tag] ||= :div
        if !Copy::Storage.connected? || !(content = Copy::Storage.get(name))
          # Side-step the output buffer so we can capture the block, but not output it.
          @_out_buf, old_buffer = '', @_out_buf
          content = yield
          @_out_buf = old_buffer
          
          # Get the first line from captured text.
          first_line = content.split("\n").first
          # Determine how much white space it has in front.
          white_space = first_line.match(/^(\s)*/)[0]
          # Remove that same amount of white space from the beginning of every line.
          content.gsub!(Regexp.new("^#{white_space}"), '')
          
          # Save the content so it can be edited.
          Copy::Storage.set(name, content) if Copy::Storage.connected?
        end
        
        # Apply markdown formatting.
        if settings.text_formatting == :markdown
          content = Redcarpet.new(content, :smart).to_html
        end
        
        # Append the output buffer.
        @_out_buf << %Q(<#{options[:wrap_tag]} class="_copy_editable" data-name="#{name}">#{content}</#{options[:wrap_tag]}>)
      end
    end
    
    def self.config(&block)
      class_eval(&block)
    end
    
    before do
      if settings.respond_to?(:storage) && !Copy::Storage.connected?
        Copy::Storage.connect!(settings.storage)
      end
    end
    
    get '_copy/?' do
      ERB.new(File.read(File.join(settings.root, 'admin', 'index.html.erb'))).result(self.send(:binding))
    end
    
    get '_copy/:name' do
      @doc = Copy::Storage.get(params[:name])
      ERB.new(File.read(File.join(settings.root, 'admin', 'edit.html.erb'))).result(self.send(:binding))
    end
    
    put '_copy/:name' do
      Copy::Storage.set(params[:name], params[:content])
    end
    
    get '*' do
      route = Copy::Router.new(params[:splat].first, settings.views)
      if route.success?
        set_cache_control_header
        content_type(route.format)
        send(route.renderer, route.template, :layout => route.layout)
      else
        not_found
      end
    end
  end
end