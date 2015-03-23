require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra/handlebars'
require 'json'

require_relative './lib/reservoir'

helpers Sinatra::Handlebars

get '/' do
  @reservoirs = Reservoir.data.values
  puts @reservoirs
  handlebars :index, locals: {reservoirs: @reservoirs}
end

get '/data/data.json' do
  content_type 'application/json'
  data = Reservoir.data
  JSON.pretty_generate(data)
end