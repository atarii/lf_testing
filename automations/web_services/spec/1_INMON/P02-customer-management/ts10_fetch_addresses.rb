require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify fetchAddress service works correctly
=end

describe "TS10 - fetchAddresses - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  customer_id = nil
  type = 'shipping'
  unit = '113'
  street = 'street'
  city = 'Washington'
  country = 'United States of America'
  province = 'province'
  postal_code = '94600'
  res = nil

  it 'Precondition - register customer' do
    register_response1 = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_response = CustomerManagement.get_customer_info(register_response1)
    customer_id = arr_response[:id]
  end

  context 'TC10.001 - fetchAddresses - Successful Response' do
    xml_fetch_address = nil

    before :all do
      CustomerManagement.add_address(caller_id, customer_id, username, type, street, unit, city, country, province, postal_code)
      xml_fetch_address = CustomerManagement.fetch_addresses(caller_id, customer_id, username)
    end

    it 'Check Type: ' do
      expect(xml_fetch_address.xpath('//address').attr('type').text).to eq(type)
    end

    it 'Check Unit: ' do
      expect(xml_fetch_address.xpath('//address/street').attr('unit').text).to eq(unit)
    end

    it 'Check Street: ' do
      expect(xml_fetch_address.xpath('//address/street').text).to eq(street)
    end

    it 'Check City: ' do
      expect(xml_fetch_address.xpath('//address/region').attr('city').text).to eq(city)
    end

    it 'Check Country: ' do
      expect(xml_fetch_address.xpath('//address/region').attr('country').text).to eq(country)
    end

    it 'Check Province: ' do
      expect(xml_fetch_address.xpath('//address/region').attr('province').text).to eq(province)
    end

    it 'Check Postal Code: ' do
      expect(xml_fetch_address.xpath('//address/region').attr('postal-code').text).to eq(postal_code)
    end
  end

  context 'TC10.002 - fetchAddresses - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CustomerManagement.fetch_addresses(caller_id2, customer_id, username)
    end

    it "Verify 'Error while checking caller id' error message displays" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC10.003 - fetchAddresses - Access Denied' do
    customer_id3 = '-1234'

    before :all do
      res = CustomerManagement.fetch_addresses(caller_id, customer_id3, username)
    end

    it "Verify 'An invalid customer or customer id was provided to execute this call' error message displays" do
      expect(res).to eq('An invalid customer or customer id was provided to execute this call')
    end
  end

  context 'TC10.004 - fetchAddresses - Invalid Request' do
    customer_id4 = 'aaaaa'

    before :all do
      res = CustomerManagement.fetch_addresses(caller_id, customer_id4, username)
    end

    it "Verify 'There was a problem while executing the call, an invalid or empty customer was provided' error message displays" do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer was provided')
    end
  end

  context 'TC10.005 - fetchAddresses - Customer id is null' do
    customer_id5 = ''

    before :all do
      res = CustomerManagement.fetch_addresses(caller_id, customer_id5, username)
    end

    it "Verify 'There was a problem while executing the call, an invalid or empty customer was provided' error message displays" do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer was provided')
    end
  end

  context 'TC10.006 - fetchAddresses - Customer id is so long' do
    customer_id6 = 'In this guide you will learn how to create a data driven test, add a data source, assert the data, and run the test. This feature is only available in SoapUI Pro, so you should download SoapUI Pro Trial before starting, if you don'

    before :all do
      res = CustomerManagement.fetch_addresses(caller_id, customer_id6, username)
    end

    it "Verify 'There was a problem while executing the call, an invalid or empty customer was provided' error message displays" do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer was provided')
    end
  end
end
