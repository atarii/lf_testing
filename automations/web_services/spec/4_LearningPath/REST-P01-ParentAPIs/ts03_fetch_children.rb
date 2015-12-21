require File.expand_path('../../../spec_helper', __FILE__)
require 'parent_management'

=begin
REST call: Verify fetchChildren service works correctly
=end

describe "TS02 - fetchChildren - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  email = LFCommon.generate_email
  password = '123456'
  firstname = 'ltrc'
  lastname = 'vn'
  email_optin = 'true'
  locale = 'en_US'
  parent_id = session = nil
  fetch_children_res   = nil

  it 'Pre-Condition - Create Parent' do
    create_parent_res = ParentManagementRest.create_parent(caller_id, email, password, firstname, lastname, email_optin, locale)
    parent_id = create_parent_res['data']['parent']['parentID']
    session = create_parent_res['data']['token']
  end

  context 'TC03.01 - fetchChildren - Successful Response' do
    before :all do
      fetch_children_res = ParentManagementRest.fetch_child(caller_id, session, parent_id)
    end

    it "Valid HTTP Status Codes is 'true'" do
      expect(fetch_children_res['status']).to eq(true)
    end
  end

  context 'TC03.02 - fetchChildren - Access Denied' do
    session2 = ''

    before :all do
      fetch_children_res = ParentManagementRest.fetch_child(caller_id, session2, parent_id)
    end

    it "Verify error is 'Nil session token'" do
      expect(fetch_children_res['data']['message']).to eq('Nil session token')
    end
  end

  context 'TC03.03 - fetchChildren - Invalid ParentID' do
    parent_id3 = '123456789'

    before :all do
      fetch_children_res = ParentManagementRest.fetch_child(caller_id, session, parent_id3)
    end

    it "Fault message is '" + parent_id3 + " doesn't match session token cust-id'" do
      expect(fetch_children_res['data']['message']).to eq(parent_id3 + " doesn't match session token cust-id")
    end
  end
end
