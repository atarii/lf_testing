require File.expand_path('../../../spec_helper', __FILE__)
require 'discussions_management'

=begin
REST call: Verify fetchDiscussions service works correctly
=end

describe "TS01 - fetchDiscussions - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  milestone = 'c5d91f7f-e92b-45fa-9b7b-103e04b302fe'
  res = nil

  context 'TC01.001 - fetchDiscussions - SuccessfulResponse' do
    before :all do
      res = DiscussionManagementRest.fetch_discussions(caller_id, milestone)
    end

    it 'Verify response [status] is true' do
      expect(res['status']).to eq(true)
    end
  end

  context 'TC01.002 - fetchDiscussions - Milestone does not exist' do
    milestone2 = 'invalid'

    before :all do
      res = DiscussionManagementRest.fetch_discussions(caller_id, milestone2)
    end

    it "Verify error message is 'Invalid Milestone : " + milestone2 + "'" do
      expect(res['data']['message']).to eq('Invalid Milestone : ' + milestone2)
    end
  end
end
