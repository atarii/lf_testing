require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify updateProfiles service works correctly
=end

describe "TS07 - updateProfiles - #{Misc::CONST_ENV}" do
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
  session = child_id = nil
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

  context 'TC07.001 - updateProfiles - Successful Response' do
    profile_name1 = slot1 = nil
    profile_name2 = slot2 = nil

    before :all do
      # fetchDevice before updating profile
      xml_fetch_device_res1 = DeviceManagement.fetch_device(caller_id, device_serial, platform)
      profile_name1 = xml_fetch_device_res1.xpath('//device/profile').attr('name').text
      slot1 = xml_fetch_device_res1.xpath('//device/profile').attr('slot').text

      DeviceManagement.update_profiles(caller_id, session, 'service', device_serial, platform, 2, 'updateprofile', child_id)

      # fetchDevice after updating profile
      xml_fetch_device_res2 = DeviceManagement.fetch_device(caller_id, device_serial, platform)
      profile_name2 = xml_fetch_device_res2.xpath('//device/profile').attr('name').text
      slot2 = xml_fetch_device_res2.xpath('//device/profile').attr('slot').text
    end

    it "Check profile_name before calling 'updateProfiles'" do
      expect(profile_name1).to eq('profile')
    end

    it "Check slot before calling 'updateProfiles'" do
      expect(slot1).to eq('1')
    end

    it "Check profile_name is updated after calling 'updateProfiles'" do
      expect(profile_name2).to eq('updateprofile')
    end

    it "Check slot is updated after calling 'updateProfiles'" do
      expect(slot2).to eq('2')
    end
  end

  context 'TC07.002 - updateProfiles - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = DeviceManagement.update_profiles(caller_id2, session, 'service', device_serial, platform, 2, 'updateprofile', child_id)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC07.003 - updateProfiles - Invalid Request' do
    device_serial3 = ''

    before :all do
      res = DeviceManagement.update_profiles(caller_id, session, 'service', device_serial3, platform, 2, 'updateprofile', child_id)
    end

    it "Verify 'ServiceException' error responses" do
      expect(res).to eq('ServiceException')
    end
  end

  context 'TC07.004 - updateProfiles - Access Denied' do
    session4 = 'invalid'

    before :all do
      res = DeviceManagement.update_profiles(caller_id, session4, 'service', device_serial, platform, 2, 'updateprofile', child_id)
    end

    it 'Verify SOAPFault responses' do
      expect('#36240: Web Services: device-management: updateProfiles: The service call does not validate the input data of @session').to eq(res)
    end
  end

  context 'TC07.005 - updateProfiles - Unclaimed Device' do
    before :all do
      OwnerManagement.unclaim_device(caller_id, session, 'service', device_serial)
      res = DeviceManagement.update_profiles(caller_id, session, 'service', device_serial, platform, 2, 'updateprofile', child_id)
    end

    it 'Verify SOAPFault responses' do
      expect('#36310: Web Services: device-management: updateProfiles: The service return a successful response when updating profiles with unclaimed device').to eq(res)
    end
  end

  context "TC07.006 - updateProfiles - Parentpin's value is characters" do
    parent_pin = 'abcd'

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :update_profiles,
        "<caller-id>#{caller_id}</caller-id>
          <session type='service'>#{session}</session>
          <device serial='#{device_serial}' platform='#{platform}' auto-create='true' pin=''>
            <properties>
              <property key='deviceparentpin' value='#{parent_pin}'/>
            </properties>
          </device>"
      )
    end

    it 'Verify SOAPFault responses' do
      expect('#36314: Web Services: device-management: updateProfiles: The service does accept any data of Parent PIN when calling updateProfiles service for Leappad Ultra').to eq(res)
    end
  end

  context "TC07.007 - updateProfiles - Parentpin's value more than 4 digital" do
    parent_pin = '123456'

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :update_profiles,
        "<caller-id>#{caller_id}</caller-id>
          <session type='service'>#{session}</session>
          <device serial='#{device_serial}' platform='#{platform}' auto-create='true' pin=''>
            <properties>
              <property key='deviceparentpin' value='#{parent_pin}'/>
            </properties>
          </device>"
      )
    end

    it 'Verify SOAPFault responses' do
      expect('#36314: Web Services: device-management: updateProfiles: The service does accept any data of Parent PIN when calling updateProfiles service for Leappad Ultra').to eq(res)
    end
  end

  context "TC07.008 - updateProfiles - Parentpin's value is empty" do
    parent_pin = ''

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :update_profiles,
        "<caller-id>#{caller_id}</caller-id>
          <session type='service'>#{session}</session>
          <device serial='#{device_serial}' platform='#{platform}' auto-create='true' pin=''>
            <properties>
              <property key='deviceparentpin' value='#{parent_pin}'/>
            </properties>
          </device>"
      )
    end

    it 'Verify SOAPFault responses' do
      expect('#36314: Web Services: device-management: updateProfiles: The service does accept any data of Parent PIN when calling updateProfiles service for Leappad Ultra').to eq(res)
    end
  end

  context "TC07.009 - updateProfiles - Parentpin's value less than 4 digital" do
    parent_pin = '123'

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :update_profiles,
        "<caller-id>#{caller_id}</caller-id>
          <session type='service'>#{session}</session>
          <device serial='#{device_serial}' platform='#{platform}' auto-create='true' pin=''>
            <properties>
              <property key='deviceparentpin' value='#{parent_pin}'/>
            </properties>
          </device>"
      )
    end

    it 'Verify SOAPFault responses' do
      expect('#36314: Web Services: device-management: updateProfiles: The service does accept any data of Parent PIN when calling updateProfiles service for Leappad Ultra').to eq(res)
    end
  end
end
