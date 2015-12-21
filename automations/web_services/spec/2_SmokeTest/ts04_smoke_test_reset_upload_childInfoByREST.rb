require File.expand_path('../../spec_helper', __FILE__)
require 'authentication'
require 'child_management'
require 'learning_path/child_management'
require 'customer_management'
require 'child_management'
require 'device_profile_content'
require 'device_log_upload'
require 'child_management'

=begin
Smoke test: reset, upload function by using REST
=end

describe "TestSuite 04 - Smoke test 04 - #{Misc::CONST_ENV}" do
  caller_id = 'a023bc85-db5b-40b5-934c-28a72b4d9547'
  device_serial = 'L3xyz123321xyz27845298426'
  username = email = 'ltrc_1216213_qa@leapfrog.test'
  password = LFCommon.get_current_time
  screen_name = ''
  customer_id = '2842123'
  session = child_id = nil

  filename = 'Stretchy monkey.log'
  content_path = "#{Misc::CONST_PROJECT_PATH}/data/Log2.xml"

  context 'Test Case 01 - Precondition get session' do
    before :all do
      # Step 1: Update Customer
      CustomerManagement.update_customer(caller_id, customer_id, username, email, password, screen_name)

      # Step 2: Login Parent account
      session = Authentication.get_service_session(caller_id, username, password)
    end

    it 'Check for existence of [session]' do
      expect(session).not_to be_empty
    end
  end

  context 'Test Case 02 - Get Child Information' do
    xml_fetch_child = nil

    before :all do
      # Step 1: List Child
      xml_list_child = ChildManagement.list_children(caller_id, session, customer_id)
      child_id = xml_list_child.xpath('//child[1]/@id').text

      # Step 2: Get Child Information
      xml_fetch_child = ChildManagement.fetch_child(caller_id, session, child_id)
    end

    it 'Match content of [@id]' do
      expect(xml_fetch_child.xpath('//child/@id').text).to eq(child_id)
    end

    it 'Check for existence of [@dob]' do
      expect(xml_fetch_child.xpath('//child/@dob').text).not_to be_empty
    end

    it 'Check for existence of [@name]' do
      expect(xml_fetch_child.xpath('//child/@name').text).not_to be_empty
    end

    it 'Check for existence of [@grade]' do
      expect(xml_fetch_child.xpath('//child/@grade').text).not_to be_empty
    end
  end

  context 'Test Case 03 - Reset Password' do
    xml_fetch_cus1 = xml_fetch_cus2 = nil

    before :all do
      # Step 1: fetchCustomer - before reset
      xml_fetch_cus1 = CustomerManagement.fetch_customer(caller_id, customer_id)

      # Step 2: Reset password
      CustomerManagement.reset_password(caller_id, username)

      # Step 3: fetchCustomer - after reset
      xml_fetch_cus2 = CustomerManagement.fetch_customer(caller_id, customer_id)

      # Step 4: acquireServiceSession
      session = Authentication.get_service_session(caller_id, username, password)
    end

    it "Check 'password-temporary' before resetting password" do
      expect(xml_fetch_cus1.xpath('//customer/credentials/@password-temporary').text).to eq('false')
    end

    it "Check 'password-temporary' after resetting password" do
      expect(xml_fetch_cus2.xpath('//customer/credentials/@password-temporary').text).to eq('true')
    end

    it 'Check for existence of [session]' do
      expect(session).not_to be_empty
    end
  end

  context 'Test Case 04 - Upload Logs' do
    device_log = xml_upload_content = nil

    before :all do
      # Step 1: Upload Device/Game log
      DeviceLogUpload.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial, '2013-11-11T00:00:00', 'jeweltrain2.bin')
      DeviceLogUpload.upload_game_log(caller_id, child_id, '2013-11-11T00:00:00', filename, content_path)

      # Step 2: Get Child Upload History - After Upload Game Log
      xml_fetch_upload = ChildManagement.fetch_child_upload_history(caller_id, 'service', session, child_id)
      device_log = xml_fetch_upload.xpath('//device-log').count

      # Step 3: Upload Content
      profile_content = package_id = 'SCPL-001300010001055B-20090325T130552800.lfp'
      xml_upload_content = DeviceProfileContent.upload_content_wo_handle_exception caller_id, session, device_serial, '0', package_id, profile_content
    end

    it 'Check for existence of [device-log]' do
      expect(device_log).not_to eq(0)
    end

    it "Verify 'uploadContent' calls successfully - status code 200'" do
      expect(xml_upload_content.http.code).to eq(200)
    end
  end

  context 'Test Case 05 - Use REST to get child information' do
    get_child_res = nil

    before :all do
      # Use REST to get child information
      get_child_res = ChildManagementRest.fetch_child(Misc::CONST_REST_CALLER_ID, child_id, session)
    end

    it 'Match content of [@childID]' do
      expect(get_child_res['data']['childID']).to eq(child_id)
    end

    it 'Match content of [@childName]' do
      expect(get_child_res['data']['childName']).to eq('RIOKid')
    end
  end
end
