require File.expand_path('../../../spec_helper', __FILE__)
require 'owner_management'
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_profile_management'
require 'device_management'

=begin
Verify unClaimDevice service works correctly
=end

describe "TS01- unClaim Device - #{Misc::CONST_ENV}" do
  session = nil
  unclaim_res = nil
  dev_serial = nil
  cus_info = nil
  platform = nil
  activated_by = nil
  res_serial1 = nil

  before :all do
    # Register customer
    reg_cus_response =  CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)

    # Acquire service session
    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
  end

  context 'TC01.001 - unclaim device - Successful Response' do

    dev_serial = DeviceManagement.generate_serial

    it "Claim device #{dev_serial}" do
      claim_res = OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_info[:id], dev_serial, 'leappad3', '0', 'Child01', '44444', Time.now, '1')
      platform = claim_res.xpath('//claimed-device/@platform').text
      activated_by = claim_res.xpath('//claimed-device/@activated-by').text

      # listNominatedDevices and get device serials value
      xml_list_nominated_devices_res = DeviceManagement.list_nominated_devices(Misc::CONST_CALLER_ID, session, 'service')
      res_serial1 = xml_list_nominated_devices_res.xpath('//device[1]').attr('serial').text
    end

    it 'Verify device is claimed' do
      expect(platform).to eq('leappad3')
      expect(activated_by).to eq(cus_info[:id])
      expect(res_serial1).to eq(dev_serial)
    end

    it "Unclaim device #{dev_serial}" do
      OwnerManagement.unclaim_device(Misc::CONST_CALLER_ID, session, 'service', dev_serial)
    end

    it 'Verify device is unclaimed successfully' do
      dev_res = DeviceManagement.fetch_device(Misc::CONST_CALLER_ID, dev_serial, 'leappad3')
      expect(dev_res.xpath('//device/@activated-by').text).to eq('0')
    end
  end

  context 'TC01.002 - unclaim device - Invalid CallerID' do
    before :all do
      unclaim_res = OwnerManagement.unclaim_device('invalid', session, 'service', dev_serial)
    end

    it "Check error message 'Error while checking caller id'" do
      expect(unclaim_res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - unclaim device - Invalid session' do
    before :all do
      unclaim_res = OwnerManagement.unclaim_device(Misc::CONST_CALLER_ID, 'invalid', 'service', dev_serial)
    end

    it 'Check error message: AccessDeniedFault: invalid_session' do
      expect(unclaim_res).to eq('AccessDeniedFault invalid session')
    end
  end

  context 'TC01.004 - unclaim device - invalid device serial' do
    before :all do
      unclaim_res = OwnerManagement.unclaim_device(Misc::CONST_CALLER_ID, session, 'service', '-123456')
    end

    it 'Check error message: Operation unClaim failed!' do
      expect(unclaim_res).to eq('Operation unClaim failed!')
    end
  end

  context 'TC01.005 - unclaim device - claim device that is unclaimed' do
    before :all do
      unclaim_res = OwnerManagement.unclaim_device(Misc::CONST_CALLER_ID, session, 'service', dev_serial)
    end

    it "Check error message: DeviceNeverClaimedException serial=#{dev_serial}" do
      expect(unclaim_res.strip).to eq("DeviceNeverClaimedException serial=#{dev_serial}")
    end
  end
end
