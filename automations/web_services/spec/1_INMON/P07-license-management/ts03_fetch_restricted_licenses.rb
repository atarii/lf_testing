require File.expand_path('../../../spec_helper', __FILE__)
require 'license_management'

=begin
Verify fetchRestrictedLicenses service works correctly
=end

describe "TS03 - fetchRestrictedLicenses - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  session = '491309d5-c2cd-4deb-aa9d-ea426372006e'
  cust_key = '2766864'
  device_serial = '3A1521000101FF001032'
  res = nil

  context 'TC03.001 - fetchRestrictedLicenses - Successful Response' do
    license_num = nil

    before :all do
      xml_res = LicenseManagement.fetch_restricted_licenses(caller_id, 'service', session, cust_key, device_serial)
      license_num = xml_res.xpath('//licenses').count
    end

    it "Verify 'fetchRestrictedLicenses' calls successfully" do
      expect(license_num).not_to eq(0)
    end
  end

  context 'TC03.002 - fetchRestrictedLicenses - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = LicenseManagement.fetch_restricted_licenses(caller_id2, 'service', session, cust_key, device_serial)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC03.003 - fetchRestrictedLicenses - Invalid Request' do
    device_serial3 = 'invalid3A1521000101FF001032'

    before :all do
      res = LicenseManagement.fetch_restricted_licenses(caller_id, 'service', session, cust_key, device_serial3)
    end

    it "Verify 'Unable to handle the request: No device found with serial number' error responses" do
      expect(res).to eq("Unable to handle the request: No device found with serial number '" + device_serial3 + "'")
    end
  end
end
