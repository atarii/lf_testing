require File.expand_path('../../../spec_helper', __FILE__)
require 'recommendation'

=begin
Verify recommendNeededSkills service works correctly
=end

describe "TS03 - recommendNeededSkills - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  customer_id = '2785727'
  response = nil

  context 'TC03.001 - recommendNeededSkills - Successful Request' do
    before :all do
      response = Recommendation.recommend_needed_skills(caller_id, customer_id, '1')
    end

    it 'Report known issue' do
      expect("The services always responses with \"unable to complete request\" fault string when calling recommendEngagedSkills and recommendNeededSkills methods.").to eq(response)
    end
  end

  context 'TC03.002 - recommendNeededSkills - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      response = Recommendation.recommend_needed_skills(caller_id2, customer_id, '1')
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(response).to eq('Error while checking caller id')
    end
  end

  context 'TC03.003 - recommendNeededSkills - Invalid CustomerID' do
    customer_id3 = 'invalid'

    before :all do
      response = Recommendation.recommend_needed_skills(caller_id, customer_id3, '1')
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided for customer id.' error responses" do
      expect(response).to eq('Unable to execute the requested call, an invalid or empty argument was provided for customer id.')
    end
  end
end
