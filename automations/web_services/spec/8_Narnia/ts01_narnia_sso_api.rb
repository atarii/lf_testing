require File.expand_path('../../spec_helper', __FILE__)
require 'credential_management'
require 'parent_management'

=begin
Narnia: SSO API checking
=end

describe "TS01 - SSO API - Narnia - #{Misc::CONST_ENV}" do
  callerid = Misc::CONST_REST_CALLER_ID
  locale = 'en_US'
  email = LFCommon.generate_email
  invalid_email = 'invalid_email' + email # email is not registered
  firstname = 'ltrc'
  lastname = 'vn'
  password = '123456'
  new_password = '123456vn'
  existing_email = 'ltrcv2holiday@gmail.com' # pass email DN123456
  temp_password = '8F9euw9v'
  email_optin = 'true'
  session = response = nil

  context "Pre-condition: Create parent account. (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_CREATE_PARENT})" do
    before :all do
      response = ParentManagementRest.create_parent(callerid, email, password, firstname, lastname, email_optin, locale)
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it 'Verify parent id is created' do
      expect(response['data']['parent']['parentID']).not_to be_empty
    end

    it 'Verify token is generated' do
      expect(response['data']['token']).not_to be_empty
    end
  end

  context "1. Verify customer info is return when calling service with valid email and password. (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_LOGIN})" do
    before :all do
      response = CredentialManagementRest.login callerid, email, password
      session = response['data']['token']
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it 'Verify token is generated' do
      expect(response['data']['token']).not_to be_empty
    end

    it 'Verify parent id is created' do
      expect(response['data']['parent']['parentID']).not_to be_empty
    end

    it "Verify parent email is \"#{email}\"" do
      expect(response['data']['parent']['parentEmail']).to eq(email)
    end

    it "Verify parent first name is \"#{firstname}\"" do
      expect(response['data']['parent']['parentFirstName']).to eq(firstname)
    end

    it "Verify parent last name is \"#{lastname}\"" do
      expect(response['data']['parent']['parentLastName']).to eq(lastname)
    end

    it "Verify parent locale is \"#{locale}\"" do
      expect(response['data']['parent']['parentLocale']).to eq(locale)
    end
  end

  context "2. Verify customer info is return when calling service with valid email and temporary password. (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_LOGIN})" do
    before :all do
      response = CredentialManagementRest.login callerid, existing_email, temp_password
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it 'Verify token is generated' do
      expect(response['data']['token']).not_to be_empty
    end

    it "Verify message is 'password is valid but temporary'" do
      expect(response['data']['message']).to eq('password is valid but temporary')
    end
  end

  context "3. Verify server will return error message when calling service with invalid email. (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_LOGIN})" do
    before :all do
      response = CredentialManagementRest.login callerid, invalid_email, password
    end

    it 'Verify response status is false' do
      expect(response['status']).to eq(false)
    end

    it "Verify faultCode is 'NOSUCHUSER'" do
      expect(response['data']['faultCode']).to eq('NOSUCHUSER')
    end

    it "Verify faultType is 'com.leapfrog.services.inmon.faults.AccessDeniedFault'" do
      expect(response['data']['faultType']).to eq('com.leapfrog.services.inmon.faults.AccessDeniedFault')
    end

    it "Verify message is '#{ErrorMessageConst::INVALID_EMAIL_MESSAGE}'" do
      expect(response['data']['message']).to eq(ErrorMessageConst::INVALID_EMAIL_MESSAGE)
    end
  end

  context "4. Verify server will return error message when calling service with invalid password. (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_LOGIN})" do
    before :all do
      response = CredentialManagementRest.login callerid, email, '123456invalid'
    end

    it 'Verify response status is false' do
      expect(response['status']).to eq(false)
    end

    it "Verify faultCode is 'BADPASSWORD'" do
      expect(response['data']['faultCode']).to eq('BADPASSWORD')
    end

    it "Verify faultType is 'com.leapfrog.services.inmon.faults.AccessDeniedFault'" do
      expect(response['data']['faultType']).to eq('com.leapfrog.services.inmon.faults.AccessDeniedFault')
    end

    it "Verify message is '#{ErrorMessageConst::INVALID_EMAIL_MESSAGE}'" do
      expect(response['data']['message']).to eq(ErrorMessageConst::INVALID_PASSWORD_MESSAGE)
    end
  end

  context "5. Verify changed password successful (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_CHANGE_PASSWORD}" do
    response_login_new_pass = response_login_old_pass = nil
    before :all do
      # Step 1: change password
      response = CredentialManagementRest.change_password callerid, session, password, new_password

      # Login with new password
      response_login_new_pass = CredentialManagementRest.login callerid, email, new_password

      # Login with old password
      response_login_old_pass = CredentialManagementRest.login callerid, email, password
    end

    it 'Verify response status is true when calling changed password.' do
      expect(response['status']).to eq(true)
    end

    it 'Verify can login successfully with the new password.' do
      expect(response_login_new_pass['status']).to eq(true)
    end

    it 'Verify token is generated after login successful with the new password.' do
      expect(response_login_new_pass['data']['token']).not_to be_empty
    end

    it 'Verify can not login successfully with the old password.' do
      expect(response_login_old_pass['status']).to eq(false)
    end

    it "Verify faultCode is 'BADPASSWORD' when login with the old password" do
      expect(response_login_old_pass['data']['faultCode']).to eq('BADPASSWORD')
    end
  end

  context "6. Verify status is true when calling reset service. (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_RESET_PASSWORD})" do
    before :all do
      response = CredentialManagementRest.reset_password callerid, email
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end
  end

  context "7. Verify server will return error message when calling reset service with invalid email. (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_RESET_PASSWORD})" do
    before :all do
      response = CredentialManagementRest.reset_password callerid, invalid_email
    end

    it 'Verify response status is false' do
      expect(response['status']).to eq(false)
    end

    it "Verify faultCode is 'NOSUCHUSER'" do
      expect(response['data']['faultCode']).to eq('NOSUCHUSER')
    end

    it "Verify faultType is 'com.leapfrog.services.inmon.faults.AccessDeniedFault'" do
      expect(response['data']['faultType']).to eq('com.leapfrog.services.inmon.faults.AccessDeniedFault')
    end

    it "Verify message is 'That email address is not connected to a LeapFrog account. Please try again.'" do
      expect(response['data']['message']).to eq('That email address is not connected to a LeapFrog account. Please try again.')
    end
  end
end
