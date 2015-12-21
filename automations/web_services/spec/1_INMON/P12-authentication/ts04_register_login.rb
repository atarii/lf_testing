require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'

=begin
Verify registerLogin service works correctly
=end

describe "TS04.001 - registerLogin - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:authentication_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:authentication_management][:namespace]
  caller_id = Misc::CONST_CALLER_ID
  session = 'dba85681-a9ae-4f20-98a4-fb12102edeaf'
  username = 'pm20140113102353835us@leapfrog.test'
  customer_id = '2847416'
  res = nil

  context 'TC04.001 - registerLogin - Successfully Response' do
    soap_fault = nil

    before :all do
      xml_res = Authentication.register_login(caller_id, session, customer_id, username)
      soap_fault = xml_res.xpath('//faultstring').count
    end

    it "Verify 'registerLogin' calls successfully" do
      expect(soap_fault).to eq(0)
    end
  end

  context 'TC04.002 - registerLogin - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Authentication.register_login(caller_id2, session, customer_id, username)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC04.003 - registerLogin - Invalid Session' do
    session3 = 'invalid_dba85681-a9ae-4f20-98a4-fb12102edeaf'

    before :all do
      res = Authentication.register_login(caller_id, session3, customer_id, username)
    end

    it "Verify 'InvalidSessionFault' error responses" do
      expect(res).to eq('Inconsistent request: customer-id does not match session-id')
    end
  end

  context 'TC04.004 - registerLogin - Invalid Customer id' do
    customer_id4 = 'invalid2847416'

    before :all do
      res = Authentication.register_login(caller_id, session, customer_id4, username)
    end

    it "Response should return fault message 'customer-id is invalid'" do
      expect(res).to eq('customer-id is invalid')
    end
  end

  context 'TC04.006 - registerLogin - Empty Source Value' do
    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_login,
        "<caller-id>#{caller_id}</caller-id>
        <session type='service'>#{session}</session>
        <customer-id>#{customer_id}</customer-id>
        <customer-name>#{username}</customer-name>
        <source/>"
      )
    end

    it "Verify 'Attribute source can be neither null nor empty.' error responses" do
      expect(res).to eq('Attribute source can be neither null nor empty.')
    end
  end
end
