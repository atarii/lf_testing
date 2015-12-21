require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify fetchDevice service works correctly
=end

describe "TS02 - fetchDevice - #{Misc::CONST_ENV}" do
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
  res = nil

  it 'Precondition - claim device' do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = acquire_session_res.xpath('//session').text

    register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = register_child_res.xpath('//child').attr('id').text

    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, platform, slot, profile_name, child_id)
  end

  context 'TC02.001 - fetchDevice - Successful Response' do
    xml_fetch_device_res = nil

    before :all do
      xml_fetch_device_res = DeviceManagement.fetch_device(caller_id, device_serial, platform)
    end

    it 'Check Device serial responses: ' do
      expect(xml_fetch_device_res.xpath('//device').attr('serial').text).to eq(device_serial)
    end
  end

  context 'TC02.002 - fetchDevice - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = DeviceManagement.fetch_device(caller_id2, device_serial, platform)
    end

    it "Verify 'Error while checking caller id' error message responses: " do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC02.003 - fetchDevice - Invalid Request' do
    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :fetch_device,
        "<caller-id>#{caller_id}</caller-id>
        <device serial='' product-id='' platform='' auto-create='' pin=''>
          <properties>
          </properties>
        </device>"
      )
    end

    it "Verify 'Unmarshalling Error: String index out of range: 0' error message responses: " do
      expect(res).to eq('Unmarshalling Error: String index out of range: 0 ')
    end
  end
end
