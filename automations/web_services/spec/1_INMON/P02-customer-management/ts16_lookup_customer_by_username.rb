require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

describe "TS16 - lookupCustomerByUsername - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  customer_id = nil
  res = nil

  it 'Precondition - register customer' do
    res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    xml_res = CustomerManagement.get_customer_info(res)
    customer_id = xml_res[:id]
  end

  context 'TC16.001 - lookupCustomerByUsername - Successful Response' do
    res_id = res_username = res_email = nil

    before :all do
      xml_res = CustomerManagement.lookup_customer_by_username(caller_id, username)
      res_id = xml_res.xpath('//customer').attr('id').text
      res_username = xml_res.xpath('//customer/credentials').attr('username').text
      res_email = xml_res.xpath('//customer/email').text
    end

    it 'Check Customer ID responses: ' do
      expect(res_id).to eq(customer_id)
    end

    it 'Check Username responses: ' do
      expect(res_username).to eq(username)
    end

    it 'Check Customer Email responses: ' do
      expect(res_email).to eq(email)
    end
  end

  context 'TC16.002 - lookupCustomerByUsername - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CustomerManagement.lookup_customer_by_username(caller_id2, username)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC16.003 - lookupCustomerByUsername - Access Denied' do
    username3 = 'nonexistence'

    before :all do
      res = CustomerManagement.lookup_customer_by_username(caller_id, username3)
    end

    it "Verify 'A customer for the given credentials doesn't exist.' error message responses" do
      expect(res).to eq("A customer for the given credentials doesn't exist.")
    end
  end

  context 'TC16.004 - lookupCustomerByUsername - Invalid Request' do
    username4 = ''

    before :all do
      res = CustomerManagement.lookup_customer_by_username(caller_id, username4)
    end

    it "Verify 'A customer for the given credentials doesn't exist.' error message responses" do
      expect(res).to eq("A customer for the given credentials doesn't exist.")
    end
  end
end
