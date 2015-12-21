require File.expand_path('../../../spec_helper', __FILE__)
require 'reward_service'

=begin
Verify fetchRewardByTitleAndType service works correctly
=end

describe "TS03 - fetchRewardByTitleAndType - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '000a000101b6041a'
  title_id = '1037'
  type = 'CERT'
  res = nil

  context 'TC03.001 - fetchRewardByTitleAndType - Successful Response' do
    reward_num = nil
    xml_res = nil

    before :all do
      xml_res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id, type, '10', '0')
      reward_num = xml_res.xpath('//reward').count
    end

    it 'Check for existence of Reward' do
      expect(reward_num).not_to eq(0)
    end

    it 'Verify fetchRewardByTitleAndType responses correctly' do
      (1..reward_num).each do |i|
        id = xml_res.xpath('//reward[' + i.to_s + ']').attr('title-id').text
        reward_type = xml_res.xpath('//reward[' + i.to_s + ']').attr('type').text

        expect(id).to eq(title_id)
        expect(reward_type).to eq(type)
      end
    end
  end

  context 'TC03.002 - fetchRewardByTitleAndType - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id2, device_serial, '0', title_id, type, '10', '0')
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC03.003 - fetchRewardByTitleAndType - device-serial - Empty' do
    device_serial3 = ''

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial3, '0', title_id, type, '10', '0')
    end

    it 'Verify error soap fault response' do
      expect('#36332: Web Services: reward-service: fetchRewardByTitleAndType: The services call  return SOAP fault with SQL information in faultstring when calling service with invalid @device, @slot value').to eq(res)
    end
  end

  context 'TC03.004 - fetchRewardByTitleAndType - device-serial - Nonexistence' do
    device_serial4 = 'non-existence'

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial4, '0', title_id, type, '10', '0')
    end

    it 'Verify error soap fault response' do
      expect('#36332: Web Services: reward-service: fetchRewardByTitleAndType: The services call  return SOAP fault with SQL information in faultstring when calling service with invalid @device, @slot value').to eq(res)
    end
  end

  context 'TC03.005 - fetchRewardByTitleAndType - slot - Nonexistence' do
    slot5 = '10'

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, slot5, title_id, type, '10', '0')
    end

    it 'Verify error soap fault response' do
      expect('#36332: Web Services: reward-service: fetchRewardByTitleAndType: The services call  return SOAP fault with SQL information in faultstring when calling service with invalid @device, @slot value').to eq(res)
    end
  end

  context 'TC03.006 - fetchRewardByTitleAndType - @title-id - Nonexistence' do
    title_id6 = '-111'
    reward_num = nil

    before :all do
      xml_res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id6, type, '10', '0')
      reward_num = xml_res.xpath('//reward').count
    end

    it 'Verify no reward is returned' do
      expect(reward_num).to eq(0)
    end
  end

  context 'TC03.007 - fetchRewardByTitleAndType - type - Nonexistence' do
    type7 = 'non-existence'
    reward_num = nil

    before :all do
      xml_res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id, type7, '10', '0')
      reward_num = xml_res.xpath('//reward').count
    end

    it 'Verify no reward is returned' do
      expect(reward_num).to eq(0)
    end
  end

  context 'TC03.008 - fetchRewardByTitleAndType - title-id and type - Nonexistence' do
    title_id8 = '-1111'
    type8 = 'non-existence'
    reward_num = nil

    before :all do
      xml_res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id8, type8, '10', '0')
      reward_num = xml_res.xpath('//reward').count
    end

    it 'Verify no reward is returned' do
      expect(reward_num).to eq(0)
    end
  end

  context 'TC03.009 - fetchRewardByTitleAndType - @title-id - Character' do
    title_id9 = 'char'

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id9, type, '10', '0')
    end

    it "Verify 'Unmarshalling Error: Not a number: char' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: char ')
    end
  end

  context 'TC03.010 - fetchRewardByTitleAndType - @page-length - Character' do
    length10 = 'char'

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id, type, length10, '0')
    end

    it "Verify 'Unmarshalling Error: Not a number: char' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: char ')
    end
  end

  context 'TC03.011 - fetchRewardByTitleAndType - @page-length - Negative Number' do
    length11 = '-111'

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id, type, length11, '0')
    end

    it "Verify 'The service call returned with fault: page parameter was null or length/offset was less than 0' error responses" do
      expect(res).to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
    end
  end

  context 'TC03.012 - fetchRewardByTitleAndType - @page-length - Out of range' do
    length12 = '4294967297123'

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id, type, length12, '0')
    end

    it 'Verify error soap fault response' do
      expect('#36330: Web Services: reward-service: fetchRewards: The services call  return successful responses with @length = 1 when calling service with @length, @offset out of range').to eq(res)
    end
  end

  context 'TC03.013 - fetchRewardByTitleAndType - @page-offset - Character' do
    offset13 = 'char'

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id, type, '10', offset13)
    end

    it "Verify 'Unmarshalling Error: Not a number: char' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: char ')
    end
  end

  context 'TC03.014 - fetchRewardByTitleAndType - @page-offset - Negative Number' do
    offset14 = '-123'

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id, type, '10', offset14)
    end

    it "Verify 'The service call returned with fault: page parameter was null or length/offset was less than 0' error responses" do
      expect(res).to eq('The service call returned with fault: page parameter was null or length/offset was less than 0')
    end
  end

  context 'TC03.015 - fetchRewardByTitleAndType - @page-offset - Out of range' do
    offset15 = '4294967297123'

    before :all do
      res = RewardService.fetch_reward_by_title_and_type(caller_id, device_serial, '0', title_id, type, '10', offset15)
    end

    it 'Verify error soap fault response' do
      expect('#36330: Web Services: reward-service: fetchRewards: The services call  return successful responses with @length = 1 when calling service with @length, @offset out of range').to eq(res)
    end
  end
end
