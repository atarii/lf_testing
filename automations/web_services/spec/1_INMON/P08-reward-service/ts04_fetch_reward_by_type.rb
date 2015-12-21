require File.expand_path('../../../spec_helper', __FILE__)
require 'reward_service'

=begin
Verify fetchRewardByType service works correctly
=end

describe "TS04 - fetchRewardByType - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '000a000101b6041a'
  type = 'CERT'
  slot = '0'
  length = '10'
  offset = '0'
  res = nil

  context 'TC04.001 - fetchRewardByType - Successful Response' do
    reward_num = nil
    xml_response = nil

    before :all do
      xml_response = RewardService.fetch_rewards_by_type(caller_id, device_serial, slot, type, length, offset)
      reward_num = xml_response.xpath('//reward').count
    end

    it 'Check for existence of Reward' do
      expect(reward_num).not_to eq(0)
    end

    it 'Verify fetchRewardByTitleAndType responses correctly' do
      (1..reward_num).each do |i|
        reward_type = xml_response.xpath('//reward[' + i.to_s + ']').attr('type').text
        expect(reward_type).to eq(type)
      end
    end
  end

  context 'TC04.002 - fetchRewardByType - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = RewardService.fetch_rewards_by_type(caller_id2, device_serial, slot, type, length, offset)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC04.003 - fetchRewardByType - device-serial - Empty' do
    device_serial3 = ''

    before :all do
      res = RewardService.fetch_rewards_by_type(caller_id, device_serial3, slot, type, length, offset)
    end

    it 'Verify error soap fault response' do
      expect('#36335:Web Services: reward-service: fetchRewardByType: The services call  return SOAP fault with SQL information in faultstring when calling service with invalid @device, @slot value').to eq(res)
    end
  end

  context 'TC04.004 - fetchRewardByType - slot - Nonexistence' do
    slot4 = '10'

    before :all do
      res = RewardService.fetch_rewards_by_type(caller_id, device_serial, slot4, type, length, offset)
    end

    it 'Verify error soap fault response' do
      expect('#36335:Web Services: reward-service: fetchRewardByType: The services call  return SOAP fault with SQL information in faultstring when calling service with invalid @device, @slot value').to eq(res)
    end
  end

  context 'TC04.005 - fetchRewardByType - type - Empty' do
    type5 = ''
    reward_num = nil

    before :all do
      xml_response = RewardService.fetch_rewards_by_type(caller_id, device_serial, slot, type5, length, offset)
      reward_num = xml_response.xpath('//reward').count
    end

    it 'Verify no reward is returned' do
      expect(reward_num).to eq(0)
    end
  end

  context 'TC04.006 - fetchRewardByType - type - Nonexistence' do
    type6 = 'non-existence'
    reward_num = nil

    before :all do
      xml_response = RewardService.fetch_rewards_by_type(caller_id, device_serial, slot, type6, length, offset)
      reward_num = xml_response.xpath('//reward').count
    end

    it 'Verify no reward is returned' do
      expect(reward_num).to eq(0)
    end
  end

  context 'TC04.007 - fetchRewardByType - @page-length - Character' do
    length7 = 'char'

    before :all do
      res = RewardService.fetch_rewards_by_type(caller_id, device_serial, slot, type, length7, offset)
    end

    it "Verify 'Unmarshalling Error: Not a number: char' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: char ')
    end
  end

  context 'TC04.008 - fetchRewardByType - @page-length - Negative Number' do
    length8 = '-111'

    before :all do
      res = RewardService.fetch_rewards_by_type(caller_id, device_serial, slot, type, length8, offset)
    end

    it "Verify 'The service call returned with fault: page parameter was null or length/offset was less than 0' error responses" do
      expect(res).to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
    end
  end

  context 'TC04.009 - fetchRewardByType - @page-length - Out of range' do
    length9 = '4294967297123'

    before :all do
      res = RewardService.fetch_rewards_by_type(caller_id, device_serial, slot, type, length9, offset)
    end

    it 'Verify error soap fault response' do
      expect('#36330: Web Services: reward-service: fetchRewards: The services call  return successful responses with @length = 1 when calling service with @length, @offset out of range').to eq(res)
    end
  end

  context 'TC04.010 - fetchRewardByType - @page-offset - Character' do
    offset10 = 'char'

    before :all do
      res = RewardService.fetch_rewards_by_type(caller_id, device_serial, slot, type, length, offset10)
    end

    it "Verify 'Unmarshalling Error: Not a number: ...' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: char ')
    end
  end

  context 'TC04.011 - fetchRewardByType - @page-offset - Negative Number' do
    offset11 = '-1111'

    before :all do
      res = RewardService.fetch_rewards_by_type(caller_id, device_serial, slot, type, length, offset11)
    end

    it "Verify 'The service call returned with fault: page parameter was null or length/offset was less than 0' error responses" do
      expect(res).to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
    end
  end

  context 'TC04.012 - fetchRewardByType - @page-offset - Out of range' do
    offset12 = '4294967297123'

    before :all do
      res = RewardService.fetch_rewards_by_type(caller_id, device_serial, slot, type, length, offset12)
    end

    it 'Verify error soap fault response' do
      expect('#36330: Web Services: reward-service: fetchRewards: The services call  return successful responses with @length = 1 when calling service with @length, @offset out of range').to eq(res)
    end
  end
end
