require File.expand_path('../../../spec_helper', __FILE__)
require 'package_management'

=begin
Verify packageDotSpaces service works correctly
=end

describe "TS06 - packageDotSpaces - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:package_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:package_management][:namespace]
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  package_id = 'LPRD-0x000B003A-000000'
  platform = 'leapreader'
  package_title = 'Disney/Pixar The World of Cars: Tractor Tipping'
  res = nil

  context 'TC006.001 - packageDotSpaces - Successful Response' do
    xml_res = nil

    before :all do
      xml_res = PackageManagement.package_dot_spaces(caller_id, 'en_US', platform, package_title, package_id)
    end

    it 'Verify package-ID responses correctly' do
      expect(xml_res.xpath('//dotspace/package-id').text).to eq(package_id)
    end

    it 'Verify package-Title responses correctly' do
      expect(xml_res.xpath('//dotspace/package-title').text).to eq(package_title)
    end

    it 'Verify upL exists' do
      expect(xml_res.xpath('//bounding-box/upL').count).to eq(1)
    end

    it 'Verify lowR exists' do
      expect(xml_res.xpath('//bounding-box/lowR').count).to eq(1)
    end
  end

  context 'TC006.002 - packageDotSpaces - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = PackageManagement.package_dot_spaces(caller_id2, 'en_US', platform, package_title, package_id)
    end

    it "Verify 'Supplied caller id is not well formed' error responses correctly" do
      expect(res).to eq('Supplied caller id is not well formed')
    end
  end

  context 'TC006.003 - packageDotSpaces - Invalid Request' do
    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :package_dot_spaces,
        "<caller-id>#{caller_id}</caller-id>
        <locale>en_US</locale>
        <platform>#{platform}</platform>
        <dotspace refresh='false'></dotspace>"
      )
    end

    it "Verify 'en_US/leapreader' error responses correctly" do
      expect(res).to eq('en_US/leapreader')
    end
  end

  context 'TC006.004 - packageDotSpaces - Inexistent Package' do
    package_id4 = 'Inexistent'
    error = nil

    before :all do
      xml_res = PackageManagement.package_dot_spaces(caller_id, 'en_US', platform, package_title, package_id4)
      error = xml_res.xpath('//dotspace/error').text
    end

    it "Verify 'Not Found' error responses correctly" do
      expect(error).to eq('Not Found')
    end
  end
end
