require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'product_registration'

=begin
Verify deregisterProducts service works correctly
=end

describe "TS03 - deregisterProducts - #{Misc::CONST_ENV}" do
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

  context 'TC03.001 - deresgiterProduct - Successful Response' do
    product_num1 = product_num2 = nil

    before :all do
      ProductRegistration.register_products(caller_id, customer_id, type, child_id, game_log_nbr)

      xml_list_product_res1 = ProductRegistration.list_registered_products(caller_id, customer_id, 'GAME_LOG_NBR')
      product_num1 = xml_list_product_res1.xpath('//product').count

      ProductRegistration.deregister_products(caller_id, customer_id, child_id, game_log_nbr)

      xml_list_product_res2 = ProductRegistration.list_registered_products(caller_id, customer_id, 'GAME_LOG_NBR')
      product_num2 = xml_list_product_res2.xpath('//product').count
    end

    it "Check for existence of [product] before calling 'deregisterProduct'" do
      expect(product_num1).to eq(1)
    end

    it "Check for existence of [product] after calling 'deregisterProduct'" do
      expect(product_num2).to eq(0)
    end
  end

  context 'TC03.002 - deresgiterProduct - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = ProductRegistration.deregister_products(caller_id2, customer_id, child_id, game_log_nbr)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC03.003 - deresgiterProduct - Invalid CustomerID' do
    customer_id3 = 'invalid'

    before :all do
      res = ProductRegistration.deregister_products(caller_id, customer_id3, child_id, game_log_nbr)
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided.' error responses" do
      expect(res).to eq('Unable to execute the requested call, an invalid or empty argument was provided.')
    end
  end

  context 'TC03.004 - deresgiterProduct - product de-registered - Successful Response' do
    product_num = nil

    before :all do
      ProductRegistration.register_products(caller_id, customer_id, type, child_id, game_log_nbr)
      ProductRegistration.deregister_products(caller_id, customer_id, child_id, game_log_nbr)
      ProductRegistration.deregister_products(caller_id, customer_id, child_id, game_log_nbr)
      xml_list_product_res = ProductRegistration.list_registered_products(caller_id, customer_id, 'GAME_LOG_NBR')
      product_num = xml_list_product_res.xpath('//product').count

    end

    it 'Check for existence of [product]' do
      expect(product_num).to eq(0)
    end
  end

  context 'TC03.005 - deresgiterProduct - product does not deregister' do
    before :all do
      res = ProductRegistration.deregister_products(caller_id, customer_id, child_id, '1572871')
    end

    it "Verify 'unable to complete request' error responses" do
      expect(res).to eq('unable to complete request')
    end
  end

  context 'TC03.006 - deresgiterProduct - inconsistent cus and child' do
    child_id6 = '11111'

    before :all do
      res = ProductRegistration.deregister_products(caller_id, customer_id, child_id6, game_log_nbr)
    end

    it "Verify 'Unable to register product[s] since the childid ... is not a child of customerid...' error responses" do
      expect(res).to eq('Unable to register product[s] since the childid ' + child_id6 + ' is not a child of customerid ' + customer_id)
    end
  end
end
