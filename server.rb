# frozen_string_literal: true

require 'securerandom'
# require 'faye/websocket'
# Webserver handeling all routes
class Server < Sinatra::Base # rubocop:disable Metrics/ClassLength
  Dir['modules/**/*.rb'].each do |file|
    require_relative file
  end

  enable :sessions

  use Faye::RackAdapter, mount: '/faye', timeout: 45

  before do
    SassCompiler.compile
    @error = session[:error]
    session[:error] = nil
  end

  # DEFAULT PAGE
  def initialize
    super
    @clients = [] # Websocket clients
  end

  # Generates a token to be used as identifier when connecting from gosu
  get '/token/:user_id' do
    token = SecureRandom.hex(10)
    DBConnector.connect.execute('INSERT INTO tokens (user_id, token) VALUES (?, ?)',
                                params[:user_id], token)
    token
  end

  # rubocop:disable Metrics/BlockLength

  # Handles gosu based connection
  get '/socket' do
    if Faye::WebSocket.websocket?(request.env)
      ws = Faye::WebSocket.new(request.env)
      ws.on(:open) do |_event|
        puts 'WS connection opened'
      end

      ws.on(:message) do |msg|
        db_data = DBConnector.connect.execute('SELECT * FROM tokens WHERE token = ?', msg.data).first
        begin
          if db_data[1].include? msg.data
            @clients << [ws, db_data[0]]
            if DBConnector.connect.execute('SELECT * FROM current_sessions WHERE user_id = ?',
                                           db_data[0]) == [[nil]] ||
               DBConnector.connect.execute('SELECT * FROM current_sessions WHERE user_id = ?',
                                           db_data[0]) == []
              DBConnector.connect.execute('INSERT INTO current_sessions (user_id) VALUES (?)',
                                          db_data[0])
            end
            Websocket.connection_made
            Websocket.send_message(ws, 'traffic', PublicTransport.get(db_data[0]))
            Websocket.send_message(ws, 'weather', Weather.get(db_data[0]))
            Websocket.send_message(ws, 'calendar', Calendar.retrive(db_data[0]))
            Websocket.store(ws, db_data[0])
            Websocket.send_message(ws, 'test', 'message received')
          else
            ws.close
          end
        rescue StandardError
          print '/socket caused a fatal error'
          ws.close
        end
      end

      ws.on(:close) do |_event|
        pos = ''
        if @clients[0].is_a? Array
          @clients.each_with_index do |client, index|
            next unless client.include? ws

            pos = index
            DBConnector.connect.execute('DELETE FROM current_sessions WHERE user_id = ?',
                                        @clients[index].last)
            Websocket.remove(ws, @clients[index].last)
            @clients.delete_at(pos)
          end
        end
        puts 'WS connection closed'
      end
      ws.rack_response
    else
      slim :index
    end
  end

  # Handles browser based connection
  get '/' do
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
        Websocket.connection_made
        Websocket.send_message(ws, 'traffic', PublicTransport.get(session[:user_id]))
        Websocket.send_message(ws, 'weather', Weather.get(session[:user_id]))
        Websocket.send_message(ws, 'calendar', Calendar.retrive(session[:user_id]))
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
  # rubocop:enable Metrics/BlockLength

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
    if session[:authorized]
      @calendar_authorized = true
      session[:authorized] = false
    else
      @calendar_authorized = false
    end
    @url = session[:url]
    unless @url.nil?
      @url = @url.gsub('&amp;', '')
      @url = @url.gsub(';', '&')
    end
    session[:url] = nil
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
    User.new(params[:name], params[:password], params[:lang], params[:admin], params[:calendar])
    redirect '/admin'
  end

  post '/admin/user/remove' do
    User.remove('id', params[:user_id])
    redirect '/admin'
  end

  calendar = nil

  before '/admin/calendar/url' do
    calendar = Calendar.new
  end

  post '/admin/calendar/url' do
    if calendar.error
      session[:error] = calendar.error
    elsif calendar.url.nil?
      session[:authorized] = true
    else
      session[:authorized] = false
      session[:url] = calendar.url
    end
    redirect '/admin'
  end

  post '/admin/calendar/authorize' do
    begin
      calendar.authorize_2(params['code'])
    rescue StandardError => e
      session[:error] = e.message
    end
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
       DBConnector.connect.execute('SELECT * FROM Location WHERE user_id = ?',
                                   params[:user_id]) != [[nil]]
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
