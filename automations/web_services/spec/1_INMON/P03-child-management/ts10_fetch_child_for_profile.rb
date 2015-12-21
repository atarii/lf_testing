require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'owner_management'
require 'device_management'
require 'device_profile_management'

=begin
Verify fetchChildForProfile service works correctly
=end

describe "TS10 - fetchChildForProfile - #{Misc::CONST_ENV}" do
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

  context 'TC10.001 - fetchChildForProfile - Successful Response' do
    child_id_act = nil

    before :all do
      profile = 'profile'
      slot = '0'
      platform = 'leappad'

      OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_id, device_serial, platform, slot, profile, child_id)
      DeviceManagement.update_profiles(Misc::CONST_CALLER_ID, session, 'service', device_serial, platform, slot, profile, child_id)
      DeviceProfileManagement.assign_device_profile(Misc::CONST_CALLER_ID, cus_id, device_serial, platform, slot, profile, child_id)

      fet_chi_for_prl_rest = ChildManagement.fetch_child_for_profile(Misc::CONST_CALLER_ID, session, device_serial, slot)
      child_id_act = fet_chi_for_prl_rest.xpath('//child/@id').text
    end

    it 'Verify registed child is returned' do
      expect(child_id_act).to eq(child_id)
    end
  end

  context 'TC10.002 - fetchChildForProfile - Invalid CallerID' do
    res = nil

    before :all do
      res = ChildManagement.fetch_child_for_profile('invalid', session, device_serial, 0)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC10.003 - fetchChildForProfile - Invalid Request' do
    res = nil

    before :all do
      res = ChildManagement.fetch_child_for_profile(Misc::CONST_CALLER_ID, session, '', 0)
    end

    it 'Verify faultstring is returned: Unable to complete fetchChildForProfile for device "" and slot "0"' do
      expect(res).to eq('Unable to complete fetchChildForProfile for device "" and slot "0"')
    end
  end

  context 'TC10.004 - fetchChildForProfile - Access Denied' do
    res = nil

    before :all do
      res = ChildManagement.fetch_child_for_profile(Misc::CONST_CALLER_ID, 'invalid', device_serial, 0)
    end

    it 'Verify faultstring is returned: Session is invalid: invalid' do
      expect(res).to eq('Session is invalid: invalid')
    end
  end
end
