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
# PublicTransport.new("chalmers")
#   => "Please use one of the following locationsin the configuration.yaml file"
#         "Chalmers (G\u00F6teborg kn)"
#         "Chalmers golfklubb (H\u00E4rryda kn)"
#         "Chalmers Tv\u00E4rgata (G\u00F6teborg kn)"
#         "Chalmersplatsen (G\u00F6teborg kn)"
#
#
# PublicTransport.new("skra bro")
#   => [["Svart", nil, "12:10:00", "Amhult Resecentrum (G\u00F6teborg kn)", "V\u00E4sttrafik", "279"],
#      ["Buss SVART", "12:13:00", "12:10:00", "Amhults Torg", "LT V\u00E4sttrafik", "279"],
#      ["Svart", nil, "12:15:00", "S\u00E4vedalen Ljungkullen (Partille kn)", "V\u00E4sttrafik", "279"]]
#
class PublicTransport

  def self.stopID(querry)
    @config = YAML.load_file('configuration.yaml')
    location = WebHandler.encode(querry)
    response = WebHandler.request('https://api.resrobot.se/v2/location.name.json?key='\
      "#{@config['public_transport']['reseplanerare']['api_key']}"\
      "&input=#{querry}")
      response.body
    end










  attr_reader :departures, :json
  def initialize(location) # rubocop:disable Metrics/MethodLength
    @config = DBConnector.connect
    @config.results_as_hash = true
    @config = @config.execute('SELECT * FROM ApiKeys')[0]
    location = WebHandler.encode(location)
    response = WebHandler.request('https://api.resrobot.se/v2/location.name.json?key='\
      "#{@config['reseplanerare']}"\
      "&input=#{location}")
    @json = JSON.parse(response.body)
    if @json['StopLocation'].length > 1
      too_many_locations
    else
      @departures
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Lint/DuplicateMethods
  def departures # rubocop:disable Metrics/AbcSize
    response = WebHandler.request('https://api.resrobot.se/v2/departureBoard?key='\
      "#{@config['stolptidstabeller']}"\
      "&id=#{@json['StopLocation'][0]['id']}&format=json&passlist=0")
    @json = JSON.parse(response.body)
    traffic = []
    @json['Departure'].each do |bus|
      traffic << [bus['Product']['num'], bus['rtTime'], bus['time'],
                  bus['direction'], bus['Product']['operator'],
                  bus['Product']['operatorCode']]
    end
    traffic
  end
  # rubocop:enable Lint/DuplicateMethods
  # rubocop:enable Metrics/MethodLength

  def too_many_locations
    puts 'Please use one of the following locations'\
    'in the configuration.yaml file'
    @json['StopLocation'].each do |stop|
      PP.pp(stop['name'])
    end
  end

  def self.stop_add(name, stop_id, user_id)
    DBConnector.insert('PublicTransit', %w[Name stop_id user_id], [name, stop_id.to_i, user_id.to_i])
    true
  end

  def self.stops
    DBConnector.connect.execute('SELECT * FROM PublicTransit')
  end
end
