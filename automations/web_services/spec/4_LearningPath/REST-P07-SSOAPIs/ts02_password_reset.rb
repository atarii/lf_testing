require File.expand_path('../../../spec_helper', __FILE__)
require 'credential_management'

=begin
REST call: Verify resetPassword service works correctly
=end

describe "TS02 - Password Reset - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  email = Misc::CONST_ACCOUNT
  res = nil

  context 'TC02.001 - Password Reset - SuccessfulResponse' do
    before :all do
      res = CredentialManagementRest.reset_password(caller_id, email)
    end

    it 'Verify response [status] is true' do
      expect(res['status']).to eq(true)
    end
  end

  context 'TC02.002 - Password Reset - Invalid Email' do
    email2 = 'invalid'

    before :all do
      res =  CredentialManagementRest.reset_password(caller_id, email2)
    end

    it 'Verify response [status] is false' do
      expect(res['status']).to eq(false)
    end

    it "Verify error message is 'invalid email address '" + email2 + "''" do
      expect(res['data']['message']).to eq("invalid email address '" + email2 + "'")
    end
  end

  context 'TC02.003 - Password Reset - Empty Email' do
    email3 = ''

    before :all do
      res = CredentialManagementRest.reset_password(caller_id, email3)
    end

    it 'Verify response [status] is false' do
      expect(res['status']).to eq(false)
    end

    it "Verify error message is 'invalid email address '''" do
      expect(res['data']['message']).to eq("invalid email address ''")
    end
  end
end
