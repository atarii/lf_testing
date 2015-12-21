require File.expand_path('../../../spec_helper', __FILE__)
require 'device_profile_content'

=begin
Verify fetchContentIndex service works correctly
=end

describe "TS01 - fetchContentIndex - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '3A191700010AFF01F581'
  session = '969fc9aa-5ac2-474f-8076-44480b9672a3'
  slot = '0'
  res = nil

  context 'TC01.001 - fetchContentIndex - Successfully Response' do
    soap_fault = nil

    before :all do
      xml_res = DeviceProfileContent.fetch_content_index(caller_id, session, device_serial, slot)
      soap_fault = xml_res.xpath('//faultcode').count
    end

    it "Verify 'fetchContentIndex' calls successfully" do
      expect(soap_fault).to eq(0)
    end
  end

  context 'TC01.002 - fetchContentIndex - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = DeviceProfileContent.fetch_content_index(caller_id2, session, device_serial, slot)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - fetchContentIndex - Invalid Request' do
    slot3 = 'invalid'

    before :all do
      res = DeviceProfileContent.fetch_content_index(caller_id, session, device_serial, slot3)
    end

    it "Verify 'Unmarshalling Error: Not a number: invalid' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: invalid ')
    end
  end

  context 'TC01.004 - fetchContentIndex - Invalid Session' do
    session4 = 'invalid969fc9aa-5ac2-474f-8076-44480b9672a3'

    before :all do
      res = DeviceProfileContent.fetch_content_index(caller_id, session4, device_serial, slot)
    end

    it "Verify 'Session is invalid: invalid969fc9aa-5ac2-474f-8076-44480b9672a3' error responses" do
      expect(res).to eq('Session is invalid: invalid969fc9aa-5ac2-474f-8076-44480b9672a3')
    end
  end

  context 'TC01.006 - fetchContentIndex - Slot - Characters' do
    slot6 = 'invalid'

    before :all do
      res = DeviceProfileContent.fetch_content_index(caller_id, session, device_serial, slot6)
    end

    it "Verify 'Unmarshalling Error: Not a number: invalid' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: invalid ')
    end
  end

  context 'TC01.007 - fetchContentIndex - Slot - Large number' do
    slot7 = '111111111111111111111111111111111111111111111111111122222222223'

    before :all do
      res = DeviceProfileContent.fetch_content_index(caller_id, session, device_serial, slot7)
    end

    it 'Report bug' do
      expect('#36323: Web Services: device-management: updateProfiles: The service responses successful content when update profiles with  @product-id, @slot, @weak-id, @size attributes as invalid value').to eq(res)
    end
  end
end
