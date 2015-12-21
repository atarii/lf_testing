require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'product_registration'

=begin
Verify listRegisteredProducts service works correctly
=end

describe "TS02 - listRegisteredProducts - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  device_serial = DeviceManagement.generate_serial
  customer_id = child_id = nil
  type = 'ECOM'
  game_log_nbr = '2031625'
  res = nil

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

  context 'TC02.001 - listRegisteredProducts  - Successful Request' do
    product_num1 = nil
    child_id1 = nil

    before :all do
      ProductRegistration.register_products(caller_id, customer_id, type, child_id, game_log_nbr)

      xml_list_product_res = ProductRegistration.list_registered_products(caller_id, customer_id, 'GAME_LOG_NBR')
      child_id1 = xml_list_product_res.xpath('//product-list/child').attr('id').text
      product_num1 = xml_list_product_res.xpath('//product').count
    end

    it "Verify 'registerProducts' calls successfully" do
      expect(child_id1).to eq(child_id)
    end

it 'Verify Check for existence of [product]' do
      expect(product_num1).to eq(1)
    end
  end

  context 'TC02.002 - listRegisteredProducts  - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = ProductRegistration.list_registered_products(caller_id2, customer_id, 'GAME_LOG_NBR')
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC02.003 - listRegisteredProducts  - Invalid CustomerID' do
    customer_id3 = 'invalid'

    before :all do
      res = ProductRegistration.list_registered_products(caller_id, customer_id3, 'GAME_LOG_NBR')
    end

    it "Verify 'Fault occurred while processing.' error responses" do
      expect(res).to eq('Fault occurred while processing.')
    end
  end

  context 'TC02.004 - listRegisteredProducts  - Customer id is null' do
    customer_id4 = ''

    before :all do
      res = ProductRegistration.list_registered_products(caller_id, customer_id4, 'GAME_LOG_NBR')
    end

    it "Verify 'Fault occurred while processing.' error responses" do
      expect(res).to eq('Fault occurred while processing.')
    end
  end

  context 'TC02.005 - listRegisteredProducts  - Customer id is special charaters' do
    customer_id5 = '@@$@#$@$'

    before :all do
      res = ProductRegistration.list_registered_products(caller_id, customer_id5, 'GAME_LOG_NBR')
    end

    it "Verify 'Fault occurred while processing.' error responses" do
      expect(res).to eq('Fault occurred while processing.')
    end
  end

  context 'TC02.006 - listRegisteredProducts  - Customer id is negative numbers' do
    customer_id6 = '-2031918'

    before :all do
      res = ProductRegistration.list_registered_products(caller_id, customer_id6, 'GAME_LOG_NBR')
    end

    it 'Report bug' do
      expect("#36387: Web Services: product-registration: listRegisteredProduct: The service resturn successful response with empty content when requesting the service with a customer-id that doesn't exist or negative number").to eq(res)
    end
  end

  context 'TC02.007 - listRegisteredProducts  - Non-exist customer id' do
    customer_id7 = '11111111'

    before :all do
      res = ProductRegistration.list_registered_products(caller_id, customer_id7, 'GAME_LOG_NBR')
    end

    it 'Report bug' do
      expect("#36387: Web Services: product-registration: listRegisteredProduct: The service returns successful response with empty content when requesting the service with a customer-id that doesn't exist or negative number").to eq(res)
    end
  end
end
