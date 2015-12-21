require File.expand_path('../../../spec_helper', __FILE__)
require 'parent_management'

=begin
REST call: Verify createParent service works correctly
=end

describe "TS04 - createParent - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  email = LFCommon.generate_email
  password = '123456'
  firstname = 'ltrc'
  lastname = 'vn'
  email_optin = 'true'
  locale = 'en_US'
  create_parent_res = nil
  parent_id = nil

  context 'TC04.01 - createParent - Successful Response' do
    before :all do
      create_parent_res = ParentManagementRest.create_parent(caller_id, email, password, firstname, lastname, email_optin, locale)
      parent_id = create_parent_res['data']['parent']['parentID']
    end

    it 'Status is true' do
      expect(create_parent_res['status']).to eq(true)
    end

    it 'Check for existance of [parentID]' do
      expect(create_parent_res['data']['parent']['parentID']).not_to be_empty
    end

    it "Check parent email is #{email}" do
      expect(create_parent_res['data']['parent']['parentEmail']).to eq(email)
    end

    it "Check parent first name is #{firstname}" do
      expect(create_parent_res['data']['parent']['parentFirstName']).to eq(firstname)
    end

    it "Check parent last name is #{lastname}" do
      expect(create_parent_res['data']['parent']['parentLastName']).to eq(lastname)
    end

    it "Check parent locale is #{locale}" do
      expect(create_parent_res['data']['parent']['parentLocale']).to eq(locale)
    end
  end

  context 'TC04.02 - createParent -parentFirstName-Empty' do
    firstname2 = ''

    before :all do
      create_parent_res = ParentManagementRest.create_parent(caller_id, email, password, firstname2, lastname, email_optin, locale)
    end

    it 'Status is false' do
      expect(create_parent_res['status']).to eq(false)
    end

    it "Fault message is 'First name cannot be empty.'" do
      expect(create_parent_res['data']['message']).to eq('First name cannot be empty.')
    end
  end

  context 'TC04.03 - createParent -parentEmail-Empty' do
    email3 = ''

    before :all do
      create_parent_res = ParentManagementRest.create_parent(caller_id, email3, password, firstname, lastname, email_optin, locale)
    end

    it 'Status is false' do
      expect(create_parent_res['status']).to eq(false)
    end

    it "Fault message is 'invalid email address '''" do
      expect(create_parent_res['data']['message']).to eq("invalid email address ''")
    end
  end

  context 'TC04.04 - createParent -parentEmail-Invalid Format' do
    email5 = 'invalid_format'

    before :all do
      create_parent_res = ParentManagementRest.create_parent(caller_id, email5, password, firstname, lastname, email_optin, locale)
    end

    it 'Status is false' do
      expect(create_parent_res['status']).to eq(false)
    end

    it "Fault message is 'invalid email address 'invalid_format''" do
      expect(create_parent_res['data']['message']).to eq("invalid email address 'invalid_format'")
    end
  end

  context 'TC04.05 - createParent -parentEmail-Great than maximum_100' do
    email6 = 'email_great_than_maximum_100_sdfsdfsdfsfsfsdfsdfsdfsdsfsdafsdfsdafsdafaghfghfguyutyutyu@leapfrog.test'

    before :all do
      create_parent_res = ParentManagementRest.create_parent(caller_id, email6, password, firstname, lastname, email_optin, locale)
    end

    it 'Status is false' do
      expect(create_parent_res['status']).to eq(false)
    end

    it 'Ignore will-not-fix defect: UPC# 37268 Web Service: LP: REST-P01-ParentAPIs/TS04 - createParent/TC04.05 - createParent -parentEmail-Great than maximum_100: Exception occurs when entering too large email text.' do
    end
  end

  context 'TC04.07 - createParent - password-Empty' do
    password7 = ''

    before :all do
      create_parent_res = ParentManagementRest.create_parent(caller_id, email, password7, firstname, lastname, email_optin, locale)
    end

    it 'Status is false' do
      expect(create_parent_res['status']).to eq(false)
    end

    it "Fault message is 'An invalid customer password was provided.'" do
      expect(create_parent_res['data']['message']).to eq('An invalid customer password was provided.')
    end
  end

  context 'TC04.08 - createParent - Duplicate Email' do
    before :all do
      create_parent_res = ParentManagementRest.create_parent(caller_id, email, password, firstname, lastname, email_optin, locale)
    end

    it 'Status is false' do
      expect(create_parent_res['status']).to eq(false)
    end

    it "Fault message is 'An account with this email address already exists'" do
      expect(create_parent_res['data']['message']).to eq("An account with this email address already exists: #{parent_id}")
    end
  end
end
