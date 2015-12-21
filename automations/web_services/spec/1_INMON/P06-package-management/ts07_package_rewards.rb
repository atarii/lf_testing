require File.expand_path('../../../spec_helper', __FILE__)
require 'package_management'

=begin
Verify packageRewards service works correctly
=end

describe "TS07 - packageRewards - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '3B0621000102FF000C4B'
  product_id = ''
  platform = 'explorer2'
  slot = '0'
  weak_id = '1'
  child_id = '2772097'
  property_value = 'MHRS-0x0018001C-000000'
  res = nil

  context 'TC07.001 - packageRewards - Successful Request' do
    soap_fault = nil

    before :all do
      xml_res = PackageManagement.package_rewards(caller_id, device_serial, product_id, platform, slot, weak_id, child_id, property_value)
      soap_fault = xml_res.xpath('//fault/faultstring').count
    end

    it 'Verify packageRewards calls successfully' do
      expect(soap_fault).to eq(0)
    end
  end

  context 'TC07.002 - packageRewards - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = PackageManagement.package_rewards(caller_id2, device_serial, product_id, platform, slot, weak_id, child_id, property_value)
    end

    it "Verify 'Supplied caller id is not well formed' error message responses" do
      expect(res).to eq('Supplied caller id is not well formed')
    end
  end

  context 'TC07.003 - packageRewards - Invalid Request' do
    platform3 = 'bad_platform'

    before :all do
      res = PackageManagement.package_rewards(caller_id, device_serial, product_id, platform3, slot, weak_id, child_id, property_value)
    end

    it "Verify 'The given platform type is invalid...' error message responses" do
      expect(res).to eq('The given platform type is invalid: ' + platform3)
    end
  end

  context 'TC07.004 - packageRewards - ProductID - Characters' do
    product_id4 = 'abcinvalid'

    before :all do
      res = PackageManagement.package_rewards(caller_id, device_serial, product_id4, platform, slot, weak_id, child_id, property_value)
    end

    it "Verify 'Unmarshalling Error: Not a number: ...' error message responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: ' + product_id4 + ' ')
    end
  end

  context 'TC07.005 - packageRewards - ProductID - Large number' do
    product_id5 = '12312312312312312312312312312312312312312312312312'

    before :all do
      PackageManagement.package_rewards(caller_id, device_serial, product_id5, platform, slot, weak_id, child_id, property_value)
    end

    it 'Report bug' do
      expect('#36323: Web Services: device-management: updateProfiles: The service responses successful content when update profiles with  @product-id, @slot, @weak-id, @size attributes as invalid value').to eq(res)
    end
  end

  context 'TC07.006 - packageRewards - Invalid Slot 01' do
    slot6 = 'invalid'

    before :all do
      res = PackageManagement.package_rewards(caller_id, device_serial, product_id, platform, slot6, weak_id, child_id, property_value)
    end

    it "Verify 'Unmarshalling Error: Not a number: ...' error message responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: ' + slot6 + ' ')
    end
  end

  context 'TC07.007 - packageRewards - Invalid Slot 02' do
    slot7 = '1312736127864782367892634789252423423'

    before :all do
      PackageManagement.package_rewards(caller_id, device_serial, product_id, platform, slot7, weak_id, child_id, property_value)
    end

    it 'Report bug' do
      expect('#36323: Web Services: device-management: updateProfiles: The service responses successful content when update profiles with  @product-id, @slot, @weak-id, @size attributes as invalid value').to eq(res)
    end
  end

  context 'TC07.008 - packageRewards - Invalid Weak-ID 01' do
    weak_id8 = 'invalid'

    before :all do
      res = PackageManagement.package_rewards(caller_id, device_serial, product_id, platform, slot, weak_id8, child_id, property_value)
    end

    it "Verify 'Unmarshalling Error: Not a number: ...' error message responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: ' + weak_id8 + ' ')
    end
  end

  context 'TC07.009 - packageRewards - Invalid Weak-ID 02' do
    weak_id9 = '1983789123641482635789364896789754'

    before :all do
      PackageManagement.package_rewards(caller_id, device_serial, product_id, platform, slot, weak_id9, child_id, property_value)
    end

    it 'Report bug' do
      expect('#36323: Web Services: device-management: updateProfiles: The service responses successful content when update profiles with  @product-id, @slot, @weak-id, @size attributes as invalid value').to eq(res)
    end
  end
end
