require File.expand_path('../../../spec_helper', __FILE__)
require 'device_profile_content'

=begin
Verify uploadContent service works correctly
=end

describe "TS03 - uploadContent - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '3A191700010AFF01F581'
  session = '969fc9aa-5ac2-474f-8076-44480b9672a3'
  slot = '0'
  package_id = 'MHRS-0x001B0011-000000'
  content = 'Logging Data-134911-164939-0.bin'
  res = nil

  context 'TC03.001 - uploadContent - Successfully Response' do
    soap_fault = nil

    before :all do
      xml_res = DeviceProfileContent.upload_content(caller_id, session, device_serial, slot, package_id, content)
      soap_fault = xml_res.xpath('//faultcode').count
    end

    it "Verify 'uploadContent' calls successfully" do
      expect(soap_fault).to eq(0)
    end
  end

  context 'TC03.002 - uploadContent - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = DeviceProfileContent.upload_content(caller_id2, session, device_serial, slot, package_id, content)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC03.003 - uploadContent - Invalid Request' do
    session3 = '12345'
    package_id3 = '123'
    device_serial3 = '3B0C27000101FF0039DE'

    before :all do
      res = DeviceProfileContent.upload_content(caller_id, session3, device_serial3, slot, package_id3, content)
    end

    it "Verify 'Session is invalid: 12345' error responses" do
      expect(res).to eq('Session is invalid: 12345')
    end
  end

  context 'TC03.005 - uploadContent - Slot - Characters' do
    slot5 = 'invalid'

    before :all do
      res = DeviceProfileContent.upload_content(caller_id, session, device_serial, slot5, package_id, content)
    end

    it "Verify 'Unmarshalling Error: Not a number: invalid' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: invalid ')
    end
  end

  context 'TC03.006 - uploadContent - Slot - Large number' do
    slot6 = '111111111111111111111111111111111111111111111111111122222222223'
    soap_fault = 0

    before :all do
      res = DeviceProfileContent.upload_content(caller_id, session, device_serial, slot6, package_id, content)
      soap_fault = res.xpath('//faultcode').count
    end

    it 'Verify service returns error message' do
      if soap_fault == 0
        fail 'Broken, will fix defect: UPC 36323: Web Services: device-management: updateProfiles: The service responses successful content when update profiles with  @product-id, @slot, @weak-id, @size attributes as invalid value'
      else
        expect(soap_fault).to eq(1)
      end
    end
  end
end
