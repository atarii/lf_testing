require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'

=begin
Verify removeChild service works correctly
=end

describe "TS06 - removeChild - #{Misc::CONST_ENV}" do
  session = nil
  child_id = nil

  before :all do
    reg_cus_response =  CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
    reg_chi_response = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_info[:id])

    child_id = reg_chi_response.xpath('//child/@id').text
  end

  context 'TC06.001 - removeChild - Successful Response' do
    rem_chi_res = nil

    before :all do
      ChildManagement.remove_child(Misc::CONST_CALLER_ID, session, child_id)
      rem_chi_res = ChildManagement.remove_child(Misc::CONST_CALLER_ID, session, child_id)
    end

    it 'Verify error message is returned when removing a nonexistent child: there is no parent/child relationship between the customer and child' do
      expect(rem_chi_res).to eq('there is no parent/child relationship between the customer and child')
    end
  end

  context 'TC06.002 - removeChild - Invalid CallerID' do
    rem_chi_res = nil

    before :all do
      rem_chi_res = ChildManagement.remove_child('invalid', session, child_id)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(rem_chi_res).to eq('Error while checking caller id')
    end
  end

  context 'TC06.003 - removeChild - Invalid Request' do
    rem_chi_res = nil

    before :all do
      rem_chi_res = ChildManagement.remove_child(Misc::CONST_CALLER_ID, session, 'aaaaaa')
    end

    it 'Verify faultstring is returned: there is no parent/child relationship between the customer and child' do
      expect(rem_chi_res).to eq('there is no parent/child relationship between the customer and child')
    end
  end

  context 'TC06.004 - removeChild - Access Denied' do
    rem_chi_res = nil

    before :all do
      rem_chi_res = ChildManagement.remove_child(Misc::CONST_CALLER_ID, 'invalid', child_id)
    end

    it 'Verify faultstring is returned: Session is invalid: invalid' do
      expect(rem_chi_res).to eq('Session is invalid: invalid')
    end
  end

  context 'TC06.005 - removeChild - Nonexistent Child' do
    rem_chi_res = nil

    before :all do
      rem_chi_res = ChildManagement.remove_child(Misc::CONST_CALLER_ID, session, '1')
    end

    it 'Verify faultstring is returned: there is no parent/child relationship between the customer and child' do
      expect(rem_chi_res).to eq('there is no parent/child relationship between the customer and child')
    end
  end
end
