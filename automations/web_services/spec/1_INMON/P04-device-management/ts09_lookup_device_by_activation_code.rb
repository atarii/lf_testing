require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify lookupDeviceByActivationCode service works correctly
=end

describe "TS09 - lookupDeviceByActivationCode - #{Misc::CONST_ENV}" do
  username = email = LFCommon.generate_email
  device_serial = DeviceManagement.generate_serial
  session = nil
  customer_id = nil
  act_code = nil
  res = nil

  it 'Pre-condition' do
    register_cus_res = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(Misc::CONST_CALLER_ID, username, '123456')
    session = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, customer_id)
    child_id = xml_register_child_res.xpath('//child/@id').text

    OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, customer_id, device_serial, 'leappad', '1', 'profile', child_id)

    DeviceProfileManagement.assign_device_profile(Misc::CONST_CALLER_ID, customer_id, device_serial, 'leappad', '1', 'profile', child_id)

    fet_dev_act_code_res = DeviceManagement.fetch_device_activation_code(Misc::CONST_CALLER_ID, device_serial)
    act_code = fet_dev_act_code_res.xpath('//activation-code').text
  end

  context 'TC09.001 - lookupDeviceByActivationCode - Successful response' do
    before :all do
      res = DeviceManagement.lookup_device_by_activation_code(Misc::CONST_CALLER_ID, session, act_code)
    end

    it 'Verify device information: serial number' do
      expect(res.xpath('//device/@serial').text).to eq(device_serial)
    end

    it 'Verify device information: activated by' do
      expect(res.xpath('//device/@activated-by').text).to eq(customer_id)
    end
  end

  context 'TC09.002 - lookupDeviceByActivationCode - Invalid caller-id' do
    before :all do
      res = DeviceManagement.lookup_device_by_activation_code('invalid', session, act_code)
    end

    it 'Verify error message is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC09.003 - lookupDeviceByActivationCode - AccessDenied - Invalid session' do
    before :all do
      res = DeviceManagement.lookup_device_by_activation_code(Misc::CONST_CALLER_ID, 'invalid', act_code)
    end

    it 'Verify error message responses' do
      expect(res).to eq('Bug #35124: Web services: SOAP/REST: Response error messages are not clearly when calling fetchDeviceActivationCode and lookupDeviceByActivationCode services')
    end
  end

  context 'TC09.004 - lookupDeviceByActivationCode - AccessDenied - session of another parent' do
    before :all do
      res = DeviceManagement.lookup_device_by_activation_code(Misc::CONST_CALLER_ID, '2c757c5e-2dce-479b-a6f4-cafa93af7fb9', act_code)
    end

    it 'Verify error message responses' do
      expect(res).to eq('Bug #35124: Web services: SOAP/REST: Response error messages are not clearly when calling fetchDeviceActivationCode and lookupDeviceByActivationCode services')
    end
  end

  context 'TC09.005 - lookupDeviceByActivationCode - nonexistent act-code' do
    before :all do
      res = DeviceManagement.lookup_device_by_activation_code(Misc::CONST_CALLER_ID, session, '1YE4UD1')
    end

    it 'Verify error message is returned: No device associated with activation code: 1YE4UD1' do
      expect(res).to eq('No device associated with activation code: 1YE4UD1')
    end
  end

  context 'TC09.006 - lookupDeviceByActivationCode - activation code has expired' do
    before :all do
      res = DeviceManagement.lookup_device_by_activation_code(Misc::CONST_CALLER_ID, session, 'BYE4UD')
    end

    it 'Verify error message responses' do
      expect(res).to eq('Bug #35124: Web services: SOAP/REST: Response error messages are not clearly when calling fetchDeviceActivationCode and lookupDeviceByActivationCode services')
    end
  end
end
