require File.expand_path('../../../spec_helper', __FILE__)
require 'credential_management'
require 'parent_management'

=begin
REST call: Verify changePassword service works correctly
=end

describe "TS03  - Change Password - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  email = LFCommon.generate_email
  password = '123456'
  firstname = 'ltrc'
  lastname = 'vn'
  email_optin = 'true'
  locale = 'en_US'
  session = nil
  new_pass = current_pass = '654321'
  res = nil

  it 'Precondition - Create Parent' do
    create_parent_res = ParentManagementRest.create_parent(caller_id, email, password, firstname, lastname, email_optin, locale)
    session = create_parent_res['data']['token']
  end

  context 'TC03.001 - Change Password - SuccessfulResponse' do
    login_res1 = login_res2 = nil

    before :all do
      login_res1 = CredentialManagementRest.login(caller_id, email, password)
      CredentialManagementRest.change_password(caller_id, session, password, new_pass)
      login_res2 = CredentialManagementRest.login(caller_id, email, new_pass)
    end

    it 'Verify response [status] is true' do
      expect(login_res1['status']).to eq(true)
    end

    it 'Match content of [parentEmail]' do
      expect(login_res1['data']['parent']['parentEmail']).to eq(email)
    end

    it 'Verify response [status] is true' do
      expect(login_res2['status']).to eq(true)
    end

    it 'Match content of [parentEmail]' do
      expect(login_res2['data']['parent']['parentEmail']).to eq(email)
    end
  end

  context 'TC03.002 - Change Password - Access Denied' do
    session2 = 'invalid'

    before :all do
      res = CredentialManagementRest.change_password(caller_id, session2, current_pass, new_pass)
    end

    it "Verify error message is 'Can not find session: " + session2 + "'" do
      expect(res['data']['message']).to eq('Can not find session: ' + session2)
    end
  end

  context 'TC03.003 - Change Password - Invalid current pass' do
    current_pass3 = 'invalid'

    before :all do
      res = CredentialManagementRest.change_password(caller_id, session, current_pass3, new_pass)
    end

    it "Verify error message is 'given password does not match customer's current password'" do
      expect(res['data']['message']).to eq("given password does not match customer's current password")
    end
  end

  context 'TC03.004 - Change Password - Invalid New Password' do
    new_pass_4 = '123'

    before :all do
      res = CredentialManagementRest.change_password(caller_id, session, current_pass, new_pass_4)
    end

    it "Verify error message is 'An invalid customer password was provided.'" do
      expect(res['data']['message']).to eq('An invalid customer password was provided.')
    end
  end
end
