require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'

=begin
Verify listTitles service works correctly
=end

describe "TS12 - listTitles - #{Misc::CONST_ENV}" do
  session = nil
  child_id = nil
  cus_info = nil

  before :all do
    reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
    reg_chi_response = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_info[:id])

    child_id = reg_chi_response.xpath('//child/@id').text
  end

  context 'TC12.001 - listTitles - Successful Response' do
    res = nil
    before :all do
      endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:endpoint]
      namespace = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:namespace]

      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :list_titles,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <customer-id>#{cus_info[:id]}</customer-id>
        <child-id>#{child_id}</child-id>"
      )
    end

    it 'Verify listTitles call successfully' do
      if res.include?('Unable to fetchTitles for customerId')
        expect("#36899: Web Services: listTitles: The 'Unable to fetchTitles for customerId and childId' error responses").to eq(200)
      else
        expect(res.xpath('//faultcode').count).to eq(0)
      end
    end
  end

  context 'TC12.002 - listTitles - Invalid CallerID' do
    res = nil

    before :all do
      res = ChildManagement.list_titles('invalid', session, child_id)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC12.003 - listTitles - Invalid Request' do
    res = nil

    before :all do
      res = ChildManagement.list_titles(Misc::CONST_CALLER_ID, session, 'invalid')
    end

    it 'Verify faultstring is returned: there is no parent/child relationship between the customer and child' do
      expect(res).to eq('there is no parent/child relationship between the customer and child')
    end
  end

  context 'TC12.004 - listTitles - Access Denied' do
    res = nil

    before :all do
      res = ChildManagement.list_titles(Misc::CONST_CALLER_ID, 'invalid', child_id)
    end

    it 'Verify faultstring is returned: Session is invalid: invalid' do
      expect(res).to eq('Session is invalid: invalid')
    end
  end

  context 'TC12.005 - listTitles - Nonexistent Child' do
    res = nil

    before :all do
      res = ChildManagement.list_titles(Misc::CONST_CALLER_ID, session, 1111)
    end

    it 'Verify faultstring is returned: there is no parent/child relationship between the customer and child' do
      expect(res).to eq('there is no parent/child relationship between the customer and child')
    end
  end
end
