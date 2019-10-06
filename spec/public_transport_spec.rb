# frozen_string_literal: false

require 'rspec'
require_relative '../modules/public_transport.rb'
RSpec.describe 'PublicTransport:' do
  it 'Veryfies PublicTransport station output' do
    expect(PublicTransport.new('skra bro').json.to_json).to include '740059559' && 'Skra Bro'
  end
  it 'Veryfies PublicTransport departure output' do
    expect(PublicTransport.new('skra bro').departures.class.to_s).to eq 'Array'
  end
  it 'Veryfies PublicTransport departure output layer 2' do
    expect(PublicTransport.new('skra bro').departures[0].class.to_s).to eq 'Array'
  end
  it 'Veryfies PublicTransport departure output "Line"' do
    expect((PublicTransport.new('skra bro').departures[0][0].include? '22') ||
    (PublicTransport.new('skra bro').departures[0][0].include? '36') ||
    (PublicTransport.new('skra bro').departures[0][0].downcase.include? 'svart')).to eq true
  end
end
