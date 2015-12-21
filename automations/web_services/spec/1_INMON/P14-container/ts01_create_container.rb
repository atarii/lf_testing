require File.expand_path('../../../spec_helper', __FILE__)
require 'authentication'
require 'child_management'
require 'customer_management'
require 'device_management'
require 'owner_management'
require 'container_management'

=begin
Verify createContainer service works correctly
=end

describe "TS01 - createContainer - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = DeviceManagement.generate_serial
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  customer_id = nil
  res = nil

  it 'Precondition 1 - register customer' do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = xml_register_child_res.xpath('//child').attr('id').text

    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, 'leappad3', '0', 'Child01', child_id)
  end

  context 'TC01.001 - createContainer - successful Response' do
    container_id = nil

    before :all do
      xml_res = ContainerManagement.create_container(caller_id, customer_id)
      container_id = xml_res.xpath('//container').attr('id').text
    end

    it "Verify 'createContainer' calls successfully" do
      expect(container_id).not_to be_empty
    end
  end

  context 'TC01.002 - createContainer - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = ContainerManagement.create_container(caller_id2, customer_id)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - createContainer - Invalid CustomerID' do
    customer_id3 = 'invalid_customer_ID'

    before :all do
      res = ContainerManagement.create_container(caller_id, customer_id3)
    end

    it 'Report bug' do
      expect('#36346: Web Services: container-management: createContainer: The services call return successful responses with valid container-id value when calling service with invalid @customer-id ').to eq(res)
    end
  end
end
