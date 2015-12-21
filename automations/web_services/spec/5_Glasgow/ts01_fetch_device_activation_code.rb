require File.expand_path('../../spec_helper', __FILE__)
require 'activation_code_management'
require 'device_management'

=begin
Glasgow: Verify fetch_device_activation_code service works correctly
=end

describe "GLASGOW - Fetch Device Activation Code - #{Misc::CONST_ENV}" do
  caller_id = 'ededd6a8-587c-470f-a74d-5d1a9697719b'
  device_serial = DeviceManagement.generate_serial
  platform = 'leapup'
  response = nil

  context "Pre-Condition - Register device (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
    DeviceManagement.register_device Misc::CONST_CALLER_ID, device_serial, platform
  end

  context "TC850: Successful Response (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % device_serial}) " do
    before :all do
      response = fetch_device_activation_code(caller_id, device_serial)
    end

    it "Verify 'fetchDeviceActivationCode' rest calls successfully" do
      expect(response['status']).to eq(true)
    end

    it "Verify returned 'activationCode' is valid" do
      activation_code = response['data']['activationCode']
      expect(activation_code.length).to eq(6)
    end
  end

  context "TC851: invalid caller-id (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % device_serial})" do
    invalid_caller_id = 'invalid'

    before :all do
      response = fetch_device_activation_code(invalid_caller_id, device_serial)
    end

    it "Verify 'fetchDeviceActivationCode' rest call status is 'false'" do
      expect(response['status']).to eq(false)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(response['data']['message']).to eq('Error while checking caller id')
    end
  end

  context "TC852: Caller-id is empty (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % device_serial})" do
    empty_caller_id = ''

    before :all do
      response = fetch_device_activation_code(empty_caller_id, device_serial)
    end

    it "Verify 'fetchDeviceActivationCode' rest call status is 'false'" do
      expect(response['status']).to eq(false)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(response['data']['message']).to eq('Error while checking caller id')
    end
  end

  context "TC853: unnominate device (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_DEVICES_ACTIVATION % device_serial})" do
    unnominate_device_serial = '12334invalid'

    before :all do
      response = fetch_device_activation_code(caller_id, unnominate_device_serial)
    end

    it "Verify 'fetchDeviceActivationCode' rest call status is 'false'" do
      expect(response['status']).to eq(false)
    end

    it "Verify '#{unnominate_device_serial}' error message responses" do
      expect(response['data']['message']).to eq(unnominate_device_serial)
    end
  end
end
