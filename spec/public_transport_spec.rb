# frozen_string_literal: false

require 'rspec'
require_relative '../modules/public_transport.rb'
RSpec.describe 'PublicTransport:' do
  # rubocop:disable Metrics/LineLength
  it 'Verifies PublicTransport station output' do
    expect(JSON.parse(PublicTransport.stopID('skra bro'))['StopLocation'][0]['name']).to include 'Skra Bro'
    expect(JSON.parse(PublicTransport.stopID('skra bro'))['StopLocation'][0]['extId']).to include '740059559'
    expect(JSON.parse(PublicTransport.stopID('skra bro'))['StopLocation'][0]['id']).to include '740059559'
    # rubocop:enable Metrics/LineLength
    expect(JSON.parse(PublicTransport.stopID('chalmers'))['StopLocation'].length).to be > 2
    expect(JSON.parse(PublicTransport.stopID('chalmers'))['StopLocation'].class).to eq Array
    expect(JSON.parse(PublicTransport.stopID('chalmers'))['StopLocation'][0].class).to eq Hash
  end
  it 'Verifies PublicTransport departure output' do
    expect(PublicTransport.departures('740059559').class).to eq Array
    expect(PublicTransport.departures('9999999999999999').class).to eq Array
    expect(PublicTransport.departures('9999999999999999')[0]).to eq 'No data available'
  end
  it 'Verifies PublicTransport departure output "Line"' do
    expect((PublicTransport.departures('740059559')[0][0].include? '22') ||
    (PublicTransport.departures('740059559')[0][0].include? '36') ||
    (PublicTransport.departures('740059559')[0][0].downcase.include? 'svart')).to eq true
  end
end
