require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra/handlebars'
require 'json'

require_relative './lib/reservoir'

helpers Sinatra::Handlebars

configure do
  set :cache, nil
end

configure :production do
  set :cache, Dalli::Client.new((ENV["MEMCACHIER_SERVERS"] || "").split(","),
                    {:username => ENV["MEMCACHIER_USERNAME"],
                     :password => ENV["MEMCACHIER_PASSWORD"],
                     :failover => true,
                     :socket_timeout => 1.5,
                     :socket_failure_delay => 0.2, 
                     :expires_in => 60 * 60 * 24
                    })
end

helpers do
  def reservoirs
    if settings.cache
      reservoirs = settings.cache.get('reservoirs.data')
      unless reservoirs
        reservoirs = Reservoir.data.values
        settings.cache.set('reservoirs.data', reservoirs)
      end
      reservoirs
    else
      puts("no cahce")
      Reservoir.data.values
    end
  end
end

get '/' do
  handlebars :index, locals: {reservoirs: reservoirs}
end

get '/data/data.json' do
  content_type 'application/json'
  JSON.pretty_generate(reservoirs)
end