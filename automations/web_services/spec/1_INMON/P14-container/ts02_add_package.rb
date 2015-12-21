require File.expand_path('../../../spec_helper', __FILE__)
require 'authentication'
require 'child_management'
require 'customer_management'
require 'device_management'
require 'owner_management'
require 'container_management'

=begin
Verify addPackage service works correctly
=end

describe "TS02 - addPackage - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:container_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:container_management][:namespace]
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  container_id = '10787'
  package_name = 'Yo Gabba Gabba: Go Gabba Gabba! device asset'
  code = '59306-96914'
  uri = 'uri'
  checksum = ''
  res = nil

  context 'TC02.001 - addPackage - Successful Response' do
    add_package_res = nil

    before :all do
      xml_response = ContainerManagement.add_package(caller_id, container_id, package_name, code, uri, checksum)
      add_package_res = xml_response.xpath('//ns2:addPackageResponse', 'ns2' => 'http://services.leapfrog.com/inmon/container/service/').count
    end

    it 'Check for existence of [ns2:add_package_res]' do
      expect(add_package_res).not_to eq(0)
    end
  end

  context 'TC01.002 - addPackage - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = ContainerManagement.add_package(caller_id2, container_id, package_name, code, uri, checksum)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - addPackage - Invalid ContainerID' do
    container_id3 = 'invalidcontanerID'

    before :all do
      res = ContainerManagement.add_package(caller_id, container_id3, package_name, code, uri, checksum)
    end

    it "Verify 'Container is invalid' error responses" do
      expect(res).to eq('Container is invalid')
    end
  end

  context 'TC01.004 - addPackage - Invalid Size' do
    size = 'invalid'

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :add_package,
        "<caller-id>#{caller_id}</caller-id>
        <container id='#{container_id}'/>
        <package name='#{package_name}' code='#{code}' uri='#{uri}' checksum='#{checksum}' id='PHRS-0x001B0294-DA0000' version='1.0.0.0' min-version='1.0.0.0' status='' locale='US' size='#{size}' version-date=''/>"
      )
    end

    it "Verify 'Unmarshalling Error: Not a number: Invalid error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: invalid ')
    end
  end
end
