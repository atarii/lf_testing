require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'

=begin
Verify verifyServiceSession service works correctly
=end

describe "TS05 - verifyServiceSession - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  session, res = nil

  before :all do
    username = email = LFCommon.generate_email
    CustomerManagement.register_customer(caller_id, CustomerManagement.generate_screenname, email, username)
    session = Authentication.acquire_service_session(caller_id, username, '123456').xpath('//session').text
  end

  context 'TC05.001 - verifyServiceSession - Successfully Response' do
    valid = nil

    before :all do
      res = Authentication.verify_service_session(caller_id, session)
      valid = res.xpath('//valid').text
    end

    it "Verify 'verifyServiceSession' calls successfully" do
      expect(valid).to eq('true')
    end
  end

  context 'TC05.002 - verifyServiceSession - Invalid CallerID' do
    before :all do
      res = Authentication.verify_service_session('invalid', session)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC05.003 - verifyServiceSession - Invalid Session' do
    valid = nil

    before :all do
      res = Authentication.verify_service_session(caller_id, 'invaliddba85681-a9ae-4f20-98a4-fb12102edeaf')
      valid = res.xpath('//valid').text
    end

    it "Verify 'verifyServiceSession' calls successfully" do
      expect(valid).to eq('false')
    end
  end
end
