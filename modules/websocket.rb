# frozen_string_literal: true

# Handles websocket connections
class Websocket
  # Parses websocket message
  #
  # channel - String
  # msg - String / Array / Hash
  #
  def self.parse(channel, msg)
    { channel: channel, message: msg }.to_json
  end

  # Sends the inserted message to the given ws
  #
  # websocket - Object
  # channel - String
  # msg - String / Array / Hash
  #
  def self.send(websocket, channel, msg)
    websocket.send(parse(channel, msg))
  end
end
