require File.expand_path('../../spec_helper', __FILE__)
require 'authentication'
require 'child_management'
require 'customer_management'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'
require 'device_log_upload'
require 'device_profile_content'
require 'pin_management'
require 'automation_common'

=begin
Smoke test 01: redeem and upload functions devices: RIO, LPAD2, LGS, LR and MP
=end

start_browser

def device_log_and_content_upload(caller_id, serial, child_id, session, device_name)
  device_log = res = nil

  before :all do
    content_path = "#{Misc::CONST_PROJECT_PATH}/data/Log2.xml"
    profile_content = package_id = 'SCPL-001300010001055B-20090325T130552800.lfp'
    filename = 'Stretchy monkey.log'
    slot = 0

    # Upload Device/Game log
    DeviceLogUpload.upload_device_log(caller_id, 'Jewel_Train_2.log', slot, serial, '2013-11-11T00:00:00', 'jeweltrain2.bin')
    DeviceLogUpload.upload_game_log(caller_id, child_id, '2013-11-11T00:00:00', filename, content_path)

    # Get Child Upload History - After Upload Game Log
    xml_fetch_upload = ChildManagement.fetch_child_upload_history(caller_id, 'service', session, child_id)
    device_log = xml_fetch_upload.xpath('//device-log').count

    # Upload Content
    res = DeviceProfileContent.upload_content_wo_handle_exception(caller_id, session, serial, slot, package_id, profile_content)
  end

  it 'Check for existence of [device-log] - ' + device_name do
    expect(device_log).not_to eq(0)
  end

  it "Verify 'uploadContent' calls successfully - " + device_name + ' - status code 200' do
    expect(res.http.code).to eq(200)
  end
end

describe "TestSuite 01 - Smoke test 01 - Redeem - Upload - #{Misc::CONST_ENV}" do
  env = Misc::CONST_ENV
  caller_id = Misc::CONST_CALLER_ID
  serial_rio = 'RIO' + DeviceManagement.generate_serial
  serial_lp2 = 'LP2' + DeviceManagement.generate_serial
  serial_lgs = 'LGS' + DeviceManagement.generate_serial
  serial_lr = 'LR' + DeviceManagement.generate_serial
  serial_mp = 'MP' + DeviceManagement.generate_serial
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  customer_id = session = nil
  rio_child = lp2_child = lgs_child = lr_child = mp_child = nil

  context 'Test Case 01 - Account Setup' do
    # Step 1: Register Parent Account
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    type1 = register_cus_res.xpath('//customer').attr('type').text
    username1 = register_cus_res.xpath('//customer/credentials').attr('username').text

    # Step 2: Login Parent account
    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    # Step 3: Create RIO Child
    xml_register_child_rio = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'RIOKid', 'male', '1')
    rio_child = ChildManagement.register_child_info xml_register_child_rio

    # Step 4: Create Leapad2 Child
    xml_register_child_lp2 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'LP2Kid', 'female', '1')
    lp2_child = ChildManagement.register_child_info xml_register_child_lp2

    # Step 5: Create Leapster GS Child
    xml_register_child_lgs = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'LGSKid', 'female', '3')
    lgs_child = ChildManagement.register_child_info xml_register_child_lgs

    # Step 6: Create LeapReader Child
    xml_register_child_lr = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'LRKid', 'male', '2')
    lr_child = ChildManagement.register_child_info xml_register_child_lr

    # Step 7: Create MyPals Child
    xml_register_child_mp = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'MypalsKid', 'female', '1')
    mp_child = ChildManagement.register_child_info xml_register_child_mp

    it 'Match content of [@type]' do
      expect(type1).to eq('Registered')
    end

    it 'Match content of [@username]' do
      expect(username1).to eq(username)
    end

    it 'Check for existence of [session]' do
      expect(session).not_to be_empty
    end

    it 'Match content of [@name] - RIO' do
      expect(rio_child[:child_name]).to eq('RIOKid')
    end

    it 'Match content of [@gender] - RIO' do
      expect(rio_child[:gender]).to eq('male')
    end

    it 'Match content of [@grade] - RIO' do
      expect(rio_child[:grade]).to eq('1')
    end

    it 'Match content of [@name] - Leapad2' do
      expect(lp2_child[:child_name]).to eq('LP2Kid')
    end

    it 'Match content of [@gender] - Leapad2' do
      expect(lp2_child[:gender]).to eq('female')
    end

    it 'Match content of [@grade] - Leapad2' do
      expect(lp2_child[:grade]).to eq('1')
    end

    it 'Match content of [@name] - Leapster GS' do
      expect(lgs_child[:child_name]).to eq('LGSKid')
    end

    it 'Match content of [@gender] - Leapster GS' do
      expect(lgs_child[:gender]).to eq('female')
    end

    it 'Match content of [@grade] - Leapster GS' do
      expect(lgs_child[:grade]).to eq('3')
    end

    it 'Match content of [@name] - LeapReader' do
      expect(lr_child[:child_name]).to eq('LRKid')
    end

    it 'Match content of [@gender] - LeapReader' do
      expect(lr_child[:gender]).to eq('male')
    end

    it 'Match content of [@grade] - LeapReader' do
      expect(lr_child[:grade]).to eq('2')
    end

    it 'Match content of [@name] - Mypals' do
      expect(mp_child[:child_name]).to eq('MypalsKid')
    end

    it 'Match content of [@gender] - Mypals' do
      expect(mp_child[:gender]).to eq('female')
    end

    it 'Match content of [@grade] - Mypals' do
      expect(mp_child[:grade]).to eq('1')
    end
  end

  context 'Test Case 02 - Claim Devices' do
    # Step 1: Claim RIO device
    OwnerManagement.claim_device(caller_id, session, customer_id, serial_rio, 'leappad3', '0', 'RIOKid', '04444454')

    # listNominatedDevices and get device serials value
    xml_list_nominated_devices_res = DeviceManagement.list_nominated_devices(caller_id, session, 'service')
    serial1 = xml_list_nominated_devices_res.xpath('//device[1]').attr('serial').text
    platform1 = xml_list_nominated_devices_res.xpath('//device[1]').attr('platform').text

    # Step 2: Claim Leapad2 device
    xml_claim_device_lp2 = OwnerManagement.claim_device(caller_id, session, customer_id, serial_lp2, 'leappad2', '0', 'LP2Kid', '04444454')
    claim_device_lp2 = OwnerManagement.claim_device_info xml_claim_device_lp2

    # Step 3: Claim LGS device
    xml_claim_device_lgs = OwnerManagement.claim_device(caller_id, session, customer_id, serial_lgs, 'explorer2', '0', 'LGSKid', '04444454')
    claim_device_lgs = OwnerManagement.claim_device_info xml_claim_device_lgs

    # Step 4: Claim LeapReader device
    xml_claim_device_lr = OwnerManagement.claim_device(caller_id, session, customer_id, serial_lr, 'leapreader', '0', 'LRKid', '04444454')
    claim_device_lr = OwnerManagement.claim_device_info xml_claim_device_lr

    # Step 5: Claim MyPals device
    xml_claim_device_mp = OwnerManagement.claim_device(caller_id, session, customer_id, serial_mp, 'mypals', '0', 'MyPalKid', '04444454')
    claim_device_mp = OwnerManagement.claim_device_info xml_claim_device_mp

    # Step 6: Assign Device Profiles
    xml_assign_device = LFCommon.soap_call(
      LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_management][:endpoint],
      LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_management][:namespace],
      :assign_device_profile,
      "<device-profile device='#{serial_rio}' platform='leappad3' slot='0' name='RIOKid' child-id='#{rio_child[:child_id]}'/>
      <device-profile device='#{serial_lp2}' platform='leappad2' slot='0' name='LP2Kid' child-id='#{lp2_child[:child_id]}'/>
      <device-profile device='#{serial_lgs}' platform='explorer2' slot='0' name='LGSKid' child-id='#{lgs_child[:child_id]}'/>
      <device-profile device='#{serial_lr}' platform='leapreader' slot='0' name='LRKid' child-id='#{lr_child[:child_id]}'/>
      <device-profile device='#{serial_mp}' platform='mypals' slot='0' name='MyPalKid' child-id='#{mp_child[:child_id]}'/>
      <caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id>#{customer_id}</customer-id>"
    )

    soap_fault = xml_assign_device.xpath('//faultstring').count

    # Step 7: Get Device Profiles
    xml_get_device_profile = DeviceProfileManagement.list_device_profiles(caller_id, username, customer_id, '10', '10', '')
    profile_num = xml_get_device_profile.xpath('//device-profile').count

    it 'Match content of [@serial] - RIO' do
      expect(serial1).to eq(serial_rio)
    end

    it 'Match content of [@platform] - RIO' do
      expect(platform1).to eq('leappad3')
    end

    it 'Match content of [@serial] - Leapad2' do
      expect(claim_device_lp2[:device_serial]).to eq(serial_lp2)
    end

    it 'Match content of [@platform] - Leapad2' do
      expect(claim_device_lp2[:platform]).to eq('leappad2')
    end

    it 'Match content of [@serial] - Leapster GS' do
      expect(claim_device_lgs[:device_serial]).to eq(serial_lgs)
    end

    it 'Match content of [@platform] - Leapster GS' do
      expect(claim_device_lgs[:platform]).to eq('explorer2')
    end

    it 'Match content of [@serial] - LeapReader' do
      expect(claim_device_lr[:device_serial]).to eq(serial_lr)
    end

    it 'Match content of [@platform] - LeapReader' do
      expect(claim_device_lr[:platform]).to eq('leapreader')
    end

    it 'Match content of [@serial] - Mypals' do
      expect(claim_device_mp[:device_serial]).to eq(serial_mp)
    end

    it 'Match content of [@platform] - Mypals' do
      expect(claim_device_mp[:platform]).to eq('mypals')
    end

    it "Verify 'assignDeviceProfiles' calls successfully" do
      expect(soap_fault).to eq(0)
    end

    it 'Check count of [device-profile]' do
      expect(profile_num).to eq(5)
    end
  end

  context 'Test Case 03 - Redeem - USV1 PIN' do
    status_code_redemption = pin_value = pin = pin_status = pin_available = nil

    before :all do
      # Make account known to vindica system
      LFCommon.new.login_to_lfcom(username, password)

      # Get available PIN
      pin_available = PinRedemption.get_pin_number(env, 'USV1', 'Available')
      pin = pin_available.delete('-')

      begin
        # Step 1: Redeem USV1 Code
        client = Savon.client(
          endpoint: LFSOAP::CONST_INMON_ENDPOINTS[:pin_management][:endpoint],
          namespace: LFSOAP::CONST_INMON_ENDPOINTS[:pin_management][:namespace],
          log: true,
          pretty_print_xml: true,
          namespace_identifier: :man
        )

        red_val_card_res = client.call(
          :redeem_value_card,
          message:
            "<caller-id>#{caller_id}</caller-id>
            <session type='service'/>
            <cust-key>#{customer_id}</cust-key>
            <pin-text>#{pin}</pin-text>
            <locale>US</locale>
            <references key='accountSuffix' value='USD'/>
            <references key='currency' value='USD'/>
            <references key='locale' value='en_US'/>
            <references key='CUST_KEY' value='#{customer_id}'/>
            <references key='transactionId' value='11223344'/>"
        )
        status_code_redemption = red_val_card_res.http.code
      rescue => e
        status_code_redemption = e
      end

      # Step 2: Get Pin Attributes
      fet_pin_att_res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, pin)
      pin_status = fet_pin_att_res.xpath('//pins/@status').text
      pin_value = fet_pin_att_res.xpath('//pins/@pin').text
    end

    it "Verify 'redeemValueCard' calls successfully" do
      expect(status_code_redemption).to eq(200)
    end

    it 'Match content of [@pin]' do
      expect(pin_value).to eq(pin)
    end

    it "Match content of [@status] = 'REDEEMED'" do
      expect(pin_status).to eq('REDEEMED')
    end

    it 'Update PIN status to Used' do
      PinRedemption.update_pin_status(env, 'USV1', pin_available, 'Used') if status_code_redemption == 200 && pin_status == 'REDEEMED'
    end
  end

  context 'Test Case 04 - Device Log & Content Upload - RIO' do
    device_log_and_content_upload(caller_id, serial_rio, rio_child[:child_id], session, 'RIO')
  end

  context 'Test Case 05 - Device Log & Content Upload - LP2' do
    device_log_and_content_upload(caller_id, serial_lp2, lp2_child[:child_id], session, 'LP2')
  end

  context 'Test Case 06 - Device Log & Content Upload - LGS' do
    device_log_and_content_upload(caller_id, serial_lgs, lgs_child[:child_id], session, 'LGS')
  end

  context 'Test Case 07 - Device Log & Content Upload - LR' do
    device_log_and_content_upload(caller_id, serial_lr, lr_child[:child_id], session, 'LR')
  end

  context 'Test Case 08 - Device Log & Content Upload - MyPal' do
    device_log_and_content_upload(caller_id, serial_mp, mp_child[:child_id], session, 'MyPal')
  end
end
