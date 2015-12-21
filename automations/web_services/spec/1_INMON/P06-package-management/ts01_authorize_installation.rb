require File.expand_path('../../../spec_helper', __FILE__)
require 'package_management'

=begin
Verify authorizeInstallation service works correctly
=end

describe "TS01 - authorizeInstallation - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  session = '51fb883b-9727-4e84-be94-aa3e6db6785b'
  device_serial = '3B0621000102FF000C4B'
  package_id = 'MULT-0x001B001A-000000'
  package_name = 'Jewel Train 2 : Twisty Tracks'
  res = nil

  context 'TC01.001 - authorizeInstallation - Successful Response' do
    license_type = nil

    before :all do
      xml_res = PackageManagement.authorize_installation(caller_id, session, device_serial, package_id, package_name)
      license_type = xml_res.xpath('//license').attr('type').text
    end

    it 'Check authorizeInstallation call successfully' do
      expect(license_type).to eq('PURC')
    end
  end

  context 'TC01.002 - authorizeInstallation - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = PackageManagement.authorize_installation(caller_id2, session, device_serial, package_id, package_name)
    end

    it "Verify 'InvalidCallerIdFault' error message responses" do
      expect(res).to eq('InvalidCallerIdFault')
    end
  end

  context 'TC01.003 - authorizeInstallation - Invalid Request' do
    session3 = package_id3 = package_name3 = ''

    before :all do
      res = PackageManagement.authorize_installation(caller_id, session3, device_serial, package_id3, package_name3)
    end

    it "Verify 'InvalidRequestFault' error message responses" do
      expect(res).to eq('InvalidRequestFault')
    end
  end
end
