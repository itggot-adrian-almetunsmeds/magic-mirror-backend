# frozen_string_literal: true

require 'sinatra'
require 'slim'
Dir['modules/**/*.rb'].each do |f|
  require_relative f
end

set :bind, '0.0.0.0'

get '/' do
  before do
    SassCompiler.compile
  end
  slim :index
end

# namespace '/api/v1' do
#   before do
#     content_type 'application/json'
#   end

#   get '/weather' do
#     return text.to_json
#   end

#   get '/version/:id' do |_id|
#     json({ foo: 'bar' }, encoder: :to_json, content_type: :js)
#   end
# end

not_found do
  status 404
end
