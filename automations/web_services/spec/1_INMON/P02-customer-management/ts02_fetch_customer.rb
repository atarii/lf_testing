require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify fetchCustomer service works correctly
=end

describe "TS02 - fetchCustomer - #{Misc::CONST_ENV}" do
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

  context 'TC02.001 - fetchCustomer - Successful Response' do
    response_id = nil

    before :all do
      res = CustomerManagement.fetch_customer(caller_id, customer_id)
      response_id = res.xpath('//customer').attr('id').text
    end

    it "Check 'Verify customer ID is returned correctly: " do
      expect(customer_id).to eq(response_id)
    end
  end

  context 'TC02.002 - fetchCustomer - Invalid CallerID' do
    invalid_caller_id = 'invalid'

    before :all do
      res = CustomerManagement.fetch_customer(invalid_caller_id, customer_id)
    end

    it "Check 'Error while checking caller id' error message displays: " do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC02.003 - fetchCustomer - Nonexistant Customer' do
    customer_id3 = '1234'

    before :all do
      res = CustomerManagement.fetch_customer(caller_id, customer_id3)
    end

    it "Check 'A RuntimeException was thrown.' error message displays: " do
      expect(res).to eq('A RuntimeException was thrown.')
    end
  end

  context 'TC02.005 - fetchCustomer - Invalid Request' do
    customer_id5 = 'abc123'

    before :all do
      res = CustomerManagement.fetch_customer(caller_id, customer_id5)
    end

    it "Check 'There was a problem while executing the call, an invalid or empty customer id or email information was provided' error message displays: " do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer id or email information was provided')
    end
  end
end
