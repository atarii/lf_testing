require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify addAddress service works correctly
=end

describe "TS08 - addAddress - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  customer_id = nil
  type = 'shipping'
  unit = 'unit'
  street = 'street'
  city = 'Washington'
  country = 'United States of America'
  province = 'province'
  postal_code = '94600'
  res = nil

  it 'Precondition - register customer' do
    res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_response = CustomerManagement.get_customer_info(res)
    customer_id = arr_response[:id]
  end

  context 'TC8.001 - addAddress - Successful Response' do
    fetch_cus_res = nil

    before :all do
      CustomerManagement.add_address(caller_id, customer_id, username, type, street, unit, city, country, province, postal_code)
      fetch_cus_res = CustomerManagement.fetch_customer(caller_id, customer_id)
    end

    it 'Check ID: ' do
      expect(fetch_cus_res.xpath('//customer/address').attr('id').text).not_to be_empty
    end

    it 'Check Type: ' do
      expect(fetch_cus_res.xpath('//customer/address').attr('type').text).to eq(type)
    end

    it 'Check Unit: ' do
      expect(fetch_cus_res.xpath('//customer/address/street').attr('unit').text).to eq(unit)
    end

    it 'Check Street: ' do
      expect(fetch_cus_res.xpath('//customer/address/street').text).to eq(street)
    end

    it 'Check City: ' do
      expect(fetch_cus_res.xpath('//customer/address/region').attr('city').text).to eq(city)
    end

    it 'Check Country: ' do
      expect(fetch_cus_res.xpath('//customer/address/region').attr('country').text).to eq(country)
    end

    it 'Check Province: ' do
      expect(fetch_cus_res.xpath('//customer/address/region').attr('province').text).to eq(province)
    end

    it 'Check Postal Code: ' do
      expect(fetch_cus_res.xpath('//customer/address/region').attr('postal-code').text).to eq(postal_code)
    end
  end

  context 'TC8.002 - addAddress - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CustomerManagement.add_address(caller_id2, customer_id, username, type, street, unit, city, country, province, postal_code)
    end

    it "Verify 'Error while checking caller id' error message displays" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC8.003 - addAddress - Nonexistant Customer' do
    customer_id3 = '-12345'

    before :all do
      res = CustomerManagement.add_address(caller_id, customer_id3, username, type, street, unit, city, country, province, postal_code)
    end

    it "Verify 'An invalid customer or customer id was provided to execute this call' error message displays" do
      expect(res).to eq('An invalid customer or customer id was provided to execute this call')
    end
  end

  context 'TC8.004 - addAddress - Invalid Request' do
    username4 = ''
    customer_id4 = 'abc'

    before :all do
      res = CustomerManagement.add_address(caller_id, customer_id4, username4, type, street, unit, city, country, province, postal_code)
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided.' error message displays" do
      expect(res).to eq('Unable to execute the requested call, an invalid or empty argument was provided.')
    end
  end

  context 'TC8.005 - addAddress - Address is null' do
    xml_res = nil

    before :all do
      xml_res = CustomerManagement.add_address(caller_id, customer_id, username, '', '', '', '', '', '', '')
    end

    it 'Check Unit: ' do
      expect(xml_res.xpath('//address/street').attr('unit').text).to eq('')
    end

    it 'Check City: ' do
      expect(xml_res.xpath('//address/region').attr('city').text).to eq('')
    end

    it 'Check Country: ' do
      expect(xml_res.xpath('//address/region').attr('country').text).to eq('')
    end

    it 'Check Province: ' do
      expect(xml_res.xpath('//address/region').attr('province').text).to eq('')
    end

    it 'Check Postal Code: ' do
      expect(xml_res.xpath('//address/region').attr('postal-code').text).to eq('')
    end
  end
end
