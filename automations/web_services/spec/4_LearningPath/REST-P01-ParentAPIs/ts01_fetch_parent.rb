require File.expand_path('../../../spec_helper', __FILE__)
require 'parent_management'

=begin
REST call: Verify fetchParent service works correctly
=end

describe "TS01 - fetchParent - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  email = LFCommon.generate_email
  password = '123456'
  firstname = 'ltrc'
  lastname = 'vn'
  email_optin = 'true'
  locale = 'en_US'
  parent_id = session = nil
  fetch_parent_res = nil

  it 'Pre-Condition - Create Parent' do
    create_parent_res = ParentManagementRest.create_parent(caller_id, email, password, firstname, lastname, email_optin, locale)
    parent_id = create_parent_res['data']['parent']['parentID']
    session = create_parent_res['data']['token']
  end

  context 'TC01.01 - fetchParent - Successful Response - Successful Response' do
    before :all do
      fetch_parent_res = ParentManagementRest.fetch_parent(caller_id, session, parent_id)
    end

    it "Check parent ID is #{parent_id}" do
      expect(fetch_parent_res['data']['parentID']).to eq(parent_id)
    end

    it "Check parent email is #{email}" do
      expect(fetch_parent_res['data']['parentEmail']).to eq(email)
    end

    it "Check parent first name is #{firstname}" do
      expect(fetch_parent_res['data']['parentFirstName']).to eq(firstname)
    end

    it "Check parent last name is #{lastname}" do
      expect(fetch_parent_res['data']['parentLastName']).to eq(lastname)
    end

    it "Check parent locale is #{locale}" do
      expect(fetch_parent_res['data']['parentLocale']).to eq(locale)
    end
  end

  context 'TC01.02 - fetchParent - Access Denied' do
    session2 = ''

    before :all do
      fetch_parent_res = ParentManagementRest.fetch_parent(caller_id, session2, parent_id)
    end

    it "Fault message is 'Nil session token'" do
      expect(fetch_parent_res['data']['message']).to eq('Nil session token')
    end
  end

  context 'TC01.03 - fetchParent - Invalid ParentID' do
    parent_id3 = '123123123123123123'

    before :all do
      fetch_parent_res = ParentManagementRest.fetch_parent(caller_id, session, parent_id3)
    end

    it "Fault message is '" + parent_id3 + " doesn't match session token cust-id'" do
      expect(fetch_parent_res['data']['message']).to eq(parent_id3 + " doesn't match session token cust-id")
    end
  end
end
