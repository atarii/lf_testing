require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'owner_management'
require 'device_management'
require 'device_profile_management'

=begin
Verify listPlatforms service works correctly
=end

describe "TS11 - listPlatforms - #{Misc::CONST_ENV}" do
  session = nil
  cus_id = nil
  child_id = nil
  device_serial = DeviceManagement.generate_serial

  before :all do
    reg_cus_response =  CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    cus_id = cus_info[:id]

    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
    reg_chi_response = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_id)

    child_id = reg_chi_response.xpath('//child/@id').text
  end

  context 'TC11.001 - listPlatforms - Successful Response' do
    platform = 'leappad'
    platform_act = nil

    before :all do
      profile, slot = 'profile', '0'

      OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_id, device_serial, platform, slot, profile, child_id)
      DeviceManagement.update_profiles(Misc::CONST_CALLER_ID, session, 'service', device_serial, platform, slot, profile, child_id)
      DeviceProfileManagement.assign_device_profile(Misc::CONST_CALLER_ID, cus_id, device_serial, platform, slot, profile, child_id)

      lis_pla_res = ChildManagement.list_platforms(Misc::CONST_CALLER_ID, session, child_id)
      platform_act = lis_pla_res.xpath('//platforms').text
    end

    it 'Verify platform returns correctly' do
      expect(platform_act).to eq(platform)
    end
  end

  context 'TC11.002 - listPlatforms - Invalid CallerID' do
    res = nil

    before :all do
      res = ChildManagement.list_platforms('invalid', session, child_id)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC11.003 - listPlatforms - Invalid Request' do
    res = nil

    before :all do
      res = ChildManagement.list_platforms(Misc::CONST_CALLER_ID, session, 'invalid')
    end

    it 'Verify faultstring is returned: there is no parent/child relationship between the customer and child' do
      expect(res).to eq('there is no parent/child relationship between the customer and child')
    end
  end

  context 'TC11.004 - listPlatforms - Access Denied' do
    res = nil

    before :all do
      res = ChildManagement.list_platforms(Misc::CONST_CALLER_ID, 'invalid', child_id)
    end

    it 'Verify faultstring is returned: Session is invalid: invalid' do
      expect(res).to eq('Session is invalid: invalid')
    end
  end

  context 'TC11.005 - listPlatforms - Nonexistent Child' do
    res = nil

    before :all do
      res = ChildManagement.list_platforms(Misc::CONST_CALLER_ID, session, 2_756_110)
    end

    it 'Verify faultstring is returned: there is no parent/child relationship between the customer and child' do
      expect(res).to eq('there is no parent/child relationship between the customer and child')
    end
  end
end
