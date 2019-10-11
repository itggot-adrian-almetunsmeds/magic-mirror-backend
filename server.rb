# frozen_string_literal: true

require 'sinatra'
# require 'sinatra/cookies'
require 'slim'
require 'json'
Dir['modules/**/*.rb'].each do |f|
  require_relative f
end

set :bind, '0.0.0.0'
enable :sessions

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
  redirect '/admin'
end

post '/post/user/new' do
  User.new(params[:name], params[:password])
  redirect '/admin'
end
post '/post/user/remove' do
  User.remove('id', params[:user_id])
  redirect '/admin'
end

# Signing in to the admin page
get '/admin/login' do
  params[:username]
  params[:password]
  slim :login
end
post '/post/login' do
  p session
  @user = User.login(params[:name], params[:password])
  if @user.is_a? Integer
    session[:user_id] = @user
    redirect '/admin'
  else
    session[:user_id] = nil
    redirect '/admin/login'
  end
end
post '/post/signout' do
  session[:user_id] = nil
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
