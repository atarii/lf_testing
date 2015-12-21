require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify assignDeviceProfile service works correctly
=end

describe "TS01 - assignDeviceProfile - #{Misc::CONST_ENV}" do
  owner_management_endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:endpoint]
  owner_management_namespace = LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:namespace]
  caller_id = Misc::CONST_CALLER_ID
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

    xml_register_child_res1 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id1 = xml_register_child_res1.xpath('//child').attr('id').text

    xml_register_child_res2 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id2 = xml_register_child_res2.xpath('//child').attr('id').text

    LFCommon.soap_call(
      owner_management_endpoint,
      owner_management_namespace,
      :claim_device,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device serial='#{device_serial}' auto-create='false' product-id='0' platform='emerald' pin='1111'>
        <profile slot='0' name='profile2' points='0' rewards='0' weak-id='1' uploadable='true' claimed='false' dob='2006-10-31+07:00' grade='3' gender='male' child-id='#{child_id1}' auto-create='false'/>
        <profile slot='1' name='profile1' weak-id='1' uploadable='true' claimed='true' child-id='#{child_id2}' dob='2013-10-08+07:00' grade='5' gender='male' auto-create='false' points='0' rewards='0'/>
      </device>"
    )
  end

  context 'TS01 - assignDeviceProfile' do
    device_profile_count = nil

    before :all do
      DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, 'emerald', '0', 'profile1', child_id1)

      xml_response = DeviceProfileManagement.list_device_profiles(caller_id, username, customer_id, '10', '10', '0')
      device_profile_count = xml_response.xpath('//device-profile').count
    end

    it 'Check count of [device-profile]' do
      expect(device_profile_count).to eq(2)
    end
  end

  context 'TS01.003 - assignDeviceProfile - AccessDeniedFaultResponse' do
    before :all do
      res = LFCommon.soap_call(
        owner_management_endpoint,
        owner_management_namespace,
        :claim_device,
        "<caller-id>#{caller_id}</caller-id>
        <username/>
        <customer-id>#{customer_id}</customer-id>
        <device-profile device='#{device_serial}' platform='emerald' slot='0' name='profile1' child-id='#{child_id1}'/>
        <child-id>11111</child-id>"
      )
    end

    it "Verify 'AccessDeniedFault' error responses" do
      expect(res).to eq('AccessDeniedFault invalid session')
    end
  end

  context 'TS01.004 - assignDeviceProfile - InvalidRequestFaultResponse' do
    device_serial4 = 'invalid'

    before :all do
      res = DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial4, '', '1', 'profile1', child_id1)
    end

    it "Verify 'Unable to locate user for supplied slot: (invalid:1)' error responses" do
      expect(res).to eq('Unable to locate user for supplied slot: (invalid:1)')
    end
  end

  context 'TS01.005 - assignDeviceProfile - Invalid Slot Number' do
    slot5 = '10'

    before :all do
      res = DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, 'emerald', slot5, 'profile1', child_id1)
    end

    it "Verify 'Unable to locate user for supplied slot: (" + device_serial + ':' + slot5 + ")' error responses" do
      expect(res).to eq('Unable to locate user for supplied slot: (' + device_serial + ':' + slot5 + ')')
    end
  end

  context 'TS01.006 - assignDeviceProfile - single profile' do
    before :all do
      res = LFCommon.soap_call(
        owner_management_endpoint,
        owner_management_namespace,
        :claim_device,
        "<caller-id>#{caller_id}</caller-id>
        <username/>
        <customer-id>2777670</customer-id>
        <device-profile device='LPxyz123321xyz201311261519052' platform='leapreader' slot='1' name='profile1' child-id='1234'/>
        <child-id>1234</child-id>"
      )
    end

    it "Verify 'AccessDeniedFault' error responses" do
      expect(res).to eq('AccessDeniedFault invalid session')
    end
  end
end
