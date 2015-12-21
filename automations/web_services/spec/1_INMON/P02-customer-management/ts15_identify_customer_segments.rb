require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify identifyCustomerSegments service works correctly
=end

describe "TS15 - identifyCustomerSegments - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  customer_id = nil
  password = '123456'
  res = nil

  it 'Precondition - register customer' do
    response = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    xml_response = CustomerManagement.get_customer_info(response)
    customer_id = xml_response[:id]
  end

  context 'TC15.001 - identifyCustomerSegments - Successful Response' do
    resp_id = resp_username = resp_email = nil

    before :all do
      xml_res = CustomerManagement.identify_customer_segments(caller_id, username, password)
      resp_id = xml_res.xpath('//customer').attr('id').text
      resp_username = xml_res.xpath('//customer/credentials').attr('username').text
      resp_email = xml_res.xpath('//customer/email').text
    end

    it 'Check Customer ID responses: ' do
      expect(resp_id).to eq(customer_id)
    end

    it 'Check Username responses: ' do
      expect(resp_username).to eq(username)
    end

    it 'Check Customer Email responses: ' do
      expect(resp_email).to eq(email)
    end
  end

  context 'TC15.002 - identifyCustomerSegments - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CustomerManagement.identify_customer_segments(caller_id2, username, password)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC15.003 - identifyCustomerSegments - Access Denied' do
    username3 = 'nonexistence'

    before :all do
      res = CustomerManagement.identify_customer_segments(caller_id, username3, password)
    end

    it "Verify 'A customer for the given credentials doesn't exist.' error message responses" do
      expect(res).to eq("A customer for the given credentials doesn't exist.")
    end
  end

  context 'TC15.004 - identifyCustomerSegments - Invalid Request' do
    username4 = ''
    password4 = ''

    before :all do
      res = CustomerManagement.identify_customer_segments(caller_id, username4, password4)
    end

    it "Verify 'A customer for the given credentials doesn't exist.' error message responses" do
      expect(res).to eq("A customer for the given credentials doesn't exist.")
    end
  end
end
