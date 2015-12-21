require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'owner_management'
require 'device_management'
require 'soft_good_management'
require 'device_profile_management'
require 'pin_management'

=begin
Verify revokePins service works correctly
=end

start_browser

describe "TS09 - revokePins - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:pin_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:pin_management][:namespace]
  caller_id = Misc::CONST_CALLER_ID
  device_serial = DeviceManagement.generate_serial
  cus_id = nil
  pin = nil
  revoke_pin_res = nil
  fetch_pin_res = nil

  it 'Pre-Condition' do
    reg_cus_response = CustomerManagement.register_customer(caller_id, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    cus_id = cus_info[:id]

    session = Authentication.get_service_session(caller_id, cus_info[:username], cus_info[:password])
    reg_chi_response = ChildManagement.register_child(caller_id, session, cus_id)
    child_id = reg_chi_response.xpath('//child/@id').text

    OwnerManagement.claim_device(caller_id, session, cus_id, device_serial, 'leappad', '0', 'profile', child_id)
    DeviceProfileManagement.assign_device_profile(caller_id, cus_id, device_serial, 'leappad', '0', 'profile', child_id)
    DeviceManagement.update_profiles(caller_id, session, 'service', device_serial, 'leappad', '0', 'profile', child_id)
    LFCommon.new.login_to_lfcom(cus_info[:username], cus_info[:password])
  end

  context 'TC09.001.1 - revokePins - 1 Pin Successful Response' do
    before :all do
      sof_goo_res = SoftGoodManagement.reserve_gift_pin caller_id
      pin = sof_goo_res.xpath('//reserved-pin').text

      SoftGoodManagement.purchase_gift_pin(caller_id, cus_id, pin)
      revoke_pin_res = PINManagement.revoke_pins(caller_id, pin)
      fetch_pin_res = PINManagement.fetch_pin_attributes(caller_id, pin)
    end

    it 'Match content of [@pin]' do
      expect(fetch_pin_res.xpath('//pins/@pin').text).to eq(pin)
    end

    it 'Match content of [@status]' do
      expect(fetch_pin_res.xpath('//pins/@status').text).to eq('DEACTIVATED')
    end
  end

  context 'TC09.001.2 - revokePins - 2 Pins Successful Response' do
    fetch_pin_res1 = fetch_pin_res2 = nil
    pin1 = pin2 = nil

    before :all do
      sof_goo_res1 = SoftGoodManagement.reserve_gift_pin caller_id
      pin1 = sof_goo_res1.xpath('//reserved-pin').text

      SoftGoodManagement.purchase_gift_pin(caller_id, cus_id, pin1)
      sof_goo_res2 = SoftGoodManagement.reserve_gift_pin caller_id
      pin2 = sof_goo_res2.xpath('//reserved-pin').text

      SoftGoodManagement.purchase_gift_pin(caller_id, cus_id, pin2)

      revoke_pin_res = LFCommon.soap_call(
        endpoint,
        namespace,
        :revoke_pins,
        "<caller-id>#{caller_id}</caller-id>
        <session type='service'/>
        <cust-key/>
        <pin-text/>
        <pin-text/>
        <pin-text/>
        <pin-text>#{pin1}</pin-text>
        <pin-text>#{pin2}</pin-text>"
      )

      # fetchPinAttributes - validate revokePins - 1st
      fetch_pin_res1 = PINManagement.fetch_pin_attributes(caller_id, pin1)

      # fetchPinAttributes - validate revokePins - 2nd
      fetch_pin_res2 = PINManagement.fetch_pin_attributes(caller_id, pin2)
    end

    it 'Match content of [@pin] - 1' do
      expect(fetch_pin_res1.xpath('//pins/@pin').text).to eq(pin1)
    end

    it 'Match content of [@status] - 1' do
      expect(fetch_pin_res1.xpath('//pins/@status').text).to eq('DEACTIVATED')
    end

    it 'Match content of [@pin] - 2' do
      expect(fetch_pin_res2.xpath('//pins/@pin').text).to eq(pin2)
    end

    it 'Match content of [@status] - 2' do
      expect(fetch_pin_res2.xpath('//pins/@status').text).to eq('DEACTIVATED')
    end
  end

  context 'TC09.002 - revokePins - Invalid CallerID' do
    caller_id3 = 'invalid'

    before :all do
      revoke_pin_res = PINManagement.revoke_pins(caller_id3, '6453483674098519')
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(revoke_pin_res).to eq('Error while checking caller id')
    end
  end

  context 'TC09.005 - revokePins - Revoke deactived pin' do
    pin5 = '1645344007819213'

    before :all do
      PINManagement.revoke_pins(caller_id, pin5)
      fetch_pin_res = PINManagement.fetch_pin_attributes(caller_id, pin5)
    end

    it 'Match content of [@pin]' do
      expect(fetch_pin_res.xpath('//pins/@pin').text).to eq(pin5)
    end

    it 'Match content of [@status]' do
      expect(fetch_pin_res.xpath('//pins/@status').text).to eq('DEACTIVATED')
    end
  end

  context 'TC09.006 - revokePins - Pin-text is null' do
    it 'Report bug' do
      revoke_pin_res = PINManagement.revoke_pins(caller_id, '')
      expect('#36324: Web Services: pin-management: revokePins: The service return successful response with empty content when revoke invalid PIN text').to eq(revoke_pin_res)
    end
  end

  context 'TC09.007 - revokePins - Pin-text is so long' do
    it 'Report bug' do
      pin7 = 'The next big thing, but also the next thing We have started development on the next big release, with more REST testing improvements. We have reinforced the team, and now we are splitting it into two: a smaller team focused on 4.6.2 and a larger team focusing on the next big release'
      revoke_pin_res = PINManagement.revoke_pins(caller_id, pin7)
      expect('#36324: Web Services: pin-management: revokePins: The service return successful response with empty content when revoke invalid PIN text').to eq(revoke_pin_res)
    end
  end

  context 'TC09.008 - revokePins - Pin-text is special characters' do
    it 'Report bug' do
      revoke_pin_res = PINManagement.revoke_pins(caller_id, '$@$@$@')
      expect('#36324: Web Services: pin-management: revokePins: The service return successful response with empty content when revoke invalid PIN text').to eq(revoke_pin_res)
    end
  end

  context 'TC09.009 - revokePins - Pin-text is negative numbers' do
    it 'Report bug' do
      revoke_pin_res = PINManagement.revoke_pins(caller_id, '-1645344007819213')
      expect('#36324: Web Services: pin-management: revokePins: The service return successful response with empty content when revoke invalid PIN text').to eq(revoke_pin_res)
    end
  end
end
