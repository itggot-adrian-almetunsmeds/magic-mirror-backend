# frozen_string_literal: true

require 'sucker_punch'

# Handles websocket connections
class Websocket
  @sockets = []

  include SuckerPunch::Job

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
  def self.send_message(websocket, channel, msg)
    websocket.send(parse(channel, msg))
  end

  def perform(websocket, user_id)
    x = DBConnector.connect.execute('SELECT * FROM current_sessions WHERE user_id = ?',
                                    user_id.to_s).first
    unless x.nil?
      Websocket.send_message(websocket, 'weather', [Weather.get(user_id)])
      Websocket.send_message(websocket, 'traffic', PublicTransport.get(user_id))
    end
    Async.quue(5, Websocket, 'update_data', websocket, user_id)
  end

  # Sends data to clients after it having been updated
  #
  # time - Integer (Time in secounds until function call)
  # ws - Object (Websocket)
  # user_id - Integer (User id given from session)
  #
  # Returns nothing
  #
  def self.update_data(time, websocket, user_id)
    perform_in(time, websocket, user_id)
  end

  # Stores the current ws sessions and initiates first data update
  #
  # ws - Object (Websocket)
  # user_id - Integer (User ID)
  #
  # Returns nothing
  #
  def self.store(websocket, user_id)
    @sockets << [websocket, user_id]
    Async.quue(5, self, 'update_data', websocket, user_id)
  end

  # Removes a ws session from the stored sessions array
  #
  # ws - Object (Websocket)
  # user_id - Integer (User ID)
  #
  # Returns nothing
  #
  def self.remove(websocket, user_id)
    @sockets.delete([websocket, user_id])
  end
end
