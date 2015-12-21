require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'

=begin
Verify listChildren service works correctly
=end

describe "TS03 - listChildren - #{Misc::CONST_ENV}" do
  cus_id = nil
  session = nil

  before :all do
    reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    cus_id = cus_info[:id]

    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
  end

  context 'TC03.001 - listChildren - Successful Response' do
    count_children = nil

    before :all do
      ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_id)
      ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_id)

      # call listChildren
      lis_child_res = ChildManagement.list_children(Misc::CONST_CALLER_ID, session, cus_id)
      count_children = lis_child_res.xpath('count( //child)').to_s.to_i
    end

    it 'Verify number of children-->2' do
      expect(count_children).to eq(2)
    end
  end

  context 'TC03.002 - listChildren - Invalid CallerID' do
    lis_child_res = nil

    before :all do
      lis_child_res = ChildManagement.list_children('invalid', session, cus_id)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(lis_child_res).to eq('Error while checking caller id')
    end
  end

  context 'TC03.003 - listChildren - Access Denied' do
    lis_child_res = nil

    before :all do
      lis_child_res = ChildManagement.list_children(Misc::CONST_CALLER_ID, 'invalid', cus_id)
    end

    it 'Verify faultstring is returned: Session is invalid: invalid' do
      expect(lis_child_res).to eq('Session is invalid: invalid')
    end
  end

  context 'TC03.004 - listChildren - Invalid Request' do
    lis_child_res = nil

    before :all do
      lis_child_res = ChildManagement.list_children(Misc::CONST_CALLER_ID, session, cus_id)
    end

    it 'just assert for valid soap call' do
      valid_call = lis_child_res.xpath('count(//listChildrenResponse)').to_s.to_i
      expect(valid_call).to eq(0)
    end
  end
end
