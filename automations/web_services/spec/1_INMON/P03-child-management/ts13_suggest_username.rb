require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'

=begin
Verify suggestUsername service works correctly
=end

describe "TS13 - suggestUsername - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:namespace]
  session = nil

  before :all do
    reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
    ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_info[:id])
  end

  context 'TC13.001 - suggestUsername - Successful Response' do
    limit = 2
    username_exp = 'rio'
    user_names_act = nil
    nob_user_names = nil

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :suggest_username,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <child name='rio'><credentials username='#{username_exp}' password='123456'/></child>
        <limit>#{limit}</limit>"
      )

      nob_user_names = res.xpath('//usernames').count
      user_names_act = res.xpath('//usernames/text()')
    end

    it 'Verify number of suggest usernames equal to limit field' do
      expect(nob_user_names).to eq(limit)
    end

    it 'Verify returned username contains input username(e.g input username = "rio", returned usernames = "rio111", "222rio")' do
      user_names_act.each do |username|
        expect(username.text).to include(username_exp)
      end
    end
  end

  context 'TC13.002 - suggestUsername - Invalid CallerID' do
    res = nil

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :suggest_username,
        "<caller-id>invalid</caller-id>
        <session type='service'>#{session}</session>
        <child name='rio'><credentials username='rio' password='123456'/></child>
        <limit>2</limit>"
      )
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC13.003 - suggestUsername - Invalid Request' do
    res = nil

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :suggest_username,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>#{session}</session>
         <child name='rio'><credentials username='' password='123456'/></child>
         <limit>2</limit>"
      )
    end

    it 'Verify faultstring is returned: missing username' do
      expect(res).to eq('missing username')
    end
  end

  context 'TC13.004 - suggestUsername - Access Denied' do
    res = nil

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :suggest_username,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>invalid</session>
         <child name='rio'><credentials username='rio' password='123456'/></child>
         <limit>2</limit>"
      )
    end

    it 'Verify faultstring is returned: Session is invalid: invalid' do
      expect(res).to eq('Session is invalid: invalid')
    end
  end
end
