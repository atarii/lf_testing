require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'product_registration'

=begin
Verify registerProducts service works correctly
=end

describe "TS01 - registerProducts - #{Misc::CONST_ENV}" do
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

  context 'TC01.001 -  - Successful Request' do
    child_id1 = nil

    before :all do
      ProductRegistration.register_products(caller_id, customer_id, type, child_id, game_log_nbr)

      xml_list_product_res = ProductRegistration.list_registered_products(caller_id, customer_id, 'GAME_LOG_NBR')
      child_id1 = xml_list_product_res.xpath('//product-list/child').attr('id').text
    end

    it "Verify 'registerProducts' calls successfully" do
      expect(child_id1).to eq(child_id)
    end
  end

  context 'TC01.002 - registerProducts - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = ProductRegistration.register_products(caller_id2, customer_id, type, child_id, game_log_nbr)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - registerProducts - Invalid CustomerID' do
    customer_id3 = 'invalid'

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id3, type, child_id, game_log_nbr)
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided.' error responses" do
      expect(res).to eq('Unable to execute the requested call, an invalid or empty argument was provided.')
    end
  end

  context 'TC01.004 - registerProducts - Customer id is null' do
    customer_id4 = ''

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id4, type, child_id, game_log_nbr)
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided.' error responses" do
      expect(res).to eq('Unable to execute the requested call, an invalid or empty argument was provided.')
    end
  end

  context 'TC01.005 - registerProducts - Customer id is so long' do
    customer_id5 = 'One down, we keep going We released SoapUI 4.6.1 a few weeks ago (thank you SoapUI team!). You can read all about it at the bottom of this page. And as soon as 4.6.1 was out we started working on 4.6.2, which will be released a few weeks from now.'

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id5, type, child_id, game_log_nbr)
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided.' error responses" do
      expect(res).to eq('Unable to execute the requested call, an invalid or empty argument was provided.')
    end
  end

  context 'TC01.006 - registerProducts - Customer id is special characters' do
    customer_id6 = '#@#@$@$'

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id6, type, child_id, game_log_nbr)
    end

    it "Verify 'Unable to execute the requested call, an invalid or empty argument was provided.' error responses" do
      expect(res).to eq('Unable to execute the requested call, an invalid or empty argument was provided.')
    end
  end

  context 'TC01.007 - registerProducts - Customer id is negative numbers' do
    customer_id7 = '-21345646498'

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id7, type, child_id, game_log_nbr)
    end

    it "Verify 'Unable to register product[s] since the childid ... is not a child of customerid ...' error responses" do
      expect(res).to eq('Unable to register product[s] since the childid ' + child_id + ' is not a child of customerid 129189982')
    end
  end

  context 'TC01.008 - registerProducts - Child id is null' do
    child_id8 = ''

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id, type, child_id8, game_log_nbr)
    end

    it "Verify 'Unable to register product[s] since the childid 0 is not a child of customerid...' error responses" do
      expect(res).to eq('Unable to register product[s] since the childid 0 is not a child of customerid ' + customer_id)
    end
  end

  context 'TC01.009 - registerProducts - Child id is so long' do
    child_id9 = 'One down, we keep going We released SoapUI 4.6.1 a few weeks ago (thank you SoapUI team!). You can read all about it at the bottom of this page. And as soon as 4.6.1 was out we started working on 4.6.2, which will be released a few weeks from now.'

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id, type, child_id9, game_log_nbr)
    end

    it "Verify 'Unmarshalling Error: Not a number:...' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: ' + child_id9 + ' ')
    end
  end

  context 'TC01.010 - registerProducts - Child id is special characters' do
    child_id10 = '@#@#@#@'

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id, type, child_id10, game_log_nbr)
    end

    it "Verify 'Unmarshalling Error: Not a number:...' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: ' + child_id10 + ' ')
    end
  end

  context 'TC01.011 - registerProducts - Child id is negative numbers' do
    child_id11 = '-1136546798'

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id, type, child_id11, game_log_nbr)
    end

    it "Verify 'Unable to register product[s] since the childid ... is not a child of customerid ...' error responses" do
      expect(res).to eq('Unable to register product[s] since the childid ' + child_id11 + ' is not a child of customerid ' + customer_id)
    end
  end

  context 'TC01.012 - registerProducts - produc-registration-type is null' do
    type12 = ''

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id, type12, child_id, game_log_nbr)
    end

    it "Verify 'The service call returned with fault: null' error responses" do
      expect(res).to eq('The service call returned with fault: null')
    end
  end

  context 'TC01.013 - registerProducts - game_log_nbr is null' do
    game_log_nbr13 = ''

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id, type, child_id, game_log_nbr13)
    end

    it "Verify 'unable to complete request' error responses" do
      expect(res).to eq('unable to complete request')
    end
  end

  context 'TC01.014 - registerProducts - game_log_nbr is negative numbers' do
    game_log_nbr14 = '-2031918'

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id, type, child_id, game_log_nbr14)
    end

    it "Verify 'unable to complete request' error responses" do
      expect(res).to eq('unable to complete request')
    end
  end

  context 'TC01.015 - registerProducts - game_log_nbr is special charaters' do
    game_log_nbr15 = '@#$%%'

    before :all do
      res = ProductRegistration.register_products(caller_id, customer_id, type, child_id, game_log_nbr15)
    end

    it "Verify 'unable to complete request' error responses" do
      expect(res).to eq('unable to complete request')
    end
  end
end
