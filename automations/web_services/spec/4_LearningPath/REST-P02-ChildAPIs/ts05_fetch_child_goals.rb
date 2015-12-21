require File.expand_path('../../../spec_helper', __FILE__)
require 'parent_management'
require 'lib/learning_path/child_management'
require 'lib/inmon/child_management'

=begin
REST call: Verify fetchChild service works correctly
=end

describe "TS05 - fetchChildGoals - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  email = LFCommon.generate_email
  password = '123456'
  firstname = 'ltrc'
  lastname = 'vn'
  email_optin = 'true'
  locale = 'en_US'
  session = child_id = nil
  fetch_child_goal_res = nil

  it 'Precondition - createParent' do
    # Create Parent account
    create_parent_res = ParentManagementRest.create_parent(caller_id, email, password, firstname, lastname, email_optin, locale)
    parent_id = create_parent_res['data']['parent']['parentID']
    session = create_parent_res['data']['token']

    # createChild
    xml_register_child = ChildManagement.register_child_smoketest(caller_id, session, parent_id, 'RIOKid', 'male', '3')
    child_id = xml_register_child.xpath('//child/@id').text
  end

  context 'TC05.01 - fetchChildGoals - Successful Response' do
    before :all do
      fetch_child_goal_res = ChildManagementRest.fetch_child_goals(caller_id, session, child_id, '', '')
    end

    it 'Valid HTTP Status Codes' do
      expect(fetch_child_goal_res['status']).to eq(true)
    end
  end

  context 'TC05.02 - fetchChildGoals - Access Denied' do
    session2 = 'invalid'

    before :all do
      fetch_child_goal_res = ChildManagementRest.fetch_child_goals(caller_id, session2, child_id, '', '')
    end

    it "Verify error message is 'Can not find session: " + session2 + "'" do
      expect(fetch_child_goal_res['data']['message']).to eq('Can not find session: ' + session2)
    end
  end

  context 'TC05.03 - fetchChildGoals - childId-Nonexistence' do
    child_id3 = '-111'

    before :all do
      fetch_child_goal_res = ChildManagementRest.fetch_child_goals(caller_id, session, child_id3, '', '')
    end

    it "Verify error message is 'Cannot locate child with ID \"" + child_id3 + "\" in the system'" do
      expect(fetch_child_goal_res['data']['message']).to eq("Cannot locate child with ID \"" + child_id3 + "\" in the system")
    end
  end

  context 'TC05.04 - fetchChildGoals - childId-Character' do
    child_id4 = 'invalid'

    before :all do
      fetch_child_goal_res = ChildManagementRest.fetch_child_goals(caller_id, session, child_id4, '', '')
    end

    it 'Invalid HTTP Status Codes' do
      expect(fetch_child_goal_res['status']).to eq(false)
    end
  end
end
