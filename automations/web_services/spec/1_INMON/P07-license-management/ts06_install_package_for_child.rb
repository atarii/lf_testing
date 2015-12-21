require File.expand_path('../../../spec_helper', __FILE__)
require 'license_management'
require 'package_management'

=begin
Verify installPackageForChild service works correctly
=end

describe "TS06 - installPackageForChild - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  session = '491309d5-c2cd-4deb-aa9d-ea426372006e'
  cust_key = '2766864'
  device_serial = '3A1521000101FF001032'
  child_id = '2766866'
  package_id = '50038-97914'
  href = 'http://qa-digitalcontent.leapfrog.com/packages/MULT/MULT-0x001B001A-000000.lf3'
  res = nil

  context 'TC06.001 - installPackageForChild - Successful Response' do
    package_id = 'MHRS-0x001B001A-000000'
    check_install_package = nil

    before :all do
      LicenseManagement.grant_license(caller_id, session, cust_key, device_serial, package_id)
      LicenseManagement.install_package_for_child(caller_id, session, child_id, package_id, href)
      device_inventory_res = PackageManagement.device_inventory(caller_id, 'application', device_serial, 'Application')
      check_install_package = LicenseManagement.check_install_package(device_inventory_res, package_id, 'pending')
    end

    it 'Verify installPackageForChild call successfully' do
      expect(check_install_package).to eq(1)
    end
  end

  context 'TC06.002 - installPackageForChild - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = LicenseManagement.install_package_for_child(caller_id2, session, child_id, package_id, href)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC06.003 - installPackageForChild - Invalid Request' do
    package_id3 = '123'

    before :all do
      res = LicenseManagement.install_package_for_child(caller_id, session, child_id, package_id3, href)
    end

    it "Verify 'Unable to handle the request: No meta data found for package id...' error responses" do
      expect(res).to eq('Unable to handle the request: No meta data found for package id [123]')
    end
  end
end
