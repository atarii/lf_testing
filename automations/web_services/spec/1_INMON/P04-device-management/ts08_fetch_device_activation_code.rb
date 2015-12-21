require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify fetchDeviceActivationCode service works correctly
=end

describe "TS08 - fetchDeviceActivationCode - #{Misc::CONST_ENV}" do
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  device_serial = DeviceManagement.generate_serial
  platform = 'leappad'
  slot = '1'
  profile_name = 'profile'


  it 'Pre-Condition: claim device' do
    register_cus_res = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(Misc::CONST_CALLER_ID, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, customer_id)
    child_id = xml_register_child_res.xpath('//child/@id').text

    OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, customer_id, device_serial, platform, slot, profile_name, child_id)
    DeviceProfileManagement.assign_device_profile(Misc::CONST_CALLER_ID, customer_id, device_serial, platform, slot, profile_name, child_id)
  end

  context 'TC08.001 - fetchDeviceActivationCode - Successful response' do
    res = nil

    before :all do
      res = DeviceManagement.fetch_device_activation_code(Misc::CONST_CALLER_ID, device_serial)
    end

    it 'Verify activation code is returned and has 6 characters' do
      expect(res.xpath('//activation-code').text.length).to eq(6)
    end
  end

  context 'TC08.002 - fetchDeviceActivationCode - Invalid caller-id' do
    res = nil

    before :all do
      res = DeviceManagement.fetch_device_activation_code('invalid', device_serial)
    end

    it 'Verify error message is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC08.003 - fetchDeviceActivationCode - UnnominatedDeviceFault' do
    res = nil

    before :all do
      res = DeviceManagement.fetch_device_activation_code(Misc::CONST_CALLER_ID, 'nonexistence_dev')
    end

    it 'Verify error message is returned: ...' do
      expect('Bug #35124: Web services: SOAP/REST: Response error messages are not clearly when calling fetchDeviceActivationCode and lookupDeviceByActivationCode services').to eq(res)
    end
  end
end
