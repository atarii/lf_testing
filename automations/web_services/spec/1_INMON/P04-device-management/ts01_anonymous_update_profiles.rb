require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify anonymousUpdateProfiles service works correctly
=end

describe "TS01 - anonymousUpdateProfiles - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:namespace]
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  device_serial = DeviceManagement.generate_serial
  platform = 'leappad'
  slot = '1'
  profile_name = 'profile'
  child_id = nil
  res = nil

  it 'Precondition - claim device' do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = acquire_session_res.xpath('//session').text

    xml_register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = xml_register_child_res.xpath('//child').attr('id').text

    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, platform, slot, profile_name, child_id)
  end

  context 'TC01.001 - anonymousUpdateProfiles - Successful Response' do
    slot_res = nil

    before :all do
      DeviceManagement.anonymous_update_profiles(caller_id, device_serial, platform, '2', profile_name, child_id)
      xml_fetch_device_res = DeviceManagement.fetch_device(caller_id, device_serial, platform)

      slot_res = xml_fetch_device_res.xpath('//device/profile').attr('slot').text
    end

    it 'Check Slot responses: ' do
      expect(slot_res).to eq('2')
    end
  end

  context 'TC01.002 - anonymousUpdateProfiles - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = DeviceManagement.anonymous_update_profiles(caller_id2, device_serial, platform, slot, profile_name, child_id)
    end

    it "Verify 'Error while checking caller id' error message responses: " do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - anonymousUpdateProfiles - Invalid Request' do
    before :all do
      res = DeviceManagement.anonymous_update_profiles(caller_id, '', '', slot, profile_name, child_id)
    end

    it "Verify 'InvalidRequestFault' error message responses: " do
      expect(res).to eq('InvalidRequestFault')
    end
  end

  context 'TC01.004 - anonymousUpdateProfiles - Invalid Slot' do
    slot4 = '123abc'

    before :all do
      res = DeviceManagement.anonymous_update_profiles(caller_id, device_serial, platform, slot4, profile_name, child_id)
    end

    it "Verify 'Unmarshalling Error: Not a number: 1c' error message responses: " do
      expect(res).to eq('Unmarshalling Error: Not a number: ' + slot4 + ' ')
    end
  end

  context 'TC01.005 - anonymousUpdateProfiles - Invalid Weak-ID' do
    weak_id5 = '111111111111111111111111111111111111111111111111'

    res = LFCommon.soap_call(
      endpoint,
      namespace,
      :anonymous_update_profiles,
      "<caller-id>#{caller_id}</caller-id>
        <device serial='#{device_serial}' product-id='0' platform='#{platform}' auto-create='false' pin='1111'>
          <profile slot='#{slot}' name='#{profile_name}' child-id='#{child_id}' auto-create='false' points='0' rewards='0' weak-id='#{weak_id5}' uploadable='false' claimed='true' dob='2013-11-20+07:00' grade='1' gender='female'/>
        </device>"
    )

    it 'Unmarshalling ErrorReport should be returned ' do
      expect(res).to eq('Unmarshalling Error: Not a number: 123abc ')
    end
  end
end
