require File.expand_path('../../../spec_helper', __FILE__)
require 'package_management'

=begin
Verify packageDependencies service works correctly
=end

describe "TS05 - packageDependencies - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:package_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:package_management][:namespace]
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  expected_dependencies_count = 3
  expected_package_dependencies_count = 4
  package_id = 'MULT-0x001B001A-000000'
  package_name = 'Jewel Train 2 : Twisty Tracks'
  res = nil

  context 'TC05.001 - packageDependencies - Successful Response' do
    dependencies_count = pkg_dpd_count = nil

    before :all do
      xml_res = PackageManagement.package_dependencies(caller_id, package_id, package_name)
      dependencies_count = xml_res.xpath('//package/dependencies').count
      pkg_dpd_count = xml_res.xpath('//package').count - xml_res.xpath('//package/package').count
    end

    it 'Check count of package Dependencies' do
      expect(pkg_dpd_count).to eq(expected_package_dependencies_count)
    end

    it 'Check count of Dependencies' do
      expect(dependencies_count).to eq(expected_dependencies_count)
    end
  end

  context 'TC05.002 - packageDependencies - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = PackageManagement.package_dependencies(caller_id2, package_id, package_name)
    end

    it "Verify 'Supplied caller id is not well formed' error message responses" do
      expect(res).to eq('Supplied caller id is not well formed')
    end
  end

  context 'TC05.003 - packageDependencies - Invalid Request' do
    package_id3 = ''
    status = nil

    before :all do
      xml_res = PackageManagement.package_dependencies(caller_id, package_id3, package_name)
      status = xml_res.xpath('//package/package').attr('status').text
    end

    it "Verify invalid request responses 'NOT_FOUND' status" do
      expect(status).to eq('NOT_FOUND')
    end
  end

  context 'TC05.004 - packageDependencies - Size - Characters' do
    size = 'invalid'

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :package_dependencies,
        "<caller-id>#{caller_id}</caller-id>
        <package>
          <package version-date='' id='#{package_id}' name='#{package_name}' uri='' checksum='' code='' size='#{size}'/>
        </package>"
      )
    end

    it "Verify 'Unmarshalling Error: Not a number: invalid' error message responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: invalid ')
    end
  end

  context 'TC05.005 - packageDependencies - Size - Large number' do
    size = '123123123123123123123123123123123123'

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :package_dependencies,
        "<caller-id>#{caller_id}</caller-id>
        <package>
          <package version-date='' id='#{package_id}' name='#{package_name}' uri='' checksum='' code='' size='#{size}'/>
        </package>"
      )
    end

    it 'Report bug' do
      expect('#36323: Web Services: device-management: updateProfiles: The service responses successful content when update profiles with  @product-id, @slot, @weak-id, @size attributes as invalid value').to eq(res)
    end
  end
end
