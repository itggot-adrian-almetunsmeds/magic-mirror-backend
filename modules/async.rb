# frozen_string_literal: true

require_relative 'websocket'

# Handles async calling
class Async
  # Makes async operation possible
  #
  # time - Integer (Time in secounds)
  # object - Object (Object to call method on)
  # method - String (Name of method to be called)
  # *args - Values to be passed on as arguments for method call (Max 2, Min 2)
  #
  # Returns nothing
  #
  def self.quue(time, object, method, *args)
    object.send(method, time, args[0], args[1])
  end
end
