# frozen_string_literal: false

require 'rspec'
require_relative '../modules/link.rb'
RSpec.describe 'Link:' do
  it 'Verifies url encoding' do
    question = 'Kan vi inkludera stora delar'\
    ' av ett alfabet här eller måste jag dra till med '\
    'ö'
    correct = 'kan%20vi%20inkludera%20stora%20delar%20'\
    'av%20ett%20alfabet%20h%C3%A4r%20eller%20m%C3%A5ste%20jag'\
    '%20dra%20till%20med%20%C3%B6'
    expect(Link.encode(question.downcase)).to eq correct
  end
end
