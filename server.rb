# frozen_string_literal: true

require 'sinatra'
require 'slim'
require 'json'
Dir['modules/**/*.rb'].each do |file|
  require_relative file
end

set :bind, '0.0.0.0'

get '/' do
  # before do
  SassCompiler.compile
  # end
  slim :index
end

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
