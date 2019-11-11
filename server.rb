# frozen_string_literal: true

# require 'faye/websocket'
# rubocop:disable Metrics/ClassLength
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

  # rubocop:disable Metrics/BlockLength
  get '/' do
    # FIXME: TODO: Verify user session if connecting from gosu front end
    #
    # Currently the cookie is not present and there by redirects the user before establishing ws

    # FIXME: TODO: Server crashes on attempted connection to ws
    #
    # Error message:
    # ```
    # "Connection: close\r\n", "Server: thin\r\n"]>, @status=304, @persistent=true,
    # @skip_body=false, @body=[]>, @backend=#<Thin::Backends::TcpServer:0x0000000008386758 ...>,
    # @app=Server, @threaded=nil, @can_persist=true, @serving=nil, @idle=false>, 44986000=>
    # #<Thin::Connection:0x00000000055cdd20 ...>, 54047880=>#<Thin::Connection:0x0000000006716910
    #  @signature=17, @request=#<Thin::Request:0x0000000006714b60 @parser=#<Thin::HttpParser:
    #  0x0000000006714750>, @data="", @nparsed=0, @body=#<StringIO:0x0000000006714520>,
    #  @env={"SERVER_SOFTWARE"=>"thin 1.7.2 codename Bachmanity", "SERVER_NAME"=>"localhost",
    #  "rack.input"=>#<StringIO:0x0000000006714520>, "rack.version"=>[1, 0], "rack.errors"=>
    #  #<IO:<STDERR>>, "rack.multithread"=>false, "rack.multiprocess"=>false,
    #  "rack.run_once"=>false}>, @response=#<Thin::Response:0x00000000067140e8
    #  @headers=#<Thin::Headers:0x00000000067140c0 @sent={}, @out=[]>, @status=200,
    #  @persistent=false, @skip_body=false>, @backend=#<Thin::Backends::TcpServer:
    #  0x0000000008386758 ...>, @app=Server, @threaded=nil, @can_persist=true>},
    #  @timeout=30, @persistent_connection_count=4, @maximum_connections=1024,
    #  @maximum_persistent_connections=100, @no_epoll=false, @ssl=nil, @threaded=nil,
    #   @started_reactor=true, @server=#<Thin::Server:0x0000000008386898 @app=Server,
    #   @tag=nil, @backend=#<Thin::Backends::TcpServer:0x0000000008386758 ...>,
    #  @setup_signals=true, @signal_queue=[], @signal_timer=#<EventMachine::PeriodicTimer
    #  :0x0000000008385bf0 @interval=1, @code=#<Proc:0x0000000008385c18@C:/Ruby25-x64/lib
    #  /ruby/gems/2.5.0/gems/thin-1.7.2/lib/thin/server.rb:244>, @cancelled=false,
    #  @work=#<Method: EventMachine::PeriodicTimer#fire>>>, @stopping=false, @signature=2,
    #  @running=true>, @app=Server, @threaded=nil, @can_persist=true, @serving=:websocket,
    #  @idle=false, @socket_stream=#<Faye::WebSocket::Stream:0x00000000067b8c38 ...>>,
    #  @stream_send=#<Proc:0x00000000067b8490@C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/
    #  thin-1.7.2/lib/thin/response.rb:96>, @rack_hijack_io_reader=nil,
    #  @rack_hijack_io=nil, @deferred_status=:unknown, @callbacks=[#<Proc:0x000000000671c0b8
    #  @C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/thin-1.7.2/lib/thin/connection.rb:126>,
    #  #<Proc:0x00000000067b81e8@C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/thin-1.7.2/lib/thin/
    #  connection.rb:126>], @errbacks=[#<Proc:0x000000000671c090@C:/Ruby25-x64/lib/ruby/gems/2
    #  .5.0/gems/thin-1.7.2/lib/thin/connection.rb:127>, #<Proc:0x00000000067b3da0@C:/Ruby25-
    #  x64/lib/ruby/gems/2.5.0/gems/thin-1.7.2/lib/thin/connection.rb:127>]>,
    #  @proxy=nil, @ping_timer=nil, @close_timer=nil, @close_params=nil, @onerror=nil,
    #  @onclose=nil, @onmessage=nil, @onopen=nil, @driver_started=true, @event_buffers={}>
    #  is not a symbol nor a string (TypeError)
    # ```
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
        Websocket.send(ws, 'traffic', PublicTransport.get(session[:user_id]))
        Websocket.send(ws, 'weather', [Weather.get(session[:user_id])])
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
       DBConnector.connect.execute('SELECT * FROM Location WHERE user_id = ?', params[:user_id]) != [[nil]] # rubocop:disable Metrics/LineLength
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
# rubocop:enable Metrics/ClassLength
