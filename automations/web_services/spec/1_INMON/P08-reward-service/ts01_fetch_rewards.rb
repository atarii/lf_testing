require File.expand_path('../../../spec_helper', __FILE__)
require 'reward_service'

=begin
Verify revokeLicense service works correctly
=end

describe "TS01 - fetchRewards - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '000a000101b6041a'
  res = nil

  context 'TC01.001 - fetchRewards - Successful Response' do
    reward_num = nil

    before :all do
      xml_res = RewardService.fetch_rewards(caller_id, device_serial, '0', '100', '0')
      reward_num = xml_res.xpath('//reward').count
    end

    it 'Verify fetchRewards calls successfully' do
      expect(reward_num).not_to eq(0)
    end
  end

  context 'TC01.002 - fetchRewards - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = RewardService.fetch_rewards(caller_id2, device_serial, '0', '100', '0')
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - fetchRewards - device - Empty' do
    device_serial3 = ''

    before :all do
      res = RewardService.fetch_rewards(caller_id, device_serial3, '0', '100', '0')
    end

    it 'Verify error message response' do
      expect('#36327: Web Services: reward-service: fetchRewards: The services call  return SOAP fault with SQL information in faultstring when calling service with invalid @device, @slot value').to eq(res)
    end
  end

  context 'TC01.004 - fetchRewards - slot - Nonexistence' do
    slot = '10'

    before :all do
      res = RewardService.fetch_rewards(caller_id, device_serial, slot, '100', '0')
    end

    it 'Verify error message response' do
      expect('#36327: Web Services: reward-service: fetchRewards: The services call  return SOAP fault with SQL information in faultstring when calling service with invalid @device, @slot value').to eq(res)
    end
  end

  context 'TC01.005 - fetchRewards - @length - Character' do
    length = 'char'

    before :all do
      res = RewardService.fetch_rewards(caller_id, device_serial, '0', length, '0')
    end

    it "Verify 'Unmarshalling Error: Not a number: invalid' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: char ')
    end
  end

  context 'TC01.006 - fetchRewards - @length - Negative Number' do
    length = '-123'

    before :all do
      res = RewardService.fetch_rewards(caller_id, device_serial, '0', length, '0')
    end

    it "Verify 'The service call returned with fault: page parameter was null or length/offset was less than 0' error responses" do
      expect(res).to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
    end
  end

  context 'TC01.007 - fetchRewards - @length - Out of range' do
    length = '12345678901234567890'

    before :all do
      res = RewardService.fetch_rewards(caller_id, device_serial, '0', length, '0')
    end

    it 'Report known issue' do
      expect(res).to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
    end
  end

  context 'TC01.008 - fetchRewards - @offset - Character' do
    offset = 'char'

    before :all do
      res = RewardService.fetch_rewards(caller_id, device_serial, '1', '100', offset)
    end

    it "Verify 'The service call returned with fault: page parameter was null or length/offset was less than 0' error responses" do
      if res == 'Unmarshalling Error: Not a number: char '
        expect('#36905: Web Services: fetchRewards: "Unmarshalling Error: Not a number: char" instead of "page parameter was null or length..." error message responses ').to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
      else
        expect(res).to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
      end
    end
  end

  context 'TC01.009 - fetchRewards - @offset - Negative Number' do
    offset = '-123'

    before :all do
      res = RewardService.fetch_rewards(caller_id, device_serial, '0', '100', offset)
    end

    it "Verify 'The service call returned with fault: page parameter was null or length/offset was less than 0' error responses" do
      expect(res).to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
    end
  end

  context 'TC01.010 - fetchRewards - @offset - Out of range' do
    offset = '42949672974294967297'

    before :all do
      res = RewardService.fetch_rewards(caller_id, device_serial, '0', '100', offset)
    end

    it 'Verify error message response' do
      expect('#36330: Web Services: reward-service: fetchRewards: The services call  return successful responses with @length = 1 when calling service with @length, @offset out of range').to eq(res)
    end
  end
end
