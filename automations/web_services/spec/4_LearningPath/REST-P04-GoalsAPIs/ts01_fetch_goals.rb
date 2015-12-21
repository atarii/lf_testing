require File.expand_path('../../../spec_helper', __FILE__)
require 'goals_management'

=begin
REST call: Verify fetchGoals service works correctly
=end

describe "TS01 - fetchGoals - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  milestone = 'c5d91f7f-e92b-45fa-9b7b-103e04b302fe'
  fetch_goals_res = nil

  context 'TC01.001 - fetchGoals - SuccessfulResponse' do
    before :all do
      fetch_goals_res = GoalsManagementRest.fetch_goals(caller_id, milestone)
    end

    it 'Match content of [milestone]' do
      expect(fetch_goals_res['data'][0]['milestone']).to eq(milestone)
    end

    it 'Match content of [status] = true' do
      expect(fetch_goals_res['status']).to eq(true)
    end
  end

  context 'TC01.002 - fetchGoals - Milestone does not exist' do
    milestone2 = '1423423'

    before :all do
      fetch_goals_res = GoalsManagementRest.fetch_goals(caller_id, milestone2)
    end

    it "Verify error message is 'Invalid Milestone : " + milestone2 + "'" do
      expect(fetch_goals_res['data']['message']).to eq('Invalid Milestone : ' + milestone2)
    end
  end
end
