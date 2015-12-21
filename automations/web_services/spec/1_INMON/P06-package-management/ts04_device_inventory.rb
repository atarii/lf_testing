require File.expand_path('../../../spec_helper', __FILE__)
require 'package_management'

=begin
Verify deviceInventory service works correctly
=end

describe "TS04 - deviceInventory - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '3B0621000102FF000C4B'
  res = nil

  context 'TC04.001 - deviceInventory - Successful Response' do
    package_num = nil

    before :all do
      xml_res = PackageManagement.device_inventory(caller_id, 'service', device_serial, 'Application')
      package_num = xml_res.xpath('//device/package').count
    end

    it "Check 'deviceInventory' call successfully with no SOAp Fault" do
      expect(package_num).not_to eq(0)
    end
  end

  context 'TC04.002 - deviceInventory - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = PackageManagement.device_inventory(caller_id2, 'service', device_serial, 'Application')
    end

    it "Verify 'Supplied caller id is not well formed' error message responses" do
      expect(res).to eq('Supplied caller id is not well formed')
    end
  end

  context 'TC04.003 - deviceInventory - Invalid Request' do
    before :all do
      res = PackageManagement.device_inventory(caller_id, 'service', '', '')
    end

    it "Verify 'InvalidRequestFault' error message responses" do
      expect(res).to eq('InvalidRequestFault')
    end
  end
end
