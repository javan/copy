require 'sinatra/base'

module Copy 
  class Server < Sinatra::Base
    enable :sessions
    
    set :views,  './views'
    set :public, './public'
    
    helpers do
      def copy(name, &block)
        if content = Copy::Content.find(:name => name)
          if template && template.respond_to?(:is_haml?) && template.is_haml?
            template.haml_concat(content)
          else
            @_out_buf << content
          end
        else
          # Render the default text in the block
          block.call if block_given?
        end
      end
    end
    
    def self.config(&block)
      class_eval(&block)
    end
    
    get '/admin/?' do
      "admin"
    end
    
    get '*' do
      route = Copy::Router.new(params[:splat].to_s, settings.views)
      if route.success?
        send(route.renderer, route.template, :layout => route.layout)
      else
        halt 404
      end
    end
  end
end