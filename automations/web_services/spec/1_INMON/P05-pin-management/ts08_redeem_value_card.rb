require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'owner_management'
require 'device_management'
require 'soft_good_management'
require 'device_profile_management'
require 'pin_management'
require 'automation_common'

=begin
Verify redeemValueCard service works correctly
=end

start_browser

describe "TS08 - redeemValueCard - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:pin_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:pin_management][:namespace]
  client = Savon.client(
    endpoint: endpoint,
    namespace: namespace,
    log: true,
    pretty_print_xml: true,
    namespace_identifier: :man
  )

  cus_id = nil
  device_serial = DeviceManagement.generate_serial
  res = nil
  env = Misc::CONST_ENV
  pin_available = nil
  pin = nil
  pin_status = nil
  status_code_redemption = nil

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

  context 'TC08.001 - redeemValueCard - USV1' do
    before :all do
      # Get PIN value from DB
      pin_available = PinRedemption.get_pin_number(env, 'USV1', 'Available')
      pin = pin_available.gsub('-', '')

      red_val_card_res = client.call(
        :redeem_value_card,
        message:
          "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
          <session type='service'/>
          <cust-key>#{cus_id}</cust-key>
          <pin-text>#{pin}</pin-text>
          <locale>US</locale>
          <references key='accountSuffix' value='USD'/>
          <references key='currency' value='USD'/>
          <references key='locale' value='en_US'/>
          <references key='CUST_KEY' value='#{cus_id}'/>
          <references key='transactionId' value='11223344'/>"
      )

      status_code_redemption = red_val_card_res.http.code
      fet_pin_att_res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, pin)
      pin_status = fet_pin_att_res.xpath('//pins/@status').text
    end

    it 'Verify redeemValueCard method returns code 200' do
      expect(status_code_redemption).to eq(200)
    end

    it 'Verify pin status is "REDEEMED"' do
      expect(pin_status).to eq('REDEEMED')
    end

    it 'Update PIN status to Used' do
      PinRedemption.update_pin_status(env, 'USV1', pin_available, 'Used') if status_code_redemption == 200 && pin_status == 'REDEEMED'
    end
  end

  context 'TC08.002 - redeemValueCard - USV2' do
    before :all do
      # Get PIN value from excel file
      pin_available = PinRedemption.get_pin_number(env, 'USV2', 'Available')
      pin = pin_available.gsub('-', '')

      red_val_card_res = client.call(
        :redeem_value_card,
        message:
          "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
          <session type='service'/>
          <cust-key>#{cus_id}</cust-key>
          <pin-text>#{pin}</pin-text>
          <locale>US</locale>
          <references key='accountSuffix' value='USD'/>
          <references key='currency' value='USD'/>
          <references key='locale' value='en_US'/>
          <references key='CUST_KEY' value='#{cus_id}'/>
          <references key='transactionId' value='11223344'/>"
      )

      status_code_redemption = red_val_card_res.http.code
      fet_pin_att_res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, pin)
      pin_status = fet_pin_att_res.xpath('//pins/@status').text
    end

    it 'Verify redeemValueCard method returns code 200' do
      expect(status_code_redemption).to eq(200)
    end

    it 'Verify pin status is "REDEEMED"' do
      expect(pin_status).to eq('REDEEMED')
    end

    it 'Mark PIN used' do
      PinRedemption.update_pin_status(env, 'USV2', pin_available, 'Used') if status_code_redemption == 200 && pin_status == 'REDEEMED'
    end
  end

  context 'TC08.003 - redeemValueCard - USV3' do
    before :all do
      # Get PIN value from PIN table
      pin_available = PinRedemption.get_pin_number(env, 'USV3', 'Available')
      pin = pin_available.gsub('-', '')

      red_val_card_res = client.call(
        :redeem_value_card,
        message:
          "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
          <session type='service'/>
          <cust-key>#{cus_id}</cust-key>
          <pin-text>#{pin}</pin-text>
          <locale>US</locale>
          <references key='accountSuffix' value='USD'/>
          <references key='currency' value='USD'/>
          <references key='locale' value='en_US'/>
          <references key='CUST_KEY' value='#{cus_id}'/>
          <references key='transactionId' value='11223344'/>"
      )

      status_code_redemption = red_val_card_res.http.code
      fet_pin_att_res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, pin)
      pin_status = fet_pin_att_res.xpath('//pins/@status').text
    end

    it 'Verify redeemValueCard method returns code 200' do
      expect(status_code_redemption).to eq(200)
    end

    it 'Verify pin status is "REDEEMED"' do
      expect(pin_status).to eq('REDEEMED')
    end

    it 'Mark PIN used' do
      PinRedemption.update_pin_status(env, 'USV3', pin_available, 'Used') if status_code_redemption == 200 && pin_status == 'REDEEMED'
    end
  end

  context 'TC08.004 - redeemValueCard - CAV1' do
    before :all do
      # Get PIN value from excel file
      pin_available = PinRedemption.get_pin_number(env, 'CAV1', 'Available')
      pin = pin_available.gsub('-', '')

      red_val_card_res = client.call(
        :redeem_value_card,
        message:
          "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
          <session type='service'/>
          <cust-key>#{cus_id}</cust-key>
          <pin-text>#{pin}</pin-text>
          <locale>CA</locale>
          <references key='accountSuffix' value='USD'/>
          <references key='currency' value='USD'/>
          <references key='locale' value='en_CA'/>
          <references key='CUST_KEY' value='#{cus_id}'/>
          <references key='transactionId' value='11223344'/>"
      )
      status_code_redemption = red_val_card_res.http.code
      fet_pin_att_res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, pin)
      pin_status = fet_pin_att_res.xpath('//pins/@status').text
    end

    it 'Verify redeemValueCard method returns code 200' do
      expect(status_code_redemption).to eq(200)
    end

    it 'Verify pin status is "REDEEMED"' do
      expect(pin_status).to eq('REDEEMED')
    end

    it 'Mark PIN used' do
      PinRedemption.update_pin_status(env, 'CAV1', pin_available, 'Used') if status_code_redemption == 200 && pin_status == 'REDEEMED'
    end
  end

  context 'TC08.005 - redeemValueCard - CAV2' do
    before :all do
      # Get PIN value from DB
      pin_available = PinRedemption.get_pin_number(env, 'CAV2', 'Available')
      pin = pin_available.gsub('-', '')

      red_val_card_res = client.call(
        :redeem_value_card,
        message:
          "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
          <session type='service'/>
          <cust-key>#{cus_id}</cust-key>
          <pin-text>#{pin}</pin-text>
          <locale>CA</locale>
          <references key='accountSuffix' value='USD'/>
          <references key='currency' value='USD'/>
          <references key='locale' value='en_CA'/>
          <references key='CUST_KEY' value='#{cus_id}'/>
          <references key='transactionId' value='11223344'/>"
      )

      status_code_redemption = red_val_card_res.http.code
      fet_pin_att_res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, pin)
      pin_status = fet_pin_att_res.xpath('//pins/@status').text
    end

    it 'Verify redeemValueCard method returns code 200' do
      expect(status_code_redemption).to eq(200)
    end

    it 'Verify pin status is "REDEEMED"' do
      expect(pin_status).to eq('REDEEMED')
    end

    it 'Mark PIN used' do
      PinRedemption.update_pin_status(env, 'CAV2', pin_available, 'Used') if status_code_redemption == 200 && pin_status == 'REDEEMED'
    end
  end

  context 'TC08.006 - redeemValueCard - CAV3' do
    before :all do
      # Get PIN value from PIN table
      pin_available = PinRedemption.get_pin_number(env, 'CAV3', 'Available')
      pin = pin_available.gsub('-', '')

      red_val_card_res = client.call(
        :redeem_value_card,
        message:
          "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
          <session type='service'/>
          <cust-key>#{cus_id}</cust-key>
          <pin-text>#{pin}</pin-text>
          <locale>CA</locale>
          <references key='accountSuffix' value='USD'/>
          <references key='currency' value='USD'/>
          <references key='locale' value='en_CA'/>
          <references key='CUST_KEY' value='#{cus_id}'/>
          <references key='transactionId' value='11223344'/>"
      )

      status_code_redemption = red_val_card_res.http.code
      fet_pin_att_res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, pin)
      pin_status = fet_pin_att_res.xpath('//pins/@status').text
    end

    it 'Verify redeemValueCard method returns code 200' do
      expect(status_code_redemption).to eq(200)
    end

    it 'Verify pin status is "REDEEMED"' do
      expect(pin_status).to eq('REDEEMED')
    end

    it 'Mark PIN used' do
      PinRedemption.update_pin_status(env, 'CAV3', pin_available, 'Used') if status_code_redemption == 200 && pin_status == 'REDEEMED'
    end
  end

  context 'TC08.101 - redeemValueCard - Invalid CallerID' do
    before :all do
      res = PINManagement.redeem_value_card('invalid', cus_id, '7473150924466515')
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC08.102 - redeemValueCard - Invalid Request' do
    before :all do
      res = PINManagement.redeem_value_card(Misc::CONST_CALLER_ID, '', '')
    end

    it 'Verify faultstring is returned: Unable to handle the received request: parentKey is not valid.' do
      expect(res).to eq('Unable to handle the received request: parentKey is not valid.')
    end
  end

  context 'TC08.103 - redeemValueCard - Access Denied' do
    before :all do
      res = PINManagement.redeem_value_card(Misc::CONST_CALLER_ID, '-1111', '7473150924466515')
    end

    it 'Verify faultstring is returned: Unable to handle the received request: parentKey is not valid.' do
      expect(res).to eq('Unable to handle the received request: parentKey is not valid.')
    end
  end

  context 'TC08.104 - redeemValueCard - Redeemed PIN' do
    before :all do
      begin
        client.call(
          :redeem_value_card,
          message:
            "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
            <session type='service'/>
            <cust-key>#{cus_id}</cust-key>
            <pin-text>3646299195524717</pin-text>
            <locale>US</locale>
            <references key='accountSuffix' value='USD'/>
            <references key='currency' value='USD'/>
            <references key='locale' value='en_US'/>
            <references key='CUST_KEY' value='#{cus_id}'/>
            <references key='transactionId' value='11223344'/>"
        )
      rescue Savon::SOAPFault => error
        res = error.to_hash[:fault][:detail][:invalid_pin][:pin_fault][:reason]
      end
    end

    it 'Verify faultstring is returned: redeemed_code' do
      expect(res).to eq('redeemed_code')
    end
  end

  context 'TC08.105 - redeemValueCard - Nonexistent PIN' do
    before :all do
      begin
        client.call(
          :redeem_value_card,
          message:
            "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
            <session type='service'/>
            <cust-key>#{cus_id}</cust-key>
            <pin-text>non-existence</pin-text>
            <locale>US</locale>
            <references key='accountSuffix' value='USD'/>
            <references key='currency' value='USD'/>
            <references key='locale' value='en_US'/>
            <references key='CUST_KEY' value='#{cus_id}'/>
            <references key='transactionId' value='11223344'/>"
        )
      rescue Savon::SOAPFault => error
        res = error.to_hash[:fault][:detail][:invalid_pin][:pin_fault][:reason]
      end
    end

    it 'Verify faultstring is returned: unexistent_code' do
      expect(res).to eq('unexistent_code')
    end
  end

  context 'TC08.106 - redeemValueCard - PIN is empty' do
    before :all do
      begin
        client.call(
          :redeem_value_card,
          message:
            "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
            <session type='service'/>
            <cust-key>#{cus_id}</cust-key>
            <pin-text></pin-text>
            <locale>US</locale>
            <references key='accountSuffix' value='USD'/>
            <references key='currency' value='USD'/>
            <references key='locale' value='en_US'/>
            <references key='CUST_KEY' value='#{cus_id}'/>
            <references key='transactionId' value='11223344'/>"
        )
      rescue Savon::SOAPFault => error
        res = error.to_hash[:fault][:detail][:invalid_pin][:pin_fault][:reason]
      end
    end

    it 'Verify faultstring is returned: unexistent_code' do
      expect(res).to eq('unexistent_code')
    end
  end

  context 'TC08.107 - redeemValueCard - PIN is so long' do
    before :all do
      begin
        client.call(
          :redeem_value_card,
          message:
            "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
            <session type='service'/>
            <cust-key>#{cus_id}</cust-key>
            <pin-text>123456789456123654789651336554</pin-text>
            <locale>US</locale>
            <references key='accountSuffix' value='USD'/>
            <references key='currency' value='USD'/>
            <references key='locale' value='en_US'/>
            <references key='CUST_KEY' value='#{cus_id}'/>
            <references key='transactionId' value='11223344'/>"
        )
      rescue Savon::SOAPFault => error
        res = error.to_hash[:fault][:detail][:invalid_pin][:pin_fault][:reason]
      end
    end

    it 'Verify faultstring is returned: unexistent_code' do
      expect(res).to eq('unexistent_code')
    end
  end

  context 'TC08.108 - redeemValueCard - PIN is negative numbers' do
    before :all do
      begin
        client.call(
          :redeem_value_card,
          message:
            "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
            <session type='service'/>
            <cust-key>#{cus_id}</cust-key>
            <pin-text>-12346549879413465465</pin-text>
            <locale>US</locale>
            <references key='accountSuffix' value='USD'/>
            <references key='currency' value='USD'/>
            <references key='locale' value='en_US'/>
            <references key='CUST_KEY' value='#{cus_id}'/>
            <references key='transactionId' value='11223344'/>"
        )
      rescue Savon::SOAPFault => error
        res = error.to_hash[:fault][:detail][:invalid_pin][:pin_fault][:reason]
      end
    end

    it 'Verify faultstring is returned: unexistent_code' do
      expect(res).to eq('unexistent_code')
    end
  end

  context 'TC08.109 - redeemValueCard - PIN contains special characters' do
    before :all do
      begin
        client.call(
          :redeem_value_card,
          message:
            "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
            <session type='service'/>
            <cust-key>#{cus_id}</cust-key>
            <pin-text>!@$%^^</pin-text>
            <locale>US</locale>
            <references key='accountSuffix' value='USD'/>
            <references key='currency' value='USD'/>
            <references key='locale' value='en_US'/>
            <references key='CUST_KEY' value='#{cus_id}'/>
            <references key='transactionId' value='11223344'/>"
        )
      rescue Savon::SOAPFault => error
        res = error.to_hash[:fault][:detail][:invalid_pin][:pin_fault][:reason]
      end
    end

    it 'Verify faultstring is returned: unexistent_code' do
      expect(res).to eq('unexistent_code')
    end
  end

  context 'TC08.110 - redeemValueCard - No references' do
    before :all do
      begin
        client.call(
          :redeem_value_card,
          message:
            "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
            <session type='service'/>
            <cust-key>#{cus_id}</cust-key>
            <pin-text>7473150924466515</pin-text>
            <locale>US</locale>"
        )
      rescue Savon::SOAPFault => error
        res = error.to_hash[:fault][:faultstring]
      end
    end

    it "Verify faultstring is returned: 'The given pin was invalid: redeemed'" do
      expect(res).to eq('The given pin was invalid: redeemed')
    end
  end
end
