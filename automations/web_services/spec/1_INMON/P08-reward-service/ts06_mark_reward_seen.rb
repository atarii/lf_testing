require File.expand_path('../../../spec_helper', __FILE__)
require 'reward_service'

=begin
Verify markRewardSeen service works correctly
=end

describe "TS06.001 - markRewardSeen - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '000a000101b6041a'
  id = '3641763'
  title_id = '1386'
  res = nil

  context 'TC06.001 - markRewardSeen - Successful Response' do
    reward_id = nil

    before :all do
      RewardService.mark_reward_seen(caller_id, device_serial, '0', '20', id, title_id)
      xml_response = RewardService.fetch_rewards_by_title(caller_id, device_serial, '0', title_id, '10', '0')
      reward_id = xml_response.xpath('//reward').attr('id').text
    end

    it "Verify 'markRewardSeen' calls successfully" do
      expect(reward_id).to eq(id)
    end
  end

  context 'TC06.003 - markRewardSeen - @value - Empty' do
    value3 = ''

    before :all do
      res = RewardService.mark_reward_seen(caller_id, device_serial, '0', value3, '3572167', '1042')
    end

    it "Verify 'For input string: \"\"' error responses" do
      expect(res).to eq("For input string: \"\"")
    end
  end

  context 'TC06.004 - markRewardSeen - @value - Nonexistence' do
    value4 = 'non-existence'

    before :all do
      res = RewardService.mark_reward_seen(caller_id, device_serial, '0', value4, '3572167', '1042')
    end

    it "Verify 'For input string: \"non-existence\"' error responses" do
      expect(res).to eq("For input string: \"non-existence\"")
    end
  end

  context 'TC06.005 - markRewardSeen - @id - Empty' do
    id5 = ''

    before :all do
      res = RewardService.mark_reward_seen(caller_id, device_serial, '0', '0', id5, '1042')
    end

    it "Verify 'Unmarshalling Error: For input string: \"\"' error responses" do
      expect(res).to eq("Unmarshalling Error: For input string: \"\" ")
    end
  end

  context 'TC06.006 - markRewardSeen - @id - Nonexistence' do
    id6 = '-1234'

    before :all do
      res = RewardService.mark_reward_seen(caller_id, device_serial, '0', '0', id6, '1042')
    end

    it 'Verify soap fault responses' do
      expect('#36342: Web Services: reward-service: markRewardSeen: The services call return successful responses with empty content when calling service with @id, @title-id as invalid value').to eq(res)
    end
  end

  context 'TC06.007 - markRewardSeen - @id - Character' do
    id7 = 'character'

    before :all do
      res = RewardService.mark_reward_seen(caller_id, device_serial, '0', '0', id7, '1042')
    end

    it "Verify 'Unmarshalling Error: For input string: \"character\"' error responses" do
      expect(res).to eq("Unmarshalling Error: For input string: \"character\" ")
    end
  end

  context 'TC06.008 - markRewardSeen - @title-id - Empty' do
    title_id8 = ''

    before :all do
      res = RewardService.mark_reward_seen(caller_id, device_serial, '0', '0', '3572167', title_id8)
    end

    it "Verify 'Unmarshalling Error: For input string: \"\"' error responses" do
      expect(res).to eq("Unmarshalling Error: For input string: \"\" ")
    end
  end

  context 'TC06.009 - markRewardSeen - @title-id - Nonexistence' do
    title_id9 = '-1234'

    before :all do
      res = RewardService.mark_reward_seen(caller_id, device_serial, '0', '0', '3572167', title_id9)
    end

    it 'Verify soap fault responses' do
      expect('#36342: Web Services: reward-service: markRewardSeen: The services call return successful responses with empty content when calling service with @id, @title-id as invalid value').to eq(res)
    end
  end

  context 'TC06.010 - markRewardSeen - @title-id - Character' do
    title_id10 = 'char'

    before :all do
      res = RewardService.mark_reward_seen(caller_id, device_serial, '0', '0', '3572167', title_id10)
    end

    it "Verify 'Unmarshalling Error: For input string: \"char\"' error responses" do
      expect(res).to eq("Unmarshalling Error: For input string: \"char\" ")
    end
  end
end
