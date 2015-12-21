require File.expand_path('../../../spec_helper', __FILE__)
require 'milestones_management'

=begin
REST call: Verify fetchMilestonesDetails service works correctly
=end

describe "TS02 - fetchMilestonesDetails - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  milestones = 'c5d91f7f-e92b-45fa-9b7b-103e04b302fe'
  res = nil

  context 'TC02.001 - fetchMilestonesDetails - SuccessfulResponse' do
    before :all do
      res = MilestonesManagementRest.fetch_milestones_details(caller_id, milestones)
    end

    it 'Match content of [status] = true' do
      expect(res['status']).to eq(true)
    end

    it 'Check for existance of [data]' do
      expect(res['data']).not_to be_empty
    end
  end

  context 'TC02.002 - fetchMilestonesDetails - Milestone is invalid' do

    milestones2 = 'gahbssfjklhasdfjklsdhfjklhfjklasdhfjklsdahfk238974902374239047442309472890'

    before :all do
      res = MilestonesManagementRest.fetch_milestones_details(caller_id, milestones2)
    end

    it "Verify error message is 'Invalid Milestone : " + milestones2 + "'" do
      expect(res['data']['message']).to eq('Invalid Milestone : ' + milestones2)
    end
  end

  context 'TC02.003 - fetchMilestonesDetails - Milestone does not exist' do

    milestones3 = '12345'

    before :all do
      res = MilestonesManagementRest.fetch_milestones_details(caller_id, milestones3)
    end

    it "Verify error message is 'Invalid Milestone : " + milestones3 + "'" do
      expect(res['data']['message']).to eq('Invalid Milestone : ' + milestones3)
    end
  end

  context 'TC02.004 - fetchMilestonesDetails - Milestone is special characters' do

    milestones4 = '%21%40%40%23%40%40%23' # = '!@@\#@@#"'

    before :all do
      res = MilestonesManagementRest.fetch_milestones_details(caller_id, milestones4)
    end

    it "Verify error message is 'Invalid Milestone : !@@\#@@#'" do
      expect(res['data']['message']).to eq("Invalid Milestone : !@@\#@@#")
    end
  end
end
