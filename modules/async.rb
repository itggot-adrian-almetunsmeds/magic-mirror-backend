# frozen_string_literal: true

class Async
  include SuckerPunch::Job
  # Makes async operation possible
  #
  # callback - Array (method to be called, method-inputs)
  #
  # Returns nothing
  #
  def self.perform(callback)
    callback[0].send(callback[1], callback[2], callback[3])
  end
end
