require File.expand_path('../../../spec_helper', __FILE__)
require 'license_management'

=begin
Verify grantLicense service works correctly
=end

describe "TS04 - grantLicense - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  session = '491309d5-c2cd-4deb-aa9d-ea426372006e'
  cust_key = '2766864'
  device_serial = '3A1521000101FF001032'
  package_id = '50038-97914'
  res = nil

  context 'TC04.001 - grantLicense - Successful Response - Successful Response' do
    license_type1 = package_id1 = nil
    license_count_1 = license_count_2 = 0

    before :all do
      # fetchRestrictedLicenses before grant_license
      fetch_res = LicenseManagement.fetch_restricted_licenses(caller_id, 'service', session, cust_key, device_serial)
      license_count_1 = fetch_res.xpath('//licenses').count

      # grantLicense
      xml_response1 = LicenseManagement.grant_license(caller_id, session, cust_key, device_serial, package_id)
      license_type1 = xml_response1.xpath('//license').attr('type').text
      package_id1 = xml_response1.xpath('//license').attr('package-id').text

      # fetchRestrictedLicenses after grant_license
      fetch_res = LicenseManagement.fetch_restricted_licenses(caller_id, 'service', session, cust_key, device_serial)
      license_count_2 = fetch_res.xpath('//licenses').count
    end

    it 'Verify License Type responses from grantLicense' do
      expect(license_type1).to eq('purchase')
    end

    it 'Verify License ID responses from grantLicense' do
      expect(package_id1).to eq(package_id)
    end

    it 'Verify License count responses from fetchRestrictedLicenses' do
      expect(license_count_1 + 1).to eq(license_count_2)
    end
  end

  context 'TC04.002 - grantLicense - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = LicenseManagement.grant_license(caller_id2, session, cust_key, device_serial, package_id)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC04.003 - grantLicense - Invalid Request' do
    package_id3 = 'invalid'

    before :all do
      res = LicenseManagement.grant_license(caller_id, session, cust_key, device_serial, package_id3)
    end

    it "Verify 'Unable to handle the request: No meta data found for package id...' error message responses" do
      expect(res).to eq('Unable to handle the request: No meta data found for package id [' + package_id3 + ']')
    end
  end
end
