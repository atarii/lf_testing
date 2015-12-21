require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify listNominatedDevices service works correctly
=end

describe "TS03 - listNominatedDevices - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  # Customer/device 1
  username1 = email1 = LFCommon.generate_email
  screen_name1 = CustomerManagement.generate_screenname
  device_serial1 = DeviceManagement.generate_serial

  # Customer/device 2
  username2 = email2 = LFCommon.generate_email
  screen_name2 = CustomerManagement.generate_screenname
  device_serial2 = DeviceManagement.generate_serial
  password = '123456'
  platform = 'leappad'
  slot = '1'
  profile_name = 'profile'
  session2 = nil
  res = nil

  it 'Precondition1 - register and claim device for 1st customer' do
    # Register customer 1 and get CustomerID
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name1, email1, username1)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id1 = arr_register_cus_res[:id]

    acquire_session_res = Authentication.acquire_service_session(caller_id, username1, password)
    session1 = acquire_session_res.xpath('//session').text

    register_child_res = ChildManagement.register_child(caller_id, session1, customer_id1)
    child_id1 = register_child_res.xpath('//child').attr('id').text

    OwnerManagement.claim_device(caller_id, session1, customer_id1, device_serial1, platform, slot, profile_name, child_id1)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id1, device_serial1, platform, slot, profile_name, child_id1)
  end

  it 'Precondition2 - register and claim device for 2st customer' do
    # Register customer 2 and get CustomerID
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name2, email2, username2)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id2 = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username2, password)
    session2 = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res = ChildManagement.register_child(caller_id, session2, customer_id2)
    child_id2 = xml_register_child_res.xpath('//child').attr('id').text

    OwnerManagement.claim_device(caller_id, session2, customer_id2, device_serial2, platform, slot, profile_name, child_id2)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id2, device_serial2, platform, slot, profile_name, child_id2)
  end

  it 'Precondition3 - nominate device of 1st_cust to 2nd_cust' do
    DeviceManagement.nominate_device(caller_id, session2, 'service', device_serial1, 'leappad')
  end

  context 'TC03.001 - listNominatedDevices - Successful Response' do
    res_serial1 = res_serial2 = nil

    before :all do
      # listNominatedDevices and get device serial value
      xml_res = DeviceManagement.list_nominated_devices(caller_id, session2, 'service')
      res_serial1 = xml_res.xpath('//device[1]').attr('serial').text
      res_serial2 = xml_res.xpath('//device[2]').attr('serial').text
    end

    it 'Verify device serial 1' do
      expect(res_serial1).to eq(device_serial1)
    end

    it 'Verify device serial 2' do
      expect(res_serial2).to eq(device_serial2)
    end
  end

  context 'TC03.002 - listNominatedDevices - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = DeviceManagement.list_nominated_devices(caller_id2, session2, 'service')
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC03.003 - listNominatedDevices - Invalid Request' do
    type3 = ''

    before :all do
      res = DeviceManagement.list_nominated_devices(caller_id, session2, type3)
    end

    it "Verify 'Fault occurred while processing.' error message responses" do
      expect(res).to eq('Fault occurred while processing.')
    end
  end

  context 'TC03.004 - listNominatedDevices - Access Denied' do
    session4 = 'invalid'

    before :all do
      res = DeviceManagement.list_nominated_devices(caller_id, session4, 'service')
    end

    it "Verify 'AccessDeniedFault' error message responses" do
      expect(res).to eq('AccessDeniedFault invalid session')
    end
  end
end
