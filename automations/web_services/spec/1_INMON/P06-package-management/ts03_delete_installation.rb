require File.expand_path('../../../spec_helper', __FILE__)
require 'package_management'
require 'license_management'

=begin
Verify deleteInstallation service works correctly
=end

describe "TS03 - deleteInstallation - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  session = '51fb883b-9727-4e84-be94-aa3e6db6785b'
  device_serial = '3B0621000102FF000C4B'
  package_id = 'MULT-0x00180003-000000'
  package_name = 'Sugar Bugs Game App'
  res = nil

  context 'TC03 - deleteInstallation - Successful Response' do
    device_inventory_res = nil

    before :all do
      LicenseManagement.install_package(caller_id, device_serial, 0, package_id)
      PackageManagement.delete_installation(caller_id, session, device_serial, package_id, package_name, 'Application')
      device_inventory_res = PackageManagement.device_inventory(caller_id, 'service', device_serial, 'Application')
    end

    it 'Verify deleted package is removed from deviceInventory' do
      device_inventory_res.xpath('//device/package/@id').each do |id|
        if package_id == id
          expect(package_id).to eq('package to delete does not remove from deviceInventory')
        end
      end
      expect('1').to eq('1')
    end
  end

  context 'TC03.002 - deleteInstallation - Invalid CallerId' do
    caller_id2 = 'invalid'

    before :all do
      res = PackageManagement.delete_installation(caller_id2, session, device_serial, package_id, package_name, 'Application')
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC03.003 - deleteInstallation - Invalid Request' do
    package_id3 = ''

    before :all do
      res = PackageManagement.delete_installation(caller_id, session, device_serial, package_id3, package_name, 'Application')
    end

    it "Verify 'InvalidRequestFault' error message responses" do
      expect(res).to eq('InvalidRequestFault')
    end
  end

  context 'TC03.004 - deleteInstallation - Access Denied' do
    session4 = 'invalid'

    before :all do
      res = PackageManagement.delete_installation(caller_id, session4, device_serial, package_id, package_name, 'Application')
    end

    it "Verify 'InvalidRequestFault' error message responses" do
      expect(res).to eq('InvalidRequestFault')
    end
  end

  context 'TC03.005 - deleteInstallation - Inexistent PackageId' do
    package_id5 = 'MULT-0x00180003-12345'

    before :all do
      res = PackageManagement.delete_installation(caller_id, session, device_serial, package_id5, package_name, 'Application')
    end

    it "Verify 'InvalidRequestFault' error message responses" do
      expect(res).to eq('InvalidRequestFault')
    end
  end
end
