require 'sinatra/base'
require 'erb'
require 'redcarpet'

module Copy 
  class Server < Sinatra::Base    
    set :views,  './views'
    set :public, './public'
    set :root, File.dirname(File.expand_path(__FILE__))
    
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
        
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Copy Admin Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        return false unless settings.respond_to?(:copy_username) && settings.respond_to?(:copy_password)
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [settings.copy_username, settings.copy_password]
      end
      
      def set_cache_control_header
        if settings.respond_to?(:cache_time) && settings.cache_time.is_a?(Numeric) && settings.cache_time > 0
          expires settings.cache_time, :public
        else
          cache_control :no_cache
        end
      end
      
      def format_text(name, content, options = {})
        original = content.dup
        # Apply markdown formatting.
        content = Redcarpet.new(content, :smart).to_html.chomp
        
        html_attrs = %Q(class="_copy_editable" data-name="#{name}")
        
        if original =~ /\n/ # content with newlines renders in a div
          tag = options[:wrap_tag] || :div
          %Q(<#{tag} #{html_attrs}>#{content}</#{tag}>)
        else # single line content renders in a span without <p> tags
          tag = options[:wrap_tag] || :span
          content.gsub!(/<\/*p>/, '')
          %Q(<#{tag} #{html_attrs}>#{content}</#{tag}>)
        end
      end
      
      def copy(name, options = {}, &block)
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
        
        # Append the output buffer.
        @_out_buf << format_text(name, content, options)
      end
      
      def partial(template)
        template_array = template.to_s.split('/')
        template = template_array[0..-2].join('/') + "/_#{template_array[-1]}.#{@_route.format}"
        send(@_route.renderer, template.to_sym, :layout => false)
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
    
    get '/_copy/?' do
      protected!
      ERB.new(File.read(settings.root + '/admin/index.html.erb')).result(self.send(:binding))
    end
    
    get '/_copy.js' do
      protected!
      content_type(:js)
      ERB.new(File.read(settings.root + '/admin/index.js.erb')).result(self.send(:binding))
    end
    
    get '/_copy/:name' do
      protected!
      @name = params[:name]
      @doc = Copy::Storage.get(params[:name])
      ERB.new(File.read(settings.root + '/admin/edit.html.erb')).result(self.send(:binding))
    end
    
    put '/_copy/:name' do
      protected!
      Copy::Storage.set(params[:name], params[:content])
      format_text(params[:name], Copy::Storage.get(params[:name]), :wrap_tag => params[:wrap_tag])
    end
    
    get '*' do
      @_route = Copy::Router.new(params[:splat].first, settings.views)
      if @_route.success?
        set_cache_control_header
        content_type(@_route.format)
        send(@_route.renderer, @_route.template, :layout => @_route.layout)
      else
        not_found
      end
    end
  end
end