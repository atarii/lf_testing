require File.expand_path('../../../spec_helper', __FILE__)
require 'recommendation'

=begin
Verify recommendProducts service works correctly
=end

describe "TS04 - recommendProducts - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  session = 'f67e22fa-6049-4640-aa38-4dfe74dbd269'
  response = nil

  context 'TC01-002 - recommendProducts - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      response = Recommendation.recommend_products(caller_id2, session, 'platform')
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(response).to eq('Error while checking caller id')
    end
  end

  context 'TC01-003 - recommendProducts - Null Rule-Type' do
    rule_type = ''

    before :all do
      response = Recommendation.recommend_products(caller_id, session, rule_type)
    end

    it "Verify 'Rule type parameter cannot be null' error responses" do
      expect(response).to eq('Rule type parameter cannot be null')
    end
  end
end
