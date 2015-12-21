require File.expand_path('../../../spec_helper', __FILE__)
require 'license_management'

=begin
Verify checkEligibility service works correctly
=end

describe "TS01 - checkEligibility - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '3A1521000101FF001032'
  cus_key = '2766864'
  package_id = '50038-97914'
  res = nil

  context 'TC01.001 - checkEligibility - Successful Response' do
    package_id1 = package_type1 = description1 = nil

    before :all do
      xml_res = LicenseManagement.check_eligibility(caller_id, cus_key, device_serial, package_id)
      package_id1 = xml_res.xpath('//package-eligibility/package').attr('id').text
      package_type1 = xml_res.xpath('//package-eligibility/package').attr('type').text
      description1 = xml_res.xpath('//package-eligibility/result').attr('description').text
    end

    it 'Check match content of Package ID' do
      expect(package_id1).to eq(package_id)
    end

    it 'Check match content of Package Type' do
      expect(package_type1).to eq('Application')
    end

    it 'Check match content of Description' do
      expect(description1).to eq('The customer already has licenses for this package.')
    end
  end

  context 'TC01.002 - checkEligibility - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = LicenseManagement.check_eligibility(caller_id2, cus_key, device_serial, package_id)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - checkEligibility - Invalid Request - Package ID' do
    package_id3 = 'invalid50038-97914'
    description = nil

    before :all do
      xml_res = LicenseManagement.check_eligibility(caller_id, cus_key, device_serial, package_id3)
      description = xml_res.xpath('//package-eligibility/result').attr('description').text
    end

    it "Verify 'This package is not defined in WEBCRM.' error responses" do
      expect(description).to eq('This package is not defined in WEBCRM.')
    end
  end

  context 'TC01.004 - checkEligibility - Invalid Request - Not License' do
    device_serial4 = ''
    package_id4 = nil

    before :all do
      xml_res = LicenseManagement.check_eligibility(caller_id, cus_key, device_serial4, package_id)
      package_id4 = xml_res.xpath('//package-eligibility/package').attr('id').text
    end

    it 'Check match content of Package ID' do
      expect(package_id4).to eq(package_id)
    end
  end

  context 'TC01.005 - checkEligibility - Invalid Request - Non Customer' do
    cus_key5 = 'non' + cus_key

    before :all do
      res = LicenseManagement.check_eligibility(caller_id, cus_key5, device_serial, package_id)
    end

    it "Verify 'An internal error occurred: com.leapfrog.inmon.services.InvalidRequestException: No customer found with key...' error responses" do
      expect(res).to eq("An internal error occurred: com.leapfrog.inmon.services.InvalidRequestException: No customer found with key '0'")
    end
  end
end
