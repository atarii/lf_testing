require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'

=begin
Verify acquireServiceSession service works correctly
=end

describe "TS01 - acquireServiceSession - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  res = nil

  context 'Pre-condition - register customer' do
    CustomerManagement.register_customer(caller_id, screen_name, email, username)
  end

  context 'TC01.001 - acquireApplicationSession - Successfully Response' do
    session = nil

    before :all do
      res = Authentication.acquire_service_session(caller_id, username, password)
      session = res.xpath('//session').text
    end

    it 'Check for existence of session: ' do
      expect(session).not_to be_empty
    end
  end

  context 'TC01.002 - acquireApplicationSession - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Authentication.acquire_service_session(caller_id2, username, password)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - acquireApplicationSession - Invalid Username' do
    username3 = 'invalidusername@leapfrog.test'

    before :all do
      res = Authentication.acquire_service_session(caller_id, username3, password)
    end

    it "Verify '#{ErrorMessageConst::INVALID_EMAIL_MESSAGE}' error message responses" do
      expect(res).to eq(ErrorMessageConst::INVALID_EMAIL_MESSAGE)
    end
  end

  context 'TC01.004 - acquireApplicationSession - Invalid Password' do
    password4 = 'invalid123456'

    before :all do
      res = Authentication.acquire_service_session(caller_id, username, password4)
    end

    it "Verify '#{ErrorMessageConst::INVALID_PASSWORD_MESSAGE}' error message responses" do
      expect(res).to eq(ErrorMessageConst::INVALID_PASSWORD_MESSAGE)
    end
  end
end
