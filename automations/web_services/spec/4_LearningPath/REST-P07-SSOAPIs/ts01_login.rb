require File.expand_path('../../../spec_helper', __FILE__)
require 'credential_management'

=begin
REST call: Verify Login service works correctly
=end

describe "TS01 - Login - For Baby Center Model - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  email = Misc::CONST_ACCOUNT
  password = '123456'
  res = nil

  context 'TC01.001 - Login - SuccessfulResponse' do
    before :all do
      res = CredentialManagementRest.login(caller_id, email, password)
    end

    it 'Verify response [status] is true' do
      expect(res['status']).to eq(true)
    end

    it 'Match content of [parentEmail]' do
      expect(res['data']['parent']['parentEmail']).to eq(email)
    end
  end

  context 'TC01.002 - Login - Invalid Email' do
    email2 = 'invalid'

    before :all do
      res = CredentialManagementRest.login(caller_id, email2, password)
    end

    it 'Verify response [status] is false' do
      expect(res['status']).to eq(false)
    end

    it "Verify error message is 'invalid email address '" + email2 + "''" do
      expect(res['data']['message']).to eq("invalid email address '" + email2 + "'")
    end
  end

  context 'TC01.003 - Login - Invalid Password' do
    password3 = 'invalid'

    before :all do
      res = CredentialManagementRest.login(caller_id, email, password3)
    end

    it 'Verify response [status] is false' do
      expect(res['status']).to eq(false)
    end

    it "Verify error message is '#{ErrorMessageConst::INVALID_PASSWORD_MESSAGE}'" do
      expect(res['data']['message']).to eq(ErrorMessageConst::INVALID_PASSWORD_MESSAGE)
    end
  end

  context 'TC01.004 - Login - Empty inputs' do
    before :all do
      res = CredentialManagementRest.login('', '', '')
    end

    it "Verify error message is 'invalid email address '''" do
      expect(res['data']['message']).to eq("invalid email address ''")
    end
  end
end
