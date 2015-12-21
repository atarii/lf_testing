require File.expand_path('../../../spec_helper', __FILE__)
require 'license_management'
require 'package_management'

=begin
Verify installPackage service works correctly
=end

describe "TS05 - installPackage - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  session = '491309d5-c2cd-4deb-aa9d-ea426372006e'
  cust_key = '2766864'
  device_serial = '3A1521000101FF001032'
  package_id = '50038-97914'
  res = nil

  context 'TC05.001 - installPackage - Successful Response' do
    check_install_package = nil

    before :all do
      # grantLicense
      LicenseManagement.grant_license(caller_id, session, cust_key, device_serial, package_id)

      # installPackage
      LicenseManagement.install_package(caller_id, device_serial, '0', package_id)

      # deviceInventory
      device_inventory_res = PackageManagement.device_inventory(caller_id, 'application', device_serial, 'Application')
      check_install_package = LicenseManagement.check_install_package(device_inventory_res, package_id, 'pending')
    end

    it 'Verify installPackage call successfully' do
      expect(check_install_package).to eq(1)
    end

    after :all do
      PackageManagement.delete_installation(caller_id, session, device_serial, package_id, 'Jewel Train 2 Game App (virtual)', 'Application')
    end
  end

  context 'TC05.002 - installPackage - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = LicenseManagement.install_package(caller_id2, device_serial, '0', package_id)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC05.003 - installPackage - Invalid Request' do
    package_id3 = '12345'

    before :all do
      res = LicenseManagement.install_package(caller_id, device_serial, '0', package_id3)
    end

    it "Verify 'Unable to handle the request: No meta data found for package id [1]' error message responses" do
      expect(res).to eq('Unable to handle the request: No meta data found for package id [12345]')
    end
  end
end
