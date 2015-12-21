require File.expand_path('../../../spec_helper', __FILE__)
require 'package_management'

=begin
Verify packageVersions service works correctly
=end

describe "TS08 - packageVersions - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  package_id = 'MULT-0x001B001A-000000'
  res = nil

  context 'TC08.001 - packageVersions - Successful Response' do
    pkg_versions_res = PackageManagement.package_versions(caller_id, package_id)
    check_version = PackageManagement.check_pkg_version(pkg_versions_res, package_id)

    it 'Verify packageVersions calls successfully' do
      expect(check_version).to eq(1)
    end
  end

  context 'TC08.002 - packageVersions - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = PackageManagement.package_versions(caller_id2, package_id)
    end

    it "Verify 'Supplied caller id is not well formed' error message responses" do
      expect(res).to eq('Supplied caller id is not well formed')
    end
  end

  context 'TC08.003 - packageVersions - Invalid Request' do
    package_id = ''
    status = nil

    before :all do
      xml_res = PackageManagement.package_versions(caller_id, package_id)
      status = xml_res.xpath('//package-version/package').attr('status').text
    end

    it "Verify 'NOT_FOUND' status responses" do
      expect(status).to eq('NOT_FOUND')
    end
  end
end
