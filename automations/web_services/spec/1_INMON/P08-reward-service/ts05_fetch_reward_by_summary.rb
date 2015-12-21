require File.expand_path('../../../spec_helper', __FILE__)
require 'reward_service'

=begin
Verify fetchRewardBySummary service works correctly
=end

describe "TS05 - fetchRewardBySummary - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '000a000101b6041a'
  slot = '0'
  res = nil

  context 'TC05.001 - fetchRewardBySummary - Successful Response' do
    xml_response = nil

    before :all do
      xml_response = RewardService.fetch_reward_summary(caller_id, device_serial, slot)
    end

    it 'Check for existence of Total' do
      expect(xml_response.xpath('//summary').attr('total').text).not_to be_empty
    end

    it 'Check for existence of Unseen' do
      expect(xml_response.xpath('//summary').attr('unseen').text).not_to be_empty
    end

    it 'Check for existence of Type' do
      expect(xml_response.xpath('//summary').attr('type').text).not_to be_empty
    end
  end

  context 'TC05.002 - fetchRewardBySummary - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = RewardService.fetch_reward_summary(caller_id2, device_serial, slot)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC05.003 - fetchRewardBySummary - device - Nonexistence' do
    device_serial3 = 'non-existence'
    summary_num = nil

    before :all do
      xml_response = RewardService.fetch_reward_summary(caller_id, device_serial3, slot)
      summary_num = xml_response.xpath('//summary').count
    end

    it 'Verify no value responses' do
      expect(summary_num).to eq(0)
    end
  end

  context 'TC05.004 - fetchRewardBySummary - slot - Nonexistence' do
    slot4 = '10'
    summary_num = nil

    before :all do
      xml_response = RewardService.fetch_reward_summary(caller_id, device_serial, slot4)
      summary_num = xml_response.xpath('//summary').count
    end

    it 'Verify no value responses' do
      expect(summary_num).to eq(0)
    end
  end
end
