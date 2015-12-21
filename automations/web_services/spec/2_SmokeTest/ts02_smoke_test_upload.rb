require File.expand_path('../../spec_helper', __FILE__)
require 'authentication'
require 'child_management'
require 'customer_management'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'
require 'device_log_upload'

=begin
Smoke test 02: upload game/device log functions devices: RIO, LPAD2, LR
=end

describe "TestSuite 02 - Smoke test 02 - #{Misc::CONST_ENV}" do
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
    # Step 1: Register Parent Account
    xml_register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(xml_register_cus_res)
    customer_id = arr_register_cus_res[:id]

    type1 = xml_register_cus_res.xpath('//customer').attr('type').text
    username1 = xml_register_cus_res.xpath('//customer/credentials').attr('username').text

    it 'Match content of [@type]' do
      expect(type1).to eq('Registered')
    end

    it 'Match content of [@username]' do
      expect(username1).to eq(username)
    end

    # Step 2: Login Parent account
    session = Authentication.get_service_session(caller_id, username, password)

    it 'Check for existance of [session]' do
      expect(session).not_to be_empty
    end

    # Step 3: Create RIO Child
    xml_register_child_rio = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'RIOKid', 'male', '1')
    rio_child = ChildManagement.register_child_info xml_register_child_rio

    it 'Match content of [@name] - RIO' do
      expect(rio_child[:child_name]).to eq('RIOKid')
    end

    it 'Match content of [@gender] - RIO' do
      expect(rio_child[:gender]).to eq('male')
    end

    it 'Match content of [@grade] - RIO' do
      expect(rio_child[:grade]).to eq('1')
    end

    # Step 4: Create Leapad2 Child
    xml_register_child_lp2 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'LP2Kid', 'female', '1')
    lp2_child = ChildManagement.register_child_info xml_register_child_lp2

    it 'Match content of [@name] - LP2' do
      expect(lp2_child[:child_name]).to eq('LP2Kid')
    end

    it 'Match content of [@gender] - LP2' do
      expect(lp2_child[:gender]).to eq('female')
    end

    it 'Match content of [@grade] - LP2' do
      expect(lp2_child[:grade]).to eq('1')
    end

    # Step 5: Create Leap Reader Child
    xml_register_child_lr = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'LRKid', 'male', '2')
    lr_child = ChildManagement.register_child_info xml_register_child_lr

    it 'Match content of [@name] - LR' do
      expect(lr_child[:child_name]).to eq('LRKid')
    end

    it 'Match content of [@gender] - LR' do
      expect(lr_child[:gender]).to eq('male')
    end

    it 'Match content of [@grade] - LR' do
      expect(lr_child[:grade]).to eq('2')
    end
  end

  context 'Test Case 02 - Claim Devices' do
    # Step 1: Claim RIO
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial1, 'leappad3', '0', 'RIOKid', '04444454')

    # listNominatedDevices and get device serials value
    xml_list_nominated_devices_res = DeviceManagement.list_nominated_devices(caller_id, session, 'service')
    serial1 = xml_list_nominated_devices_res.xpath('//device[1]').attr('serial').text
    platform1 = xml_list_nominated_devices_res.xpath('//device[1]').attr('platform').text

    it 'Match content of [@serial] - RIO' do
      expect(serial1).to eq(device_serial1)
    end

    it 'Match content of [@platform] - RIO' do
      expect(platform1).to eq('leappad3')
    end

    # Step 2: Claim LP2
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial2, 'leappad2', '0', 'LP2Kid', '04444454')

    # listNominatedDevices and get device serials value
    xml_list_nominated_devices_res = DeviceManagement.list_nominated_devices(caller_id, session, 'service')
    serial2 = xml_list_nominated_devices_res.xpath('//device[2]').attr('serial').text
    platform2 = xml_list_nominated_devices_res.xpath('//device[2]').attr('platform').text

    it 'Match content of [@serial] - LP2' do
      expect(serial2).to eq(device_serial2)
    end

    it 'Match content of [@platform] - LP2' do
      expect(platform2).to eq('leappad2')
    end

    # Step 3: Claim LR
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial3, 'leapreader', '0', 'LRKid', '04444454')

    # listNominatedDevices and get device serials value
    xml_list_nominated_devices_res = DeviceManagement.list_nominated_devices(caller_id, session, 'service')
    serial3 = xml_list_nominated_devices_res.xpath('//device[3]').attr('serial').text
    platform3 = xml_list_nominated_devices_res.xpath('//device[3]').attr('platform').text

    it 'Match content of [@serial] - LR' do
      expect(serial3).to eq(device_serial3)
    end

    it 'Match content of [@platform] - LR' do
      expect(platform3).to eq('leapreader')
    end

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

    it "Verify 'Assign Device Profiles' calls successfully" do
      expect(soap_fault).to eq(0)
    end

    # Step 5: Get Device Profiles
    xml_get_device_profile = DeviceProfileManagement.list_device_profiles(caller_id, username, customer_id, '10', '10', '')
    profile_num = xml_get_device_profile.xpath('//device-profile').count

    it 'Check count of [device-profile]' do
      expect(profile_num).to eq(3)
    end
  end

  context 'Test Case 03 - Device Log & Content Upload - RIO' do
    soap_fault1 = soap_fault2 = nil

    before :all do
      # Upload Device log
      xml_upload_device = DeviceLogUpload.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial1, '2013-11-11T00:00:00', 'jeweltrain2.bin')
      soap_fault1 = xml_upload_device.xpath('//faultcode').count

      # Upload Game log
      xml_upload_game = DeviceLogUpload.upload_game_log(caller_id, rio_child[:child_id], '2013-11-11T00:00:00', filename, content_path)
      soap_fault2 = xml_upload_game.xpath('//faultcode').count
    end

    it "Verify 'Device Log Upload - RIO' calls successfully" do
      expect(soap_fault1).to eq(0)
    end

    it "Verify 'Device Content Upload - RIO' calls successfully" do
      expect(soap_fault2).to eq(0)
    end
  end

  context 'Test Case 04 - Device Log & Content Upload - LP2' do
    soap_fault1 = soap_fault2 = nil

    before :all do
      # Upload Device log
      xml_upload_device = DeviceLogUpload.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial2, '2013-11-11T00:00:00', 'jeweltrain2.bin')
      soap_fault1 = xml_upload_device.xpath('//faultcode').count

      # Upload Game log
      xml_upload_game = DeviceLogUpload.upload_game_log(caller_id, lp2_child[:child_id], '2013-11-11T00:00:00', filename, content_path)
      soap_fault2 = xml_upload_game.xpath('//faultcode').count
    end

    it "Verify 'Device Log Upload - LP2' calls successfully" do
      expect(soap_fault1).to eq(0)
    end

    it "Verify 'Device Content Upload - LP2' calls successfully" do
      expect(soap_fault2).to eq(0)
    end
  end

  context 'Test Case 05 - Device Log & Content Upload - LR' do
    soap_fault1 = soap_fault2 = nil

    before :all do
      # Upload Device log
      xml_upload_device = DeviceLogUpload.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial3, '2013-11-11T00:00:00', 'jeweltrain2.bin')
      soap_fault1 = xml_upload_device.xpath('//faultcode').count

      # Upload Game log
      xml_upload_game = DeviceLogUpload.upload_game_log(caller_id, lr_child[:child_id], '2013-11-11T00:00:00', filename, content_path)
      soap_fault2 = xml_upload_game.xpath('//faultcode').count
    end

    it "Verify 'Device Log Upload - LR' calls successfully" do
      expect(soap_fault1).to eq(0)
    end

    it "Verify 'Device Content Upload - LR' calls successfully" do
      expect(soap_fault2).to eq(0)
    end
  end
end
