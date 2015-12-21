require File.expand_path('../../../spec_helper', __FILE__)
require 'parent_management'
require 'lib/learning_path/child_management'
require 'lib/inmon/child_management'

=begin
REST call: Verify fetchChildGoals service works correctly
=end

describe "TS05 - fetchChildGoals - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  email = LFCommon.generate_email
  password = '123456'
  firstname = 'ltrc'
  lastname = 'vn'
  email_optin = 'true'
  locale = 'en_US'
  session = child_id = child_goal = nil
  child_goal_status = 'goal for child'
  update_child_goal_res = nil

  it 'Precondition - createParent' do
    create_parent_res = ParentManagementRest.create_parent(caller_id, email, password, firstname, lastname, email_optin, locale)
    puts parent_id = create_parent_res['data']['parent']['parentID']
    session = create_parent_res['data']['token']

    xml_register_child = ChildManagement.register_child_smoketest(caller_id, session, parent_id, 'RIOKid', 'male', '3')
    child_id = xml_register_child.xpath('//child/@id').text

    fetch_child_goals_res = ChildManagementRest.fetch_child_goals(caller_id, session, child_id, '', '')
    child_goal = fetch_child_goals_res['data']['childGoals'][0]['childGoal']
  end

  context 'TC06.01 - updateChildGoal - Successful Response' do
    before :all do
      update_child_goal_res = ChildManagementRest.update_child_goals(caller_id, session, child_id, child_goal, child_goal_status)
    end

    it 'Valid HTTP Status Codes' do
      expect(update_child_goal_res['status']).to eq(true)
    end

    it "Check childGoal value is #{child_goal}" do
      expect(update_child_goal_res['data']['childGoals'][0]['childGoal']).to eq(child_goal)
    end

    it "Check childGoalStatus value is #{child_goal_status}" do
      expect(update_child_goal_res['data']['childGoals'][0]['childGoalStatus']).to eq(child_goal_status)
    end
  end

  context 'TC06.02 - updateChildGoal - Access Denied' do
    session2 = 'invalid'

    before :all do
      update_child_goal_res = ChildManagementRest.update_child_goals(caller_id, session2, child_id, child_goal, child_goal_status)
    end

    it "Verify error message is 'Can not find session: " + session2 + "'" do
      expect(update_child_goal_res['data']['message']).to eq('Can not find session: ' + session2)
    end
  end

  context 'TC06.03 - fetchChildGoals - childId-Nonexistence' do
    child_id3 = '-11111'

    before :all do
      update_child_goal_res = ChildManagementRest.update_child_goals(caller_id, session, child_id3, child_goal, child_goal_status)
    end

    it "Verify error message is 'Cannot locate child with ID \"" + child_id3 + "\" in the system'" do
      expect(update_child_goal_res['data']['message']).to eq("Cannot locate child with ID \"" + child_id3 + "\" in the system")
    end
  end

  context 'TC06.04 - fetchChildGoals - childId-Character' do
    child_id4 = 'invalid'

    before :all do
      update_child_goal_res = ChildManagementRest.update_child_goals(caller_id, session, child_id4, child_goal, child_goal_status)
    end

    it 'Invalid HTTP Status Codes' do
      expect(update_child_goal_res['status']).to eq(false)
    end
  end

  context 'TC06.05 - updateChildGoal - childGoalStatus - Over maximum length' do
    child_goal_status5 = 'child goal 64 characters, child goal 64 characters, child goal 64 characters, '

    before :all do
      update_child_goal_res = ChildManagementRest.update_child_goals(caller_id, session, child_id, child_goal, child_goal_status5)
    end

    it 'Invalid HTTP Status Codes' do
      expect(update_child_goal_res['status']).to eq(false)
    end
  end
end
