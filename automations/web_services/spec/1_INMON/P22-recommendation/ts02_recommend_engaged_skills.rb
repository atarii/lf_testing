require File.expand_path('../../../spec_helper', __FILE__)
require 'recommendation'

=begin
Verify recommendEngagedSkills service works correctly
=end

describe "TS02 - recommendEngagedSkills - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = 'ltrc_recommendation@leapfrog.test'
  customer_id = '2785727'
  response = nil

  context 'TC01.002 - recommendEngagedSkills - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      response = Recommendation.recommend_engaged_skills(caller_id2, username, customer_id, '1')
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(response).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - recommendEngagedSkills - Invalid CustomerID' do
    customer_id3 = 'invalid'

    before :all do
      response = Recommendation.recommend_engaged_skills(caller_id, username, customer_id3, '3')
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided for customer id.' error responses" do
      expect(response).to eq('Unable to execute the requested call, an invalid or empty argument was provided for customer id.')
    end
  end
end
