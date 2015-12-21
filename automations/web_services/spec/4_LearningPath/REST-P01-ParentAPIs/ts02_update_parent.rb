require File.expand_path('../../../spec_helper', __FILE__)
require 'parent_management'

=begin
REST call: Verify updateParent service works correctly
=end

describe "TS02 - updateParent - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  email = LFCommon.generate_email
  password = '123456'
  firstname = 'ltrc'
  lastname = 'vn'
  email_optin = 'true'
  locale = 'en_US'
  parent_id = session = nil
  update_parent_res = fetch_parent_res = nil

  it 'Pre-Condition - Create Parent' do
    create_parent_res = ParentManagementRest.create_parent(caller_id, email, password, firstname, lastname, email_optin, locale)
    parent_id = create_parent_res['data']['parent']['parentID']
    session = create_parent_res['data']['token']
  end

  context 'TC02.01 - updateParent - Successful Response' do
    before :all do
      update_parent_res = ParentManagementRest.update_parent(caller_id, session, parent_id, 'lastname', 'firstname', email, 'country', 'city', 'state', '4444', 'url', 'true', 'true', 'true', 'true')
      fetch_parent_res = ParentManagementRest.fetch_parent(caller_id, session, parent_id)
    end

    it 'Match content of [parentID]' do
      expect(fetch_parent_res['data']['parentID']).to eq(parent_id)
    end

    it 'Match content of [parentCity]' do
      expect(fetch_parent_res['data']['parentCity']).to eq('city')
    end

    it 'Match content of [parentCountry]' do
      expect(fetch_parent_res['data']['parentCountry']).to eq('country')
    end

    it 'Match content of [parentZipCode]' do
      expect(fetch_parent_res['data']['parentZipCode']).to eq('4444')
    end

    it 'Match content of [parentLastName]' do
      expect(fetch_parent_res['data']['parentLastName']).to eq('lastname')
    end

    it 'Match content of [parentFirstName]' do
      expect(fetch_parent_res['data']['parentFirstName']).to eq('firstname')
    end

    it 'Match content of [parentState]' do
      expect(fetch_parent_res['data']['parentState']).to eq('state')
    end

    it 'Match content of [parentPictureURL]' do
      expect(fetch_parent_res['data']['parentPictureURL']).to eq('url')
    end

    it 'Match content of [parentContentNotify_optin]' do
      expect(fetch_parent_res['data']['parentContentNotify_optin']).to eq(true)
    end

    it 'Match content of [parentMilestoneNotify_optin]' do
      expect(fetch_parent_res['data']['parentMilestoneNotify_optin']).to eq(true)
    end

    it 'Match content of [parentLFemail_optin]' do
      expect(fetch_parent_res['data']['parentLFemail_optin']).to eq(true)
    end

    it 'Match content of [parentLPemail_optin]' do
      expect(fetch_parent_res['data']['parentLPemail_optin']).to eq(true)
    end
  end

  context 'TC02.02 - updateParent - Access Denied' do
    session2 = ''

    before :all do
      update_parent_res = ParentManagementRest.update_parent(caller_id, session2, parent_id, 'lastname', 'firstname', email, 'country', 'city', 'state', '4444', 'url', 'true', 'true', 'true', 'true')
    end

    it "Fault message is 'Nil session token'" do
      expect(update_parent_res['data']['message']).to eq('Nil session token')
    end
  end

  context 'TC02.03 - updateParent - Invalid ParentID' do
    parent_id3 = '123123123123123123'

    before :all do
      update_parent_res = ParentManagementRest.update_parent(caller_id, session, parent_id3, 'lastname', 'firstname', email, 'country', 'city', 'state', '4444', 'url', 'true', 'true', 'true', 'true')
    end

    it "Fault message is '" + parent_id3 + " doesn't match session token cust-id'" do
      expect(update_parent_res['data']['message']).to eq(parent_id3 + " doesn't match session token cust-id")
    end
  end
end
