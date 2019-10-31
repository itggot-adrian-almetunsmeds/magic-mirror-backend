# frozen_string_literal: true

require 'bundler'

Bundler.require

require_relative './server'

Faye::WebSocket.load_adapter('thin')

Rack::Server.start(
  Port: 9292,
  Host: '0.0.0.0',
  app: Server,
  SSLEnable: false
)
