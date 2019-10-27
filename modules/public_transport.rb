# frozen_string_literal: false

require 'json'
require 'pp'
require 'yaml'
require_relative 'web_handler.rb'
require_relative 'db_connector.rb'

# Public: Used to get the following departures
# from a station.
#
# location - A string containing the name of a transit stop
#
# Examples:
#
# PublicTransport.stopID("chalmers")
#   => "{\n  \"StopLocation\" : [ {\n    \"id\" : \"740059559\",\n
#     \"extId\" : \"740059559\",\n    \"name\" : \"Skra Bro (G\u00F6teborg kn)\",
#     \n    \"lon\" : 11.83118,\n    \"lat\" : 57.758201,\n    \"weight\" : 465,
#     \n    \"products\" : 128\n
#     } ]\n}"
#
#
# PublicTransport.departures("740059559")
#   => [["Svart", nil, "12:10:00", "Amhult Resecentrum (G\u00F6teborg kn)", "V\u00E4sttrafik", "279"],
#      ["Buss SVART", "12:13:00", "12:10:00", "Amhults Torg", "LT V\u00E4sttrafik", "279"],
#      ["Svart", nil, "12:15:00", "S\u00E4vedalen Ljungkullen (Partille kn)", "V\u00E4sttrafik", "279"]]
#
class PublicTransport
  def self.stopID(querry) # rubocop:disable Naming/MethodName
    @config = DBConnector.connect
    @config.results_as_hash = true
    @config = @config.execute('SELECT * FROM ApiKeys')[0]
    location = WebHandler.encode(querry)
    response = WebHandler.request('https://api.resrobot.se/v2/location.name.json?key='\
      "#{@config['reseplanerare']}"\
      "&input=#{location}")
    response.body
  end

  # rubocop:disable Metrics/MethodLength
  def self.departures(stop_id) # rubocop:disable Metrics/AbcSize
    @config = DBConnector.connect
    @config.results_as_hash = true
    @config = @config.execute('SELECT * FROM ApiKeys').first
    response = WebHandler.request('https://api.resrobot.se/v2/departureBoard?key='\
    "#{@config['stolptidstabeller']}"\
    "&id=#{stop_id}&format=json&passlist=0")
    @json = JSON.parse(response.body)
    if @json['errorText'].nil?
      traffic = []
      @json['Departure'].each do |bus|
        traffic << [bus['Product']['num'], bus['rtTime'], bus['time'],
                    bus['direction'], bus['Product']['operator'],
                    bus['Product']['operatorCode']]
      end
      traffic
    else
      ['No data available']
    end
  end
  # rubocop:enable Metrics/MethodLength

  def self.stop_add(name, stop_id, user_id)
    DBConnector.insert('PublicTransit', %w[Name stop_id user_id], [name, stop_id.to_i, user_id.to_i])
    true
  end

  def self.stops
    DBConnector.connect.execute('SELECT * FROM PublicTransit')
  end
end
