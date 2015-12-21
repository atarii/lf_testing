require File.expand_path('../../spec_helper', __FILE__)
require 'authentication'
require 'child_management'
require 'customer_management'
require 'child_management'
require 'learning_path/child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'
require 'device_log_upload'
require 'device_profile_content'
require 'pin_management'
require 'child_management'
require 'automation_common'

=begin
Smoke test: redeem, upload function by using REST
=end

start_browser

describe "TestSuite 03 - Smoke test 03 - #{Misc::CONST_ENV}" do
  env = Misc::CONST_ENV
  caller_id = 'a023bc85-db5b-40b5-934c-28a72b4d9547'
  device_serial1 = 'RIO' + DeviceManagement.generate_serial
  device_serial2 = 'LP2' + DeviceManagement.generate_serial
  device_serial3 = 'LR' + DeviceManagement.generate_serial
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  customer_id = session = nil
  rio_child = lp2_child = lr_child = nil

  filename = 'Stretchy monkey.log'
  content_path = "#{Misc::CONST_PROJECT_PATH}/data/Log2.xml"

  context 'Test Case 01 - Account Setup' do
    type1 = username1 = nil

    before :all do
      # Step 1: Register Parent Account
      register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)

      # Get Customer ID
      arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
      customer_id = arr_register_cus_res[:id]

      # Get type/username
      type1 = register_cus_res.xpath('//customer').attr('type').text
      username1 = register_cus_res.xpath('//customer/credentials').attr('username').text

      # Step 2: Login Parent
      xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
      session = xml_acquire_session_res.xpath('//session').text
    end

    it 'Match content of [@type]' do
      expect(type1).to eq('Registered')
    end

    it 'Match content of [@username]' do
      expect(username1).to eq(username)
    end

    it 'Check for existence of [session]' do
      expect(session).not_to be_empty
    end
  end

  context 'Test Case 02 - Register Child' do
    before :all do
      # Step 1: Create RIO Child
      xml_register_child_rio = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'RIOKid', 'male', '5')
      rio_child = ChildManagement.register_child_info xml_register_child_rio

      # Step 2: Create LeapPad2 Child
      xml_register_child_lp2 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'LP2Kid', 'female', '1')
      lp2_child = ChildManagement.register_child_info xml_register_child_lp2

      # Step 3: Create LeapReader Child
      xml_register_child_lr = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'LRKid', 'male', '2')
      lr_child = ChildManagement.register_child_info xml_register_child_lr
    end

    it 'Match content of [@name] - RIO' do
      expect(rio_child[:child_name]).to eq('RIOKid')
    end

    it 'Match content of [@grade] - RIO' do
      expect(rio_child[:grade]).to eq('5')
    end

    it 'Match content of [@gender] - RIO' do
      expect(rio_child[:gender]).to eq('male')
    end

    it 'Match content of [@name] - LeapPad2' do
      expect(lp2_child[:child_name]).to eq('LP2Kid')
    end

    it 'Match content of [@grade] - LeapPad2' do
      expect(lp2_child[:grade]).to eq('1')
    end

    it 'Match content of [@gender] - LeapPad2' do
      expect(lp2_child[:gender]).to eq('female')
    end

    it 'Match content of [@name] - LeapReader' do
      expect(lr_child[:child_name]).to eq('LRKid')
    end

    it 'Match content of [@grade] - LeapReader' do
      expect(lr_child[:grade]).to eq('2')
    end

    it 'Match content of [@gender] - LeapReader' do
      expect(lr_child[:gender]).to eq('male')
    end
  end

  context 'Test Case 03 - Get Child Information' do
    fetch_child_rio = fetch_child_lp2 = fetch_child_lr = nil

    before :all do
      # Step 1: Get Info RIO Child
      xml_fetch_child_rio = ChildManagement.fetch_child(caller_id, session, rio_child[:child_id])
      fetch_child_rio = ChildManagement.fetch_child_info xml_fetch_child_rio

      # Step 2: Get Info LeapPad2 Child
      xml_fetch_child_lp2 = ChildManagement.fetch_child(caller_id, session, lp2_child[:child_id])
      fetch_child_lp2 = ChildManagement.fetch_child_info xml_fetch_child_lp2

      # Step 3: Get Info LeapReader Child
      xml_fetch_child_lr = ChildManagement.fetch_child(caller_id, session, lr_child[:child_id])
      fetch_child_lr = ChildManagement.fetch_child_info xml_fetch_child_lr
    end

    it 'Match content of [@id] - RIO' do
      expect(fetch_child_rio[:child_id]).to eq(rio_child[:child_id])
    end

    it 'Match content of [@name] - RIO' do
      expect(fetch_child_rio[:child_name]).to eq('RIOKid')
    end

    it 'Check for existence of [@gender] - RIO]' do
      expect(fetch_child_rio[:gender]).to eq('male')
    end

    it 'Match content of [@grade] - RIO' do
      expect(fetch_child_rio[:grade]).to eq('5')
    end

    it 'Match content of [@locale] - RIO' do
      expect(fetch_child_rio[:locale]).to eq('en_US')
    end

    it 'Match content of [@id] - LeapPad2' do
      expect(fetch_child_lp2[:child_id]).to eq(lp2_child[:child_id])
    end

    it 'Match content of [@name] - LeapPad2' do
      expect(fetch_child_lp2[:child_name]).to eq('LP2Kid')
    end

    it 'Check for existence of [@gender] - LeapPad2]' do
      expect(fetch_child_lp2[:gender]).to eq('female')
    end

    it 'Match content of [@grade] - LeapPad2' do
      expect(fetch_child_lp2[:grade]).to eq('1')
    end

    it 'Match content of [@locale] - LeapPad2' do
      expect(fetch_child_lp2[:locale]).to eq('en_US')
    end

    it 'Match content of [@id] - LeapReader' do
      expect(fetch_child_lr[:child_id]).to eq(lr_child[:child_id])
    end

    it 'Match content of [@name] - LeapReader' do
      expect(fetch_child_lr[:child_name]).to eq('LRKid')
    end

    it 'Check for existence of [@gender] - LeapReader]' do
      expect(fetch_child_lr[:gender]).to eq('male')
    end

    it 'Match content of [@grade] - LeapReader' do
      expect(fetch_child_lr[:grade]).to eq('2')
    end

    it 'Match content of [@locale] - LeapReader' do
      expect(fetch_child_lr[:locale]).to eq('en_US')
    end
  end

  context 'Test Case 04 - Claim Devices' do
    serial1 = serial2 = serial3 = platform1 = platform2 = platform3 = soap_fault = profile_num = nil

    before :all do
      # Step 1: Claim RIO device
      OwnerManagement.claim_device(caller_id, session, customer_id, device_serial1, 'leappad3', '0', 'RIOKid', '04444454')

      # listNominatedDevices and get device serials value
      xml_list_nominated_devices_res = DeviceManagement.list_nominated_devices(caller_id, session, 'service')
      serial1 = xml_list_nominated_devices_res.xpath('//device[1]').attr('serial').text
      platform1 = xml_list_nominated_devices_res.xpath('//device[1]').attr('platform').text

      # Step 2: Claim LP2
      OwnerManagement.claim_device(caller_id, session, customer_id, device_serial2, 'leappad2', '0', 'LP2Kid', '04444454')

      # listNominatedDevices and get device serials value
      xml_list_nominated_devices_res = DeviceManagement.list_nominated_devices(caller_id, session, 'service')
      serial2 = xml_list_nominated_devices_res.xpath('//device[2]').attr('serial').text
      platform2 = xml_list_nominated_devices_res.xpath('//device[2]').attr('platform').text

      # Step 3: Claim LR
      OwnerManagement.claim_device(caller_id, session, customer_id, device_serial3, 'leapreader', '0', 'LRKid', '04444454')

      # listNominatedDevices and get device serials value
      xml_list_nominated_devices_res = DeviceManagement.list_nominated_devices(caller_id, session, 'service')
      serial3 = xml_list_nominated_devices_res.xpath('//device[3]').attr('serial').text
      platform3 = xml_list_nominated_devices_res.xpath('//device[3]').attr('platform').text

      # Step 4: Assign Device Profiles
      xml_assign_device = LFCommon.soap_call(
        LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_management][:endpoint],
        LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_management][:namespace],
        :assign_device_profile,
        "<device-profile device='#{device_serial1}' platform='leappad3' slot='0' name='RIOKid' child-id='#{rio_child[:child_id]}'/>
        <device-profile device='#{device_serial2}' platform='leappad2' slot='0' name='LP2Kid' child-id='#{lp2_child[:child_id]}'/>
        <device-profile device='#{device_serial3}' platform='leapreader' slot='0' name='LRKid' child-id='#{lr_child[:child_id]}'/>
        <caller-id>#{caller_id}</caller-id>
        <username/>
        <customer-id>#{customer_id}</customer-id>"
      )

      soap_fault = xml_assign_device.xpath('//faultstring').count

      # Step 5: Get Device Profiles
      xml_get_device_profile = DeviceProfileManagement.list_device_profiles(caller_id, username, customer_id, '10', '10', '')
      profile_num = xml_get_device_profile.xpath('//device-profile').count
    end

    it 'Match content of [@serial] - RIO' do
      expect(serial1).to eq(device_serial1)
    end

    it 'Match content of [@platform] - RIO' do
      expect(platform1).to eq('leappad3')
    end

    it 'Match content of [@serial] - LeapPad2' do
      expect(serial2).to eq(device_serial2)
    end

    it 'Match content of [@platform] - LeapPad2' do
      expect(platform2).to eq('leappad2')
    end

    it 'Match content of [@serial] - LeapReader' do
      expect(serial3).to eq(device_serial3)
    end

    it 'Match content of [@platform] - LeapReader' do
      expect(platform3).to eq('leapreader')
    end

    it "Verify 'Assign Device Profiles' calls successfully" do
      expect(soap_fault).to eq(0)
    end

    it 'Check count of [device-profile]' do
      expect(profile_num).to eq(3)
    end
  end

  context 'Test Case 05 - Claim USV1 PIN' do
    status_code_redemption = pin_value = pin_status = pin_available = pin = nil

    before :all do
      # Make account known to vindica system
      LFCommon.new.login_to_lfcom(username, password)

      # Get available PIN
      pin_available = PinRedemption.get_pin_number(env, 'USV1', 'Available')
      pin = pin_available.delete('-')

      # Step 1: Redeem USV1 Code
      begin
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

  context 'Test Case 06 - Upload Logs' do
    device_log1 = device_log2 = device_log3 = nil
    xml_upload_content_rio = xml_upload_content_lp2 = xml_upload_content_lpr = nil

    before :all do
      profile_content = package_id = 'SCPL-001300010001055B-20090325T130552800.lfp'

      # Step 1: Upload Device/Game log - RIO
      DeviceLogUpload.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial1, '2013-11-11T00:00:00', 'jeweltrain2.bin')
      DeviceLogUpload.upload_game_log(caller_id, rio_child[:child_id], '2013-11-11T00:00:00', filename, content_path)

      # Step 2: Get Child Upload History - After Upload Game Log - RIO
      xml_fetch_upload1 = ChildManagement.fetch_child_upload_history(caller_id, 'service', session, rio_child[:child_id])
      device_log1 = xml_fetch_upload1.xpath('//device-log').count

      # Step 3: Upload Content - RIO
      xml_upload_content_rio = DeviceProfileContent.upload_content_wo_handle_exception caller_id, session, device_serial1, '0', package_id, profile_content

      # Step 4: Upload Device/Game log - LP2
      DeviceLogUpload.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial2, '2013-11-11T00:00:00', 'jeweltrain2.bin')
      DeviceLogUpload.upload_game_log(caller_id, lp2_child[:child_id], '2013-11-11T00:00:00', filename, content_path)

      # Step 5: Get Child Upload History - After Upload Game Log - LP2
      xml_fetch_upload2 = ChildManagement.fetch_child_upload_history(caller_id, 'service', session, lp2_child[:child_id])
      device_log2 = xml_fetch_upload2.xpath('//device-log').count

      # Step 6: Upload Content - LP2
      xml_upload_content_lp2 = DeviceProfileContent.upload_content_wo_handle_exception caller_id, session, device_serial2, '0', package_id, profile_content

      # Step 7: Upload Device/Game log - LeapReader
      DeviceLogUpload.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial3, '2013-11-11T00:00:00', 'jeweltrain2.bin')
      DeviceLogUpload.upload_game_log(caller_id, lr_child[:child_id], '2013-11-11T00:00:00', filename, content_path)

      # Step 8: Get Child Upload History - After Upload Game Log - LeapReader
      xml_fetch_upload3 = ChildManagement.fetch_child_upload_history(caller_id, 'service', session, lr_child[:child_id])
      device_log3 = xml_fetch_upload3.xpath('//device-log').count

      # Step 9: Upload Content - LeapReader
      xml_upload_content_lpr = DeviceProfileContent.upload_content_wo_handle_exception caller_id, session, device_serial3, '0', package_id, profile_content
    end

    it 'Check for existence of [device-log] - RIO' do
      expect(device_log1).not_to eq(0)
    end

    it "Verify 'uploadContent' calls successfully - RIO - status code 200'" do
      expect(xml_upload_content_rio.http.code).to eq(200)
    end

    it 'Check for existence of [device-log] - LeapPad2' do
      expect(device_log2).not_to eq(0)
    end

    it "Verify 'uploadContent' calls successfully - LP2 - status code 200'" do
      expect(xml_upload_content_lp2.http.code).to eq(200)
    end

    it 'Check for existence of [device-log] - LeapReader' do
      expect(device_log3).not_to eq(0)
    end

    it "Verify 'uploadContent' calls successfully - LeapReader - status code 200'" do
      expect(xml_upload_content_lpr.http.code).to eq(200)
    end
  end

  context 'Test Case 07 - Use REST to get child information' do
    get_child_rio_res = get_child_lp2_res = get_child_lr_res = nil

    before :all do
      # Get Child Info RIO
      get_child_rio_res = ChildManagementRest.fetch_child(Misc::CONST_REST_CALLER_ID, rio_child[:child_id], session)

      # Get Child Info LeapPad2
      get_child_lp2_res = ChildManagementRest.fetch_child(Misc::CONST_REST_CALLER_ID, lp2_child[:child_id], session)

      # Get Child Info LeapReader
      get_child_lr_res = ChildManagementRest.fetch_child(Misc::CONST_REST_CALLER_ID, lr_child[:child_id], session)
    end

    it 'Match content of [@childID] - RIO' do
      expect(get_child_rio_res['data']['childID']).to eq(rio_child[:child_id])
    end

    it 'Match content of [@childName] - RIO' do
      expect(get_child_rio_res['data']['childName']).to eq('RIOKid')
    end

    it 'Match content of [@childID] - LeapPad2' do
      expect(get_child_lp2_res['data']['childID']).to eq(lp2_child[:child_id])
    end

    it 'Match content of [@childName] - LeapPad2' do
      expect(get_child_lp2_res['data']['childName']).to eq('LP2Kid')
    end

    it 'Match content of [@childID] - LeapReader' do
      expect(get_child_lr_res['data']['childID']).to eq(lr_child[:child_id])
    end

    it 'Match content of [@childName] - LeapReader' do
      expect(get_child_lr_res['data']['childName']).to eq('LRKid')
    end
  end
end
