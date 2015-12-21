require File.expand_path('../../../spec_helper', __FILE__)
require 'package_management'
require 'license_management'

=begin
Verify reportInstallation service works correctly
=end

describe "TS11 - reportInstallation - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  session = '51fb883b-9727-4e84-be94-aa3e6db6785b'
  device_serial = '3B0621000102FF000C4B'
  package_id = 'MULT-0x001B001A-000000'
  license_id = '520822'
  res = nil

  context 'TC11.001 - reportInstallation - Successful Response' do
    begin
      res = PackageManagement.report_installation(caller_id, session, device_serial, '-1', package_id, license_id)
    rescue Savon::SOAPFault
      it 'Fail: removeInstallation fails to call' do
        expect(1).to eq(0)
      end
    else
      it 'Verify no SOAP Fault returns' do
        expect(1).to eq(1)
      end
    end
  end

  context 'TC11.002 - reportInstallation - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = PackageManagement.report_installation(caller_id2, session, device_serial, '-1', package_id, license_id)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC11.003 - reportInstallation - Invalid Request' do
    package_id3 = ''

    before :all do
      res = PackageManagement.report_installation(caller_id, session, device_serial, '-1', package_id3, license_id)
    end

    it "Verify 'InvalidRequestFault' error message responses" do
      expect(res).to eq('InvalidRequestFault')
    end
  end

  context 'TC11.004 - reportInstallation - Access Denied' do
    session4 = ''

    before :all do
      res = PackageManagement.report_installation(caller_id, session4, device_serial, '-1', package_id, license_id)
    end

    it "Verify 'InvalidRequestFault' error message responses" do
      expect(res).to eq('InvalidRequestFault')
    end
  end
end
