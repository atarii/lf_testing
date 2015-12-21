require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify addPhone service works correctly
=end

describe "TS09 - addPhone - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  customer_id = nil
  type = 'work'
  extension = '1'
  number = LFCommon.get_current_time

  it 'Precondition - register customer' do
    res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_response = CustomerManagement.get_customer_info(res)
    customer_id = arr_response[:id]
  end

  context 'TC09.001 - addPhone - Successful Response' do
    type1 = number1 = nil

    before :all do
      CustomerManagement.add_phone(caller_id, customer_id, username, number, type, extension)

      # Fetch customer info and get phone info
      xml_fetch_cus_res = CustomerManagement.fetch_customer(caller_id, customer_id)
      number1 = xml_fetch_cus_res.xpath('//customer/phone').attr('number').text
      type1 = xml_fetch_cus_res.xpath('//customer/phone').attr('type').text
    end

    it 'Check Number: ' do
      expect(number1).to eq(number + ' ext. ' + extension)
    end

    it 'Check Type: ' do
      expect(type1).to eq(type)
    end
  end

  context 'TC09.002 - addPhone - Invalid CallerID' do
    caller_id2 = 'invalid'
    res = nil

    before :all do
      res = CustomerManagement.add_phone(caller_id2, customer_id, username, number, type, extension)
    end

    it "Verify 'Error while checking caller id' error message displays" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC09.003 - addPhone - Access Denied' do
    username3 = ''
    customer_id3 = '-123'
    res = nil

    before :all do
      res = CustomerManagement.add_phone(caller_id, customer_id3, username3, number, type, extension)
    end

    it "Verify 'An invalid customer or customer id was provided to execute this call' error message displays" do
      expect(res).to eq('An invalid customer or customer id was provided to execute this call')
    end
  end

  context 'TC09.004 - addPhone - Invalid Request' do
    username4 = ''
    customer_id4 = 'invalid'
    res = nil

    before :all do
      res = CustomerManagement.add_phone(caller_id, customer_id4, username4, number, type, extension)
    end

    it "Verify 'Unable to execute the service call, an invalid/empty customer id or phone information was provided.' error message displays" do
      expect(res).to eq('Unable to execute the service call, an invalid/empty customer id or phone information was provided.')
    end
  end

  context 'TC09.006 - addPhone - one more phone number' do
    res = nil

    before :all do
      res = CustomerManagement.add_phone(caller_id, customer_id, username, '', type, extension)
    end

    it "Verify 'Unable to execute the call, there was a problem with data access.' error message displays" do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end

  context 'TC09.007 - addPhone - Number is so long characters' do
    number7 = '1234567898765432123456789'
    res = nil

    before :all do
      res = CustomerManagement.add_phone(caller_id, customer_id, username, number7, type, extension)
    end

    it "Verify 'Unable to execute the call, there was a problem with data access.' error message displays" do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end

  context 'TC09.008 - addPhone - Number with special characters' do
    number8 = '@#@#@#@#@#@#'
    res = nil

    before :all do
      res = CustomerManagement.add_phone(caller_id, customer_id, username, number8, type, extension)
    end

    it "Verify 'Unable to execute the call, there was a problem with data access.' error message displays" do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end

  context 'TC09.009 - addPhone - Negative number' do
    number9 = '-123456789'
    res = nil

    before :all do
      res = CustomerManagement.add_phone(caller_id, customer_id, username, number9, type, extension)
    end

    it "Verify 'Unable to execute the call, there was a problem with data access.' error message displays" do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end
end
