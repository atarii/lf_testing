require File.expand_path('../../../spec_helper', __FILE__)
require 'license_management'

=begin
Verify childInventory service works correctly
=end

describe "TS02 - childInventory - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  session = '491309d5-c2cd-4deb-aa9d-ea426372006e'
  child_id = '2766866'

  context 'TC02.001 - childInventory - Successful Response' do
    type = nil

    before :all do
      xml_res = LicenseManagement.child_inventory(caller_id, 'Application', session, child_id)
      type = xml_res.xpath('//packages').attr('type').text
    end

    it 'Check match content of Package Type' do
      expect(type).to eq('Application')
    end
  end

  context 'TC02.003 - childInventory - Invalid Request' do
    package_num = nil

    before :all do
      xml_res = LicenseManagement.child_inventory(caller_id, 'service', '', 'non-child')
      package_num = xml_res.xpath('//packages').count
    end

    it 'Verify no value returns' do
      expect(package_num).to eq(0)
    end
  end
end
