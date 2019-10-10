# frozen_string_literal: true

require 'sinatra'
require 'slim'
require 'json'
Dir['modules/**/*.rb'].each do |f|
  require_relative f
end

set :bind, '0.0.0.0'
# DEFAULT PAGE
get '/' do
  # before do
  SassCompiler.compile
  # end
  slim :index
end

# ADMIN PAGES
get '/admin' do
  SassCompiler.compile
  slim :admin
end
post '/post/public-transit/new' do
  PublicTransport.stop_add(params[:name], params[:stop_id], params[:user_id])
end
post '/post/user/new' do
  User.new(params[:name])
end

# NON ADMIN PAGES
get '/api/translations/:language_id' do
  JSON.parse(File.read("translations/#{params[:language_id]}.json")).to_json
end

get '/api/translations/:language_id/:component' do
  translations = JSON.parse(File.read("translations/#{params[:language_id]}.json"))
  translations[params[:component]].to_json
end

not_found do
  status 404
end
