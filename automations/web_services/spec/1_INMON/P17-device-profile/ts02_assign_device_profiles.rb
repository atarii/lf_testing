require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify assignDeviceProfiles service works correctly
=end

describe "TS02 - assignDeviceProfiles - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_management][:namespace]
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  device_serial = DeviceManagement.generate_serial
  customer_id = child_id1 = child_id2 = nil
  res = nil

  it 'Precondition - claim device' do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res1 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id1 = xml_register_child_res1.xpath('//child').attr('id').text

    xml_register_child_res2 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id2 = xml_register_child_res2.xpath('//child').attr('id').text

    LFCommon.soap_call(
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:endpoint],
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:namespace],
      :claim_device,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device serial='#{device_serial}' auto-create='false' product-id='0' platform='emerald' pin='1111'>
        <profile slot='0' name='profile1' points='0' rewards='0' weak-id='1' uploadable='true' claimed='false' dob='2006-10-31+07:00' grade='3' gender='male' child-id='#{child_id1}' auto-create='false'/>
        <profile slot='1' name='profile2' weak-id='1' uploadable='true' claimed='true' child-id='#{child_id2}' dob='2013-10-08+07:00' grade='5' gender='male' auto-create='false' points='0' rewards='0'/>
      </device>"
    )
  end

  context 'TS02.001 - assignDeviceProfiles - SuccessfulResponse' do
    device_profile_count = nil
    child_id_res1 = child_id_res2 = nil

    before :all do
      LFCommon.soap_call(
        endpoint,
        namespace,
        :assign_device_profiles,
        "<device-profile device='#{device_serial}' platform='emerald' slot='0' name='profile1' child-id='#{child_id1}'/>
        <device-profile slot='1' device='#{device_serial}' platform='emerald' name='profile2' child-id='#{child_id2}'/>
        <caller-id>#{caller_id}</caller-id>
        <username/>
        <customer-id>#{customer_id}</customer-id>"
      )
      xml_response = DeviceProfileManagement.list_device_profiles(caller_id, username, customer_id, '10', '10', '0')
      device_profile_count = xml_response.xpath('//device-profile').count
      child_id_res1 = xml_response.xpath('//device-profile[2]').attr('child-id').text
      child_id_res2 = xml_response.xpath('//device-profile[1]').attr('child-id').text
    end

    it 'Check count of [device-profile]' do
      expect(device_profile_count).to eq(2)
    end

    it 'Match content of [@child-id1]' do
      expect(child_id_res1).to eq(child_id1)
    end

    it 'Check count of [device-profile]' do
      expect(child_id_res2).to eq(child_id2)
    end
  end

  context 'TS02.002 - assignDeviceProfiles - InvalidCallerIdFaultResponse' do
    caller_id2 = 'invalid'

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :assign_device_profiles,
        "<device-profile device='#{device_serial}' platform='emerald' slot='0' name='profile1' child-id='#{child_id1}'/>
        <device-profile slot='1' device='#{device_serial}' platform='emerald' name='profile2' child-id='#{child_id2}'/>
        <caller-id>#{caller_id2}</caller-id>
        <username/>
        <customer-id>#{customer_id}</customer-id>"
      )
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TS02.003 - assignDeviceProfiles - AccessDeniedFaultResponse' do
    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :assign_device_profiles,
        "<device-profile device='#{device_serial}' platform='emerald' slot='0' name='profile1' child-id='11111'/>
        <device-profile slot='1' device='#{device_serial}' platform='emerald' name='profile2' child-id='22222'/>
        <caller-id>#{caller_id}</caller-id>
        <username/>
        <customer-id>#{customer_id}</customer-id>"
      )
    end

    it "Verify 'Unable to locate supplied child in data store' error responses" do
      expect(res).to eq('Unable to locate supplied child in data store')
    end
  end

  context 'TS02.004 - assignDeviceProfiles - InvalidRequestFaultResponse' do
    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :assign_device_profiles,
        "<device-profile device='' platform='emerald' slot='0' name='profile1' child-id='#{child_id1}'/>
        <device-profile slot='1' device='' platform='emerald' name='profile2' child-id='#{child_id2}'/>
        <caller-id>#{caller_id}</caller-id>
        <username/>
        <customer-id>#{customer_id}</customer-id>"
      )
    end

    it "Verify 'Unable to locate device for supplied serial:' error responses" do
      expect(res).to eq('Unable to locate device for supplied serial: ')
    end
  end

  context 'TS02.005 - assignDeviceProfiles - single profile' do
    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :assign_device_profiles,
        "<device-profile device='LPxyz123321xyz201311261519052' platform='leapreader' slot='0' name='profile3' child-id='12345'/>
        <device-profile slot='0' device='LPxyz123321xyz201311261519052' platform='leapreader' name='profile4' child-id='123455'/>
        <caller-id>#{caller_id}</caller-id>
        <username/>
        <customer-id>2777670</customer-id>"
      )
    end

    it "Verify 'Unable to locate supplied child in data store' error responses" do
      expect(res).to eq('Unable to locate supplied child in data store')
    end
  end
end
