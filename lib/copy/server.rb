require 'sinatra/base'

module Copy 
  class Server < Sinatra::Base
    enable :sessions
    set :views,  File.dirname(__FILE__) + '/views'
    set :public, File.dirname(__FILE__) + '/public'
    
    def self.config(&block)
      class_eval(&block)
    end
    
    get '/admin/?' do
      "admin"
    end
    
    get '*' do
      route = Copy::Router.new(params[:splat].to_s, settings.views)
      send(route.renderer, route.template)
    end
  end
end