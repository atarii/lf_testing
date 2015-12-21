require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'product_registration'
require 'recommendation'

=begin
Verify fetchConnectedProducts service works correctly
=end

describe "TS01 - fetchConnectedProducts - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  device_serial = DeviceManagement.generate_serial
  customer_id = child_id = nil
  type = 'ECOM'
  game_log_nbr = '2031625'
  response = nil

  it 'Precondition - register customer' do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res1 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = xml_register_child_res1.xpath('//child').attr('id').text

    LFCommon.soap_call(
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:endpoint],
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:namespace],
      :claim_device,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device serial='#{device_serial}' auto-create='false' product-id='0' platform='emerald' pin='1111'>
        <profile slot='0' name='profile1' points='0' rewards='0' weak-id='1' uploadable='true' claimed='false' dob='2006-10-31+07:00' grade='3' gender='male' child-id='#{child_id}' auto-create='false'/>
      </device>"
    )
  end

  context 'TC01.001 - fetchConnectedProducts - Successful Request' do
    title_name = nil

    before :all do
      ProductRegistration.register_products(caller_id, customer_id, type, child_id, game_log_nbr)

      xml_response = Recommendation.fetch_connected_products(caller_id, customer_id)
      title_name = xml_response.xpath('//title').attr('name').text
    end

    it "Verify 'fetchConnectedProducts' calls successfully" do
      expect(title_name).to eq('LeapPad Story Studio App: All About Me')
    end
  end

  context 'TC01.002 - fetchConnectedProducts - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      response = Recommendation.fetch_connected_products(caller_id2, customer_id)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(response).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - fetchConnectedProducts - Invalid CustomerID' do
    customer_id3 = 'invalid'

    before :all do
      response = Recommendation.fetch_connected_products(caller_id, customer_id3)
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided for customer id.' error responses" do
      expect(response).to eq('Unable to execute the requested call, an invalid or empty argument was provided for customer id.')
    end
  end

  context 'TC01.004 - fetchConnectedProducts - customer id is null' do
    customer_id4 = ''

    before :all do
      response = Recommendation.fetch_connected_products(caller_id, customer_id4)
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided for customer id.' error responses" do
      expect(response).to eq('Unable to execute the requested call, an invalid or empty argument was provided for customer id.')
    end
  end

  context 'TC01.005 - fetchConnectedProducts - customer id is so long' do
    customer_id5 = 'TC01.005 - fetchConnectedProducts - customer id is so long'

    before :all do
      response = Recommendation.fetch_connected_products(caller_id, customer_id5)
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided for customer id.' error responses" do
      expect(response).to eq('Unable to execute the requested call, an invalid or empty argument was provided for customer id.')
    end
  end

  context 'TC01.006 - fetchConnectedProducts - customer id is special characters' do
    customer_id6 = '@#@#@'

    before :all do
      response = Recommendation.fetch_connected_products(caller_id, customer_id6)
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided for customer id.' error responses" do
      expect(response).to eq('Unable to execute the requested call, an invalid or empty argument was provided for customer id.')
    end
  end

  context 'TC01.007 - fetchConnectedProducts - customer id is negative number' do
    customer_id7 = '-1034343'

    before :all do
      response = Recommendation.fetch_connected_products(caller_id, customer_id7)
    end

    it 'Report known issue' do
      expect(response).to eq("Issue #44: No fault string is returned when requesting the service \"fetchConnectedProducts\" with a customer-id that doesn't exist or is negative number")
    end
  end
end
