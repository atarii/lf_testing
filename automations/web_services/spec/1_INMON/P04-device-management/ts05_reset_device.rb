require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify resetDevice service works correctly
=end

describe "TS05 - resetDevice - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  device_serial = DeviceManagement.generate_serial
  platform = 'leappad'
  slot = '1'
  profile_name = 'profile'
  release_licenses = 'true'
  session = nil
  res = nil

  it 'Precondition - claim device' do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = xml_register_child_res.xpath('//child').attr('id').text

    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, platform, slot, profile_name, child_id)
  end

  context 'TC05.001 - resetDevice - Susscessful Response' do
    list_before = list_after = nil

    before :all do
      # listNominatedDevices before resetDevice
      xml_list_nominated_devices_res1 = DeviceManagement.list_nominated_devices(caller_id, session, 'service')
      list_before = xml_list_nominated_devices_res1.xpath('//device').count

      # resetDevice
      DeviceManagement.reset_device(caller_id, session, device_serial, release_licenses)

      # listNominatedDevices after resetDevice
      xml_list_nominated_devices_res2 = DeviceManagement.list_nominated_devices(caller_id, session, 'service')
      list_after = xml_list_nominated_devices_res2.xpath('//device').count
    end

    it 'Verify device is claimed before resetting device' do
      expect(list_before).to eq(1)
    end

    it 'Verify device is unclaimed after resetting device' do
      expect(list_after).to eq(0)
    end
  end

  context 'TC05.002 - resetDevice - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = DeviceManagement.reset_device(caller_id2, session, device_serial, release_licenses)
    end

    it "Verify 'Error while checking caller id' error message responses: " do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC05.004 - resetDevice - Access Denied (invalid session)' do
    session4 = 'aaa123'

    before :all do
      res = DeviceManagement.reset_device(caller_id, session4, device_serial, release_licenses)
    end

    it "Verify 'AccessDeniedFault invalid session' error message responses: " do
      if (res == 'Fault occurred while processing.')
        expect('#37024: Web Services: Reset device: Message "Fault occurred while processing" instead of "AccessDeniedFault invalid session" displays when entering an invalid session').to eq('AccessDeniedFault invalid session')
      else
        expect(res).to eq('AccessDeniedFault invalid session')
      end
    end
  end
end
