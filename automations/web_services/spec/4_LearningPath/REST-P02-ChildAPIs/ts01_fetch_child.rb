require File.expand_path('../../../spec_helper', __FILE__)
require 'parent_management'
require 'lib/learning_path/child_management'
require 'lib/inmon/child_management'

=begin
REST call: Verify fetchChild service works correctly
=end

describe "TS01 - fetchChild - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  email = LFCommon.generate_email
  password = '123456'
  firstname = 'ltrc'
  lastname = 'vn'
  email_optin = 'true'
  locale = 'en_US'
  session = child_id = nil
  fetch_child_res = nil

  it 'Precondition - createParent' do
    # Create Parent account
    create_parent_res = ParentManagementRest.create_parent(caller_id, email, password, firstname, lastname, email_optin, locale)
    parent_id = create_parent_res['data']['parent']['parentID']
    session = create_parent_res['data']['token']

    # createChild
    xml_register_child = ChildManagement.register_child_smoketest(caller_id, session, parent_id, 'RIOKid', 'male', '3')
    child_id = xml_register_child.xpath('//child/@id').text
  end

  context 'TS01 - fetchChild' do
    before :all do
      fetch_child_res = ChildManagementRest.fetch_child(caller_id, child_id, session)
    end

    it 'Match content of [childID]' do
      expect(fetch_child_res['data']['childID']).to eq(child_id)
    end
  end

  context 'TC01.02 - fetchChild - Access Denied' do
    session2 = 'invalid'

    before :all do
      fetch_child_res = ChildManagementRest.fetch_child(caller_id, child_id, session2)
    end

    it "Verify error message is 'Can not find session: " + session2 + "'" do
      expect(fetch_child_res['data']['message']).to eq('Can not find session: ' + session2)
    end
  end

  context 'TC01.03 - fetchChild - childId-Character' do
    child_id3 = 'invalid'

    before :all do
      fetch_child_res = ChildManagementRest.fetch_child(caller_id, child_id3, session)
    end

    it 'Invalid HTTP Status Codes' do
      expect(fetch_child_res['status']).to eq(false)
    end
  end

  context 'TC01.04 - fetchChild - childId-Nonexistence' do
    child_id4 = '-111'

    before :all do
      fetch_child_res = ChildManagementRest.fetch_child(caller_id, child_id4, session)
    end

    it "Verify error message is 'Cannot locate child with ID \"" + child_id4 + "\" in the system'" do
      expect(fetch_child_res['data']['message']).to eq("Cannot locate child with ID \"" + child_id4 + "\" in the system")
    end
  end
end
