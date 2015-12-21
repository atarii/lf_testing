require File.expand_path('../../spec_helper', __FILE__)
require 'activation_code_management'
require 'restfulcalls'
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Glasgow: Verify lookup_device_by_activation_code service works correctly
=end

describe "GLASGOW - Lookup Device By Activation Code - #{Misc::CONST_ENV}" do
  caller_id = 'ededd6a8-587c-470f-a74d-5d1a9697719b'
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  device_serial = DeviceManagement.generate_serial
  platform = 'leappad'
  slot = '1'
  profile_name = 'profile'
  activation_code = nil
  res_lookup = nil

  context 'Precondition - Register account, register child and get activation code' do
    customer_id = nil
    child_id = nil
    session = nil

    it "Register customer (URL: #{LFWSDL::CONST_CUSTOMER_MGT})" do
      register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
      arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
      customer_id = arr_register_cus_res[:id]
    end

    it "Authentication account (URL: #{LFWSDL::CONST_AUTHENTICATION})" do
      xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
      session = xml_acquire_session_res.xpath('//session').text
    end

    it "Register child (URL: #{LFWSDL::CONST_CHILD_MGT})" do
      xml_register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
      child_id = xml_register_child_res.xpath('//child').attr('id').text
    end

    it "Claim device (URL: #{LFWSDL::CONST_OWNER_MGT})" do
      OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id)
    end

    it "Assign device profiles (URL: #{LFWSDL::CONST_DEVICE_PROFILE_MGT})" do
      DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, platform, slot, profile_name, child_id)
    end

    it "Get activation code (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % device_serial})" do
      res_fetch = fetch_device_activation_code(caller_id, device_serial)
      activation_code = res_fetch['data']['activationCode']
    end
  end

  context 'TC870: Successful res_lookup' do
    lookup_device_serial = fetch_device_serial = lookup_device_id = fetch_dev_id = nil
    lookup_dev_service_code = fetch_dev_service_code = lookup_parent_email = fetch_parent_token = nil
    lookup_dev_owner_id = fetch_dev_owner_id = lookup_parent_token = fetch_parent_email = nil

    it "Lookup device by activation code (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % activation_code})" do
      # lookupDeviceByActivationCode with an existing activation code
      pending "*** Lookup device by activation code (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % activation_code}"
      res_lookup = lookup_device_by_activation_code(caller_id, activation_code)
      lookup_device_serial = res_lookup['data']['devSerial']
      lookup_device_id = res_lookup['data']['devId']
      lookup_dev_service_code = res_lookup['data']['devServiceCode']
      lookup_parent_email = res_lookup['data']['parentemail']
      lookup_parent_token = res_lookup['data']['parenttoken']
      lookup_dev_owner_id = res_lookup['data']['devOwnerId']
    end

    it "Fetch device info (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_FETCH_DEVICE % lookup_device_serial})" do
      # fetchDevice by on lookup_device_serial
      pending "*** Fetch device info (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_FETCH_DEVICE % lookup_device_serial}"
      res_fetch = fetch_device(caller_id, lookup_device_serial)
      fetch_device_serial = res_fetch['data']['devSerial']
      fetch_dev_id = res_fetch['data']['devId']
      fetch_dev_service_code = res_fetch['data']['devServiceCode']
      fetch_parent_email = res_fetch['data']['parentemail']
      fetch_parent_token = res_fetch['data']['parenttoken']
      fetch_dev_owner_id = res_fetch['data']['devOwnerId']
    end

    it "Verify 'lookupDeviceByActivationCode' rest calls successfully" do
      expect(res_lookup['status']).to eq(true)
    end

    it 'Verify Session Token returns correctly' do
      expect(res_lookup['token']).not_to be_empty
    end

    it 'Verify Device Serial returns correctly' do
      expect(lookup_device_serial).to eq(fetch_device_serial)
    end

    it 'Verify Device ID returns correctly' do
      expect(lookup_device_id).to eq(fetch_dev_id)
    end

    it 'Verify Device Service Code returns correctly' do
      expect(lookup_dev_service_code).to eq(fetch_dev_service_code)
    end

    it 'Verify Parent Email returns correctly' do
      expect(lookup_parent_email).to eq(fetch_parent_email)
    end

    it 'Verify Parent Token returns correctly' do
      expect(lookup_parent_token).to eq(fetch_parent_token)
    end

    it 'Verify Device Owner ID returns correctly' do
      expect(lookup_dev_owner_id).to eq(fetch_dev_owner_id)
    end
  end

  context 'TC871: invalid caller-id' do
    invalid_caller_id = 'invalid'

    it "Lookup device by activation code (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % activation_code})" do
      pending "*** Lookup device by activation code (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % activation_code}"
      res_lookup = lookup_device_by_activation_code(invalid_caller_id, activation_code)
    end

    it "Verify 'lookupDeviceByActivationCode' rest call status is 'false'" do
      expect(res_lookup['status']).to eq(false)
    end

    it "Verify 'Error while checking caller id' error message res_lookups" do
      expect(res_lookup['data']['message']).to eq('Error while checking caller id')
    end
  end

  context 'TC872: Caller-id is empty' do
    empty_caller_id = ''

    it "Lookup device by activation code (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % activation_code})" do
      pending "*** Lookup device by activation code (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % activation_code}"
      res_lookup = lookup_device_by_activation_code(empty_caller_id, activation_code)
    end

    it "Verify 'lookupDeviceByActivationCode' rest call status is 'false'" do
      expect(res_lookup['status']).to eq(false)
    end

    it "Verify 'Error while checking caller id' error message res_lookups" do
      expect(res_lookup['data']['message']).to eq('Error while checking caller id')
    end
  end

  context 'TC874: act-code has expired' do
    expired_act_code = GLASGOW::CONST_EXPIRED_ACT_CODE

    it "Lookup device by activation code (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % expired_act_code})" do
      pending "*** Lookup device by activation code (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % expired_act_code}"
      res_lookup = lookup_device_by_activation_code(caller_id, expired_act_code)
    end

    it "Verify 'lookupDeviceByActivationCode' rest call status is 'false'" do
      expect(res_lookup['status']).to eq(false)
    end

    it "Verify '#{expired_act_code} has expired.' error message res_lookups" do
      expect(res_lookup['data']['message']).to eq("#{expired_act_code} has expired.")
    end
  end
end
