require File.expand_path('../../../spec_helper', __FILE__)
require 'reward_service'

=begin
Verify fetchRewardByTitle service works correctly
=end

describe "TS02 - fetchRewardByTitle - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '000a000101b6041a'
  title_id = '1042'
  res = nil

  context 'TC02.001 - fetchRewardByTitle - Successful Response' do
    reward_num = nil
    xml_res = nil

    before :all do
      xml_res = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id, '10', '0')
      reward_num = xml_res.xpath('//reward').count
    end

    it 'Check for existence of Reward' do
      expect(reward_num).not_to eq(0)
    end

    it 'Verify fetchRewardByTitle responses correctly' do
      (1..reward_num).each do |i|
        id = xml_res.xpath('//reward[' + i.to_s + ']').attr('title-id').text
        expect(id).to eq(title_id)
      end
    end
  end

  context 'TC02.002 - fetchRewardByTitle - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id2, device_serial, '0', title_id, '10', '0')
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC02.003 - fetchRewardByTitle - device-serial - Empty' do
    device_serial3 = ''

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id, device_serial3, '0', title_id, '10', '0')
    end

    it 'Verify error message response' do
      expect('#36331: Web Services: reward-service: fetchRewardByTitle: The services call  return SOAP fault with SQL information in faultstring when calling service with invalid @device, @slot value').to eq(res)
    end
  end

  context 'TC02.004 - fetchRewardByTitle - device-serial - Nonexistence' do
    device_serial4 = 'non-existence'

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id, device_serial4, '0', title_id, '10', '0')
    end

    it 'Verify error message response' do
      expect('#36331: Web Services: reward-service: fetchRewardByTitle: The services call  return SOAP fault with SQL information in faultstring when calling service with invalid @device, @slot value').to eq(res)
    end
  end

  context 'TC02.005 - fetchRewardByTitle - @title-id - Character' do
    title_id5 = 'char'

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id5, '10', '0')
    end

    it "Verify 'Unmarshalling Error: Not a number: char' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: char ')
    end
  end

  context 'TC02.006 - fetchRewardByTitle - @title-id - Nonexistence' do
    title_id6 = '-111'
    reward_num = nil

    before :all do
      xml_res = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id6, '10', '0')
      reward_num = xml_res.xpath('//reward').count
    end

    it 'Verify no reward is returned' do
      expect(reward_num).to eq(0)
    end
  end

  context 'TC02.007 - fetchRewardByTitle - @title-id - Out of range' do
    title_id7 = '4294968334232'
    reward_num = nil

    before :all do
      xml_res = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id7, '10', '0')
      reward_num = xml_res.xpath('//reward').count
    end

    it 'Verify no reward is returned' do
      expect(reward_num).to eq(0)
    end
  end

  context 'TC02.008 - fetchRewardByTitle - @page-length - Out of range' do
    length8 = '4294967297123'

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id, length8, '0')
    end

    it 'Verify error message response' do
      expect('#36330: Web Services: reward-service: fetchRewards: The services call  return successful responses with @length = 1 when calling service with @length, @offset out of range').to eq(res)
    end
  end

  context 'TC02.009 - fetchRewardByTitle - @page-length - Character' do
    length9 = 'character'

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id, length9, '0')
    end

    it "Verify 'Unmarshalling Error: Not a number: character' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: character ')
    end
  end

  context 'TC02.010 - fetchRewardByTitle - @page-length - Negative Number' do
    length10 = '-111'

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id, length10, '0')
    end

    it "Verify 'The service call returned with fault: page parameter was null or length/offset was less than 0' error responses" do
      expect(res).to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
    end
  end

  context 'TC02.011 - fetchRewardByTitle - @page-offset - Out of range' do
    offset11 = '4294967297123'

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id, '10', offset11)
    end

    it 'Verify error message response' do
      expect('#36330: Web Services: reward-service: fetchRewards: The services call  return successful responses with @length = 1 when calling service with @length, @offset out of range').to eq(res)
    end
  end

  context 'TC02.012 - fetchRewardByTitle - @page-offset - Character' do
    offset12 = 'character'

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id, '10', offset12)
    end

    it "Verify 'Unmarshalling Error: Not a number: character' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: character ')
    end
  end

  context 'TC02.013 - fetchRewardByTitle - @page-offset - Negative Number' do
    offset13 = '-123'

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id, '10', offset13)
    end

    it "Verify 'The service call returned with fault: page parameter was null or length/offset was less than 0' error responses" do
      expect(res).to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
    end
  end

  context 'TC02.014 - fetchRewardByTitle - slot - Nonexistence' do
    slot14 = '10'

    before :all do
      res = RewardService.fetch_rewards_by_title(caller_id, device_serial, slot14, title_id, '10', '0')
    end

    it 'Verify error message response' do
      expect('#36331: Web Services: reward-service: fetchRewardByTitle: The services call  return SOAP fault with SQL information in faultstring when calling service with invalid @device, @slot value').to eq(res)
    end
  end
end
