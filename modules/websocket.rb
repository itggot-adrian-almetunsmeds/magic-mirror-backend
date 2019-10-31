# frozen_string_literal: true

# Handles websocket connections
class Websocket
  def self.parse(channel, msg)
    { channel: channel, message: msg }.to_json
  end

  def self.send(websocket, channel, msg)
    websocket.send(parse(channel, msg))
  end
end
