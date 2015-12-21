require File.expand_path('../../../spec_helper', __FILE__)
require 'package_management'
require 'license_management'

=begin
Verify removeInstallation service works correctly
=end

describe "TS10 - removeInstallation - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  session = nil
  device_serial = DeviceManagement.generate_serial
  package_id = 'MULT-0x001F0114-000000'
  res = nil
  slot = 0

  it 'Precondition - claim device and install package' do
    username = email = LFCommon.generate_email
    screen_name = CustomerManagement.generate_screenname
    password = '123456'
    platform = 'leappad'
    profile_name = 'profile'
    res = nil

    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = acquire_session_res.xpath('//session').text

    xml_register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = xml_register_child_res.xpath('//child').attr('id').text

    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, platform, slot, profile_name, child_id)

    grant_license_res = LicenseManagement.grant_license caller_id, session, customer_id, device_serial, package_id
    LicenseManagement.install_package caller_id, device_serial, slot, package_id

    license_id = grant_license_res.xpath('//license/@id').text
    PackageManagement.report_installation caller_id, session, device_serial, slot, package_id, license_id
  end

  context 'TC10.001 - removeInstallation - Successful Response' do
    count_rm = nil

    before :all do
      PackageManagement.remove_installation(caller_id, session, device_serial, slot, package_id)
      (1..3).each do
        sleep 1
        device_inventory_res = PackageManagement.device_inventory(caller_id, 'service', device_serial, 'Application')
        count_rm = PackageManagement.check_remove_installation(device_inventory_res, package_id, 'removed')
        break if count_rm != 0
      end
    end

    it "Verify 'removeInstallation' calls successfully" do
      expect(count_rm).to eq(1)
    end
  end

  context 'TC10.002 - removeInstallation - Invalid CallerId' do
    caller_id2 = 'invalid'

    before :all do
      res = PackageManagement.remove_installation(caller_id2, session, device_serial, slot, package_id)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC10.003 - removeInstallation - Invalid Request' do
    package_id3 = ''

    before :all do
      res = PackageManagement.remove_installation(caller_id, session, device_serial, slot, package_id3)
    end

    it "Verify 'InvalidRequestFault' error message responses" do
      expect(res).to eq('InvalidRequestFault')
    end
  end

  context 'TC10.004 - removeInstallation - Access Denied' do
    session4 = 'invalid'

    before :all do
      res = PackageManagement.remove_installation(caller_id, session4, device_serial, slot, package_id)
    end

    it "Verify 'InvalidRequestFault' error message responses" do
      expect(res).to eq('InvalidRequestFault')
    end
  end

  context 'TC10.005 - removeInstallation - Inexistent PackageId' do
    package_id5 = 'PAD5-0x001E000C-111111'

    before :all do
      res = PackageManagement.remove_installation(caller_id, session, device_serial, slot, package_id5)
    end

    it "Verify 'InvalidRequestFault' error message responses" do
      expect(res).to eq('InvalidRequestFault')
    end
  end
end
