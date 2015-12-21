require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify listChildDeviceProfiles service works correctly
=end

describe "TS03 - listChildDeviceProfiles - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  device_serial = DeviceManagement.generate_serial
  customer_id = child_id1 = nil
  res = nil

  it 'Precondition - claim device' do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    # registerChild 1st
    xml_register_child_res1 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id1 = xml_register_child_res1.xpath('//child').attr('id').text

    # registerChild 2nd
    xml_register_child_res2 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id2 = xml_register_child_res2.xpath('//child').attr('id').text

    LFCommon.soap_call(
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:endpoint],
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:namespace],
      :claim_device,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device serial='#{device_serial}' auto-create='false' product-id='0' platform='emerald' pin='1111'>
        <profile slot='0' name='profile3' points='0' rewards='0' weak-id='1' uploadable='true' claimed='false' dob='2006-10-31+07:00' grade='3' gender='male' child-id='#{child_id1}' auto-create='false'/>
        <profile slot='1' name='profile4' weak-id='1' uploadable='true' claimed='true' child-id='#{child_id2}' dob='2013-10-08+07:00' grade='5' gender='male' auto-create='false' points='0' rewards='0'/>
      </device>"
    )

    LFCommon.soap_call(
      LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_management][:endpoint],
      LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_management][:namespace],
      :assign_device_profiles,
      "<device-profile device='#{device_serial}' platform='emerald' slot='0' name='profile1' child-id='#{child_id1}'/>
      <device-profile slot='1' device='#{device_serial}' platform='emerald' name='profile2' child-id='#{child_id2}'/>
      <caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id>#{customer_id}</customer-id>"
    )
  end

  context 'TC03.001 - listChildDeviceProfiles - SuccessfulResponse' do
    child_id = nil

    before :all do
      xml_res = DeviceProfileManagement.list_child_device_profiles(caller_id, username, customer_id, child_id1)

      child_id = xml_res.xpath('//device-profile').attr('child-id').text
    end

    it "Verify 'listChildDeviceProfiles' calls successfully" do
      expect(child_id).to eq(child_id1)
    end
  end

  context 'TC03.001 - listChildDeviceProfiles - InvalidRequestFaultResponse' do
    before :all do
      res = DeviceProfileManagement.list_child_device_profiles(caller_id, '', '', '')
    end

    it "Verify 'child id must be a positive number' calls successfully" do
      expect(res).to eq('child id must be a positive number')
    end
  end
end
