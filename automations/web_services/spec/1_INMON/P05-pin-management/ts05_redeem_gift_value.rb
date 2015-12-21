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
Verify redeemGiftValue service works correctly
=end

start_browser

describe "TS04 - redeemGiftValue - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:pin_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:pin_management][:namespace]
  session = nil
  cus_id = nil
  device_serial = DeviceManagement.generate_serial
  pin = nil
  res = nil

  before :all do
    reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    cus_id = cus_info[:id]

    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])

    reg_chi_response = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_id)
    child_id = reg_chi_response.xpath('//child/@id').text

    OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_id, device_serial, 'leappad', '0', 'profile', child_id)
    DeviceProfileManagement.assign_device_profile(Misc::CONST_CALLER_ID, cus_id, device_serial, 'leappad', '0', 'profile', child_id)
    DeviceManagement.update_profiles(Misc::CONST_CALLER_ID, session, 'service', device_serial, 'leappad', '0', 'profile', child_id)
    LFCommon.new.login_to_lfcom(cus_info[:username], cus_info[:password])
  end

  context 'TC05.001 - redeemGiftValue - Successful Response' do
    before :all do
      sof_goo_res = SoftGoodManagement.reserve_gift_pin Misc::CONST_CALLER_ID
      pin = sof_goo_res.xpath('//reserved-pin').text

      SoftGoodManagement.purchase_gift_pin(Misc::CONST_CALLER_ID, cus_id, pin)

      client = Savon.client(
        endpoint: endpoint,
        namespace: namespace,
        log: true,
        pretty_print_xml: true,
        namespace_identifier: :man
      )

      res = client.call(
        :redeem_gift_value,
        message:
          "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
          <session type='service'/>
          <cust-key>#{cus_id}</cust-key>
          <pin-text>#{pin}</pin-text>
          <locale>US</locale><references key='accountSuffix' value='USD'/>
          <references key='currency' value='USD'/>
          <references key='transactionId' value='LFGQSR#{LFCommon.get_current_time}'/>"
      )
    end

    it 'Verify response status is 200' do
      expect(res.http.code).to eq(200)
    end
  end

  context 'TC05.002 - redeemGiftValue - Invalid CallerID' do
    before :all do
      res = PINManagement.redeem_gift_value('invalid', cus_id, pin)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC05.003 - redeemGiftValue - Invalid Request' do
    before :all do
      res = PINManagement.redeem_gift_value(Misc::CONST_CALLER_ID, cus_id, '')
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC05.004 - redeemGiftValue - Access Denied' do
    before :all do
      res = PINManagement.redeem_gift_value(Misc::CONST_CALLER_ID, '11', pin)
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC05.005 - redeemGiftValue - Redeemed PIN' do
    before :all do
      res = PINManagement.redeem_gift_value(Misc::CONST_CALLER_ID, cus_id, pin)
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC05.006 - redeemGiftValue - Pin is not purchase' do
    pin_text = nil

    before :all do
      sof_goo_res = SoftGoodManagement.reserve_gift_pin Misc::CONST_CALLER_ID
      pin_text = sof_goo_res.xpath('//reserved-pin').text

      res = PINManagement.redeem_gift_value(Misc::CONST_CALLER_ID, cus_id, pin_text)
    end

    it 'Verify faultstring is returned' do
      expect(res).to eq("Invalid gift pin \"#{pin_text}\" - not redeemed")
    end
  end

  context 'TC05.007 - redeemGiftValue - Pin is negative numbers' do
    before :all do
      res = PINManagement.redeem_gift_value(Misc::CONST_CALLER_ID, cus_id, '-11111')
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC05.008 - redeemGiftValue - Pin is so long' do
    before :all do
      res = PINManagement.redeem_gift_value(Misc::CONST_CALLER_ID, cus_id, '2232132121321321321321321321321321321')
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC05.009 - redeemGiftValue - Pin is special characters' do
    before :all do
      res = PINManagement.redeem_gift_value(Misc::CONST_CALLER_ID, cus_id, '@#$%')
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC05.010 - redeemGiftValue - No references' do
    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :redeem_gift_value,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'/>
        <cust-key>#{cus_id}</cust-key>
        <pin-text>1111111111111111</pin-text>
        <locale>US</locale>"
      )
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end
end
