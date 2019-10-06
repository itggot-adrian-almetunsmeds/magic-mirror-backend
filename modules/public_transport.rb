# frozen_string_literal: false

require 'httparty'
require 'json'
require 'pp'
require 'yaml'
require_relative 'web_handler.rb'

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
  attr_reader :departures, :json
  def initialize(location) # rubocop:disable Metrics/MethodLength
    @config = YAML.load_file('configuration.yaml')
    location = WebHandler.encode(location)
    response = HTTParty.get('https://api.resrobot.se/v2/location.name.json?key='\
      "#{@config['public_transport']['reseplanerare']['api_key']}"\
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
    response = HTTParty.get('https://api.resrobot.se/v2/departureBoard?key='\
      "#{@config['public_transport']['stolptidstabeller']['api_key']}"\
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
end
