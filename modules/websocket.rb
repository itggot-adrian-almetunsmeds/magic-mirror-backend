# frozen_string_literal: true

# require 'sucker_punch'

# Handles websocket connections
class Websocket
  @sockets = []

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

  # Sends data to clients after it having been updated
  #
  # ws - Object (Websocket)
  # user_id - Integer (User id given from session)
  #
  # Returns nothing
  #
  def self.update_data(websocket, user_id)
    x = DBConnector.connect.execute('SELECT * FROM current_sessions WHERE user_id = ?',
                                    user_id.to_s).first
    unless x.nil?
      Websocket.send_message(websocket, 'weather', [Weather.get(user_id)])
      Websocket.send_message(websocket, 'traffic', PublicTransport.get(user_id))
      Async.perform_in(5, [self, 'update_data', websocket, user_id])
      # TODO [#15]: Perform_in action can not be run more than once
      #
      # The update_data function requires perform that in turn
      # requires update_data to be defined for it to run.
      # There by creating a moment 22 situation, where it can only
      # be run the first time
    end
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
    Async.perform_in(5, [self, 'update_data', websocket, user_id])
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
