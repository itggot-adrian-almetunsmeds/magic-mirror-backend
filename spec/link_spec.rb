
require 'rspec'

require_relative '../modules/link.rb'
RSpec.describe 'Link:' do
    it "Verifies url encoding" do
        expect(Link.encode('ps öäö s')).to eq "ps%20%C3%B6%C3%A4%C3%B6%20s"
    end
    
end