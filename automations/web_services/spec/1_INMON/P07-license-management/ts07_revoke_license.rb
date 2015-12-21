require File.expand_path('../../../spec_helper', __FILE__)
require 'license_management'
require 'package_management'

=begin
Verify revokeLicense service works correctly
=end

describe "TS07 - revokeLicense - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  session = '491309d5-c2cd-4deb-aa9d-ea426372006e'
  cust_key = '2766864'
  device_serial = '3A1521000101FF001032'
  package_id = '50038-97914'
  res = nil

  context 'TC07.001 - revokeLicense - Successfully Response' do
    license_count_1 = license_count_2 = 0

    before :all do
      xml_grant_license_res = LicenseManagement.grant_license(caller_id, session, cust_key, device_serial, package_id)
      license_id = xml_grant_license_res.xpath('//license').attr('id').text

      # fetchRestrictedLicenses before grant_license
      fetch_res = LicenseManagement.fetch_restricted_licenses(caller_id, 'service', session, cust_key, device_serial)
      license_count_1 = fetch_res.xpath('//licenses').count

      # revokeLicense
      LicenseManagement.revoke_license(caller_id, session, license_id)

      # fetchRestrictedLicenses after grant_license
      fetch_res = LicenseManagement.fetch_restricted_licenses(caller_id, 'service', session, cust_key, device_serial)
      license_count_2 = fetch_res.xpath('//licenses').count
    end

    it 'Verify revokeLicense call successfully' do
      expect(license_count_1 - 1).to eq(license_count_2)
    end
  end

  context 'TC07.002 - revokeLicense - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = LicenseManagement.revoke_license(caller_id2, session, '648845')
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC07.003 - revokeLicense - Invalid Request' do
    session3 = ''
    license_id3 = '0'

    before :all do
      res = LicenseManagement.revoke_license(caller_id, session3, license_id3)
    end

    it "Verify 'license {'id': 0} does not exist' error message responses" do
      expect(res).to eq("license {'id': 0} does not exist")
    end
  end
end
