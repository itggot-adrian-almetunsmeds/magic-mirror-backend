# frozen_string_literal: true

require 'securerandom'
# require 'faye/websocket'
# Webserver handeling all routes
class Server < Sinatra::Base
  Dir['modules/**/*.rb'].each do |file|
    require_relative file
  end

  enable :sessions

  use Faye::RackAdapter, mount: '/faye', timeout: 45

  before do
    SassCompiler.compile
  end

  # DEFAULT PAGE
  def initialize
    super
    @clients = [] # Websocket clients
  end

  get '/token/:user_id' do
    token = SecureRandom.hex(10)
    DBConnector.connect.execute('INSERT INTO tokens (user_id, token) VALUES (?, ?)', params[:user_id], token)
    token
  end

  get '/socket' do
    if Faye::WebSocket.websocket?(request.env)
      ws = Faye::WebSocket.new(request.env)
      ws.on(:open) do |_event|
        puts "WS connection opened by user #{session[:user_id]}"
      end

      ws.on(:message) do |msg|
        db_data = DBConnector.connect.execute('SELECT * FROM tokens WHERE token = ?', msg.data).first
        if db_data[1].include? msg.data
          @clients << [ws, db_data[0]]
          if DBConnector.connect.execute('SELECT * FROM current_sessions WHERE user_id = ?',
                                         db_data[0]) == [[nil]] ||
             DBConnector.connect.execute('SELECT * FROM current_sessions WHERE user_id = ?',
                                         db_data[0]) == []
            DBConnector.connect.execute('INSERT INTO current_sessions (user_id) VALUES (?)',
                                        db_data[0])
          end
          Websocket.send_message(ws, 'traffic', PublicTransport.get(db_data[0]))
          Websocket.send_message(ws, 'weather', [Weather.get(db_data[0])])
          Websocket.store(ws, db_data[0])
          Websocket.send_message(ws, 'test', 'message received')
        else
          ws.close
        end
      end

      ws.on(:close) do |_event|
        p @clients[0].last
        # TODO [#26]: When closing the connection the server crashes
        #
        # When disconnecting the user_id has to be retrived from the @client list
        # and then with use it to remove the client and remove the client from the list of active sessions.
        # Reletade to #22
        if @clients[0].is_a? Array
          @clients.each do |client|
            p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            p client
            p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            data = client if client.include? ws
          end
        else
          data = @clients if client[0] == ws
        end
        p "THIS IS DATA#{data}"
        @clients.delete(data)
        DBConnector.connect.execute('DELETE FROM current_sessions WHERE user_id = ?', data[-1])
        puts 'WS connection closed'
        Websocket.remove(ws, data[-1])
      end

      ws.rack_response
    else
      slim :index
    end
  end
  get '/' do
    # TODO [#22]: Verify user session if connecting from gosu front end
    #
    # Currently the cookie is not present and there by redirects the user before establishing ws
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    p "Session ID: #{session.id}"
    p "Cookie:     #{request.cookies}"
    p "User ID:    #{session[:user_id]}"
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    redirect '/login' unless session[:user_id]
    if Faye::WebSocket.websocket?(request.env)
      ws = Faye::WebSocket.new(request.env)
      ws.on(:open) do |_event|
        @clients << [ws, session[:user_id]]
        if DBConnector.connect.execute('SELECT * FROM current_sessions WHERE user_id = ?',
                                       session[:user_id]) == [[nil]] ||
           DBConnector.connect.execute('SELECT * FROM current_sessions WHERE user_id = ?',
                                       session[:user_id]) == []
          DBConnector.connect.execute('INSERT INTO current_sessions (user_id) VALUES (?)',
                                      session[:user_id])
        end
        puts "WS connection opened by user #{session[:user_id]}"
        Websocket.send_message(ws, 'traffic', PublicTransport.get(session[:user_id]))
        Websocket.send_message(ws, 'weather', [Weather.get(session[:user_id])])
        Websocket.store(ws, session[:user_id])
      end

      ws.on(:message) do |msg|
        p msg.data
        Websocket.send_message(ws, 'test', 'message received')
      end

      ws.on(:close) do |_event|
        @clients.delete([ws, session[:user_id]])
        DBConnector.connect.execute('DELETE FROM current_sessions WHERE user_id = ?', session[:user_id])
        puts 'WS connection closed'
        Websocket.remove(ws, session[:user_id])
      end

      ws.rack_response
    else
      slim :index
    end
  end

  before '/admin*' do |s|
    unless s == '/login'
      if session[:user_id].nil? ||
         DBConnector.connect.execute('SELECT type FROM Users where id = ?',
                                     session[:user_id])[0][0] != 'admin'
        redirect '/admin/login'
      end
    end
  end

  # ADMIN PAGES

  get '/admin' do
    if !session[:stops].nil?
      @transit = PublicTransport.stopID(session[:stops])
      session[:stops] = nil
    else
      @transit = nil
    end
    slim :admin
  end

  post '/admin/public-transit/update' do
    PublicTransport.stop_add(params[:name], params[:stop_id], params[:user_id])
    redirect '/admin'
  end

  post '/admin/public-transit/new' do
    PublicTransport.stop_add(params[:name], params[:stop_id], params[:user_id])
    redirect '/admin'
  end

  post '/admin/public-transit/stops' do
    session[:stops] = params['querry']
    redirect '/admin'
  end

  post '/admin/api/update' do
    DBConnector.connect.execute('UPDATE ApiKeys SET reseplanerare = ?, stolptidstabeller = ?',
                                params['reseplanerare'], params['stolptidstabeller'])
    redirect '/admin'
  end

  post '/admin/api/new' do
    DBConnector.connect.execute('INSERT INTO ApiKeys (reseplanerare, stolptidstabeller) VALUES (?, ?)',
                                params['reseplanerare'], params['stolptidstabeller'])
    redirect '/admin'
  end

  post '/admin/api/location/update' do
    DBConnector.connect.execute('UPDATE Location SET county = ?, lat = ?, long = ?, user_id = ?',
                                params['county'], params['lat'], params['long'], params['user_id'])
    redirect '/admin'
  end

  post '/admin/api/location/new' do
    DBConnector.connect.execute('INSERT INTO Location (county, lat, long, user_id) VALUES (?, ?, ?, ?)',
                                params['county'], params['lat'], params['long'], params['user_id'])
    redirect '/admin'
  end

  post '/admin/user/new' do
    User.new(params[:name], params[:password], params[:lang], params[:admin])
    redirect '/admin'
  end

  post '/admin/user/remove' do
    User.remove('id', params[:user_id])
    redirect '/admin'
  end

  # Signing in to the admin page

  get '/admin/login' do
    @title = 'Admin configuartion'
    @action = '/admin/login'
    slim :login
  end

  post '/admin/login' do
    @user = User.login(params[:name], params[:password])
    if @user.is_a? Integer
      session[:user_id] = @user
      redirect '/admin'
    else
      session[:user_id] = nil
      redirect '/admin/login'
    end
  end

  post '/admin/signout' do
    session[:user_id] = nil
  end

  # NON ADMIN PAGES

  get '/login' do
    @title = 'Sign in'
    @action = '/login'
    slim :login
  end

  post '/login' do
    p "Session ID Login: #{session.id}"
    @user = User.login(params[:name], params[:password])
    if @user.is_a? Integer
      session[:user_id] = @user
      redirect '/'
    else
      session[:user_id] = nil
      redirect '/login'
    end
  end

  get '/api/translations/:language_id' do
    Translation.get(params[:language_id]).to_json
  end

  get '/api/translations/:language_id/:component' do
    Translation.get_component(params[:language_id], params[:component])
  end

  get '/api/weather/:user_id' do
    if params[:user_id] &&
       !DBConnector.connect.execute('SELECT * FROM Location WHERE user_id = ?', params[:user_id]).nil? &&
       DBConnector.connect.execute('SELECT * FROM Location WHERE user_id = ?', params[:user_id]) != [[nil]]
      db = DBConnector.connect
      db.results_as_hash = true
      x = db.execute('SELECT lat, long FROM Location WHERE user_id = ?', params[:user_id]).first
      Weather.current(x['lat'], x['long']).to_json
    else
      return 'No results'
    end
  end

  get '/js/application.js' do
    content_type :js
    @scheme = ENV['RACK_ENV'] == 'production' ? 'wss://' : 'ws://'
    erb :'websocket.js'
  end

  not_found do
    slim :error
  end
end
