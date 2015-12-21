require File.expand_path('../../../spec_helper', __FILE__)
require 'milestones_management'

=begin
REST call: Verify fetchMilestones service works correctly
=end

describe "TS01 - fetchMilestones - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  fetch_milestones_res = nil

  context 'TC01.001 - fetchMilestones - SuccessfulResponse' do
    before :all do
      fetch_milestones_res = MilestonesManagementRest.fetch_milestones(caller_id)
    end

    it 'Match content of [status] = true' do
      expect(fetch_milestones_res['status']).to eq(true)
    end

    it 'Check for existance of [data]' do
      expect(fetch_milestones_res['data']).not_to be_empty
    end
  end
end
