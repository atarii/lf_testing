require File.expand_path('../../../spec_helper', __FILE__)
require 'package_management'

=begin
Verify cartBuddies service works correctly
=end

describe "TS02 - cartBuddies - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '3B0621000102FF000C4B'
  package_id = 'GAMS-0x001B0056-000000'
  res = nil

  context 'TC02.001 - cartBuddies - Successful Response' do
    soap_fault = nil

    before :all do
      # cartBuddies - Successful Response
      xml_res = PackageManagement.cart_buddies(caller_id, device_serial, package_id)
      soap_fault = xml_res.xpath('//faultcode').count
    end

    it "Check 'cartBuddies' call successfully with no SOAp Fault" do
      expect(soap_fault).to eq(0)
    end
  end

  context 'TC02.002 - cartBuddies - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = PackageManagement.cart_buddies(caller_id2, device_serial, package_id)
    end

    it "Verify 'Supplied caller id is not well formed' error message responses" do
      expect(res).to eq('Supplied caller id is not well formed')
    end
  end

  context 'TC02.003 - cartBuddies - Invalid Request' do
    device_serial3 = package_id3 = ''

    before :all do
      res = PackageManagement.cart_buddies(caller_id, device_serial3, package_id3)
    end

    it "Verify 'device serial is missing' error message responses" do
      expect(res).to eq('device serial is missing')
    end
  end
end
