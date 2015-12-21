require File.expand_path('../../../spec_helper', __FILE__)
require 'license_management'
require 'package_management'
require 'customer_management'
require 'authentication'
require 'child_management'
require 'owner_management'
require 'device_management'
require 'device_profile_management'

=begin
Verify Digital Right Management (DRM) works correctly
=end

describe "TS08 - Digital Right Management - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  package_id = '50038-97914'
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  customer_id = nil
  session = nil
  license_num = nil
  res = nil

  # Generate device serial number
  device_serial1 = 'LPAD1' + DeviceManagement.generate_serial
  device_serial2 = 'LPAD2' + DeviceManagement.generate_serial
  device_serial3 = 'LPAD3' + DeviceManagement.generate_serial
  device_serial4 = 'LPAD4' + DeviceManagement.generate_serial
  device_serial5 = 'LPAD5' + DeviceManagement.generate_serial
  device_serial6 = 'LPAD6' + DeviceManagement.generate_serial

  # Pre-condition - Claim account to 6 device
  before :all do
    reg_cus_response = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    customer_id = cus_info[:id]

    session = Authentication.get_service_session(caller_id, username, password)

    register_child_res1 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id1 = register_child_res1.xpath('//child/@id').text

    register_child_res2 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id2 = register_child_res2.xpath('//child/@id').text

    register_child_res3 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id3 = register_child_res3.xpath('//child/@id').text

    register_child_res4 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id4 = register_child_res4.xpath('//child/@id').text

    register_child_res5 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id5 = register_child_res5.xpath('//child/@id').text

    register_child_res6 = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, customer_id)
    child_id6 = register_child_res6.xpath('//child/@id').text

    # 4. claim 6 devices to account
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial1, 'leappad', '0', 'profile1', child_id1)
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial2, 'leappad', '0', 'profile2', child_id2)
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial3, 'leappad', '0', 'profile3', child_id3)
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial4, 'leappad', '0', 'profile4', child_id4)
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial5, 'leappad', '0', 'profile5', child_id5)
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial6, 'leappad', '0', 'profile6', child_id6)

    # 5. assign device profile
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial1, 'leappad', '0', 'profile1', child_id1)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial2, 'leappad', '0', 'profile2', child_id2)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial3, 'leappad', '0', 'profile3', child_id3)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial4, 'leappad', '0', 'profile4', child_id4)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial5, 'leappad', '0', 'profile5', child_id5)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial6, 'leappad', '0', 'profile6', child_id6)
  end

  context 'TC08.001 - DRM = 5' do
    check_install_pkg, check_install_pkg1, check_install_pkg2, check_install_pkg3, check_install_pkg4, check_install_pkg5, check_install_pkg6 = nil

    before :all do
      grant_license_res = LicenseManagement.grant_license(caller_id, session, customer_id, device_serial1, package_id)
      license_id = grant_license_res.xpath('//license').attr('id').text

      # 7. installPackage for 5 devices
      LicenseManagement.install_package(caller_id, device_serial1, '0', package_id)
      LicenseManagement.install_package(caller_id, device_serial2, '0', package_id)
      LicenseManagement.install_package(caller_id, device_serial3, '0', package_id)
      LicenseManagement.install_package(caller_id, device_serial4, '0', package_id)
      LicenseManagement.install_package(caller_id, device_serial5, '0', package_id)

      # 8. Sync app to 5 devices
      PackageManagement.report_installation(caller_id, session, device_serial1, '0', package_id, license_id)
      PackageManagement.report_installation(caller_id, session, device_serial2, '0', package_id, license_id)
      PackageManagement.report_installation(caller_id, session, device_serial3, '0', package_id, license_id)
      PackageManagement.report_installation(caller_id, session, device_serial4, '0', package_id, license_id)
      PackageManagement.report_installation(caller_id, session, device_serial5, '0', package_id, license_id)

      # 9. installPackage to 6th device
      res = LicenseManagement.install_package(caller_id, device_serial6, '0', package_id)
      PackageManagement.report_installation(caller_id, session, device_serial6, '0', package_id, license_id)

      # 10. fetch deviceInventory and check install package
      device_inventory_res1 = PackageManagement.device_inventory(caller_id, 'application', device_serial1, 'Application')
      check_install_pkg1 = LicenseManagement.check_install_package(device_inventory_res1, package_id, 'installed')

      device_inventory_res2 = PackageManagement.device_inventory(caller_id, 'application', device_serial2, 'Application')
      check_install_pkg2 = LicenseManagement.check_install_package(device_inventory_res2, package_id, 'installed')

      device_inventory_res3 = PackageManagement.device_inventory(caller_id, 'application', device_serial3, 'Application')
      check_install_pkg3 = LicenseManagement.check_install_package(device_inventory_res3, package_id, 'installed')

      device_inventory_res4 = PackageManagement.device_inventory(caller_id, 'application', device_serial4, 'Application')
      check_install_pkg4 = LicenseManagement.check_install_package(device_inventory_res4, package_id, 'installed')

      device_inventory_res5 = PackageManagement.device_inventory(caller_id, 'application', device_serial5, 'Application')
      check_install_pkg5 = LicenseManagement.check_install_package(device_inventory_res5, package_id, 'installed')

      device_inventory_res6 = PackageManagement.device_inventory(caller_id, 'application', device_serial6, 'Application')
      check_install_pkg6 = LicenseManagement.check_install_package(device_inventory_res6, package_id, 'installed')

      # 11. fetchRestrictedLicenses
      fetch_restricted_res = LicenseManagement.fetch_restricted_licenses(caller_id, 'service', session, customer_id, '')
      license_num = fetch_restricted_res.xpath('//licenses/@count').to_s

      # 12. Remove package on 2nd device
      PackageManagement.remove_installation(caller_id, session, device_serial2, 0, package_id)

      # 13. Install package on 6th device
      PackageManagement.report_installation(caller_id, session, device_serial6, '0', package_id, license_id)
      device_inventory_res = PackageManagement.device_inventory(caller_id, 'application', device_serial6, 'Application')
      check_install_pkg = LicenseManagement.check_install_package(device_inventory_res, package_id, 'installed')
    end

    it 'Verify package is installed successfully on 1st device' do
      expect(check_install_pkg1).to eq(1)
    end

    it 'Verify package is installed successfully on 2nd device' do
      expect(check_install_pkg2).to eq(1)
    end

    it 'Verify package is installed successfully on 3rd device ' do
      expect(check_install_pkg3).to eq(1)
    end

    it 'Verify package is installed successfully on 4th device' do
      expect(check_install_pkg4).to eq(1)
    end

    it 'Verify package is installed successfully on 5th device' do
      expect(check_install_pkg5).to eq(1)
    end

    it "Verify 'Insufficient License' error message response when install package to 6th device" do
      expect(res).to eq('An internal error occurred: com.leapfrog.inmon.domain.lfp.InsufficientLicensesException: Insufficient License')
    end

    it 'Verify package is not installed on 6th device' do
      expect(check_install_pkg6).to eq(2)
    end

    it "Verify 'fetchRestrictedLicenses' returns 5" do
      expect(license_num).to eq('5')
    end

    it 'Verify package in installed on 6th device after removing it on another device' do
      expect(check_install_pkg).to eq(1)
    end
  end

  # Post-condition: deleteInstallation
  after :all do
    PackageManagement.delete_installation(caller_id, session, device_serial1, package_id, 'Jewel Train 2 Game App (virtual)', 'Application')
    PackageManagement.delete_installation(caller_id, session, device_serial3, package_id, 'Jewel Train 2 Game App (virtual)', 'Application')
    PackageManagement.delete_installation(caller_id, session, device_serial4, package_id, 'Jewel Train 2 Game App (virtual)', 'Application')
    PackageManagement.delete_installation(caller_id, session, device_serial5, package_id, 'Jewel Train 2 Game App (virtual)', 'Application')
    PackageManagement.delete_installation(caller_id, session, device_serial6, package_id, 'Jewel Train 2 Game App (virtual)', 'Application')
  end
end
