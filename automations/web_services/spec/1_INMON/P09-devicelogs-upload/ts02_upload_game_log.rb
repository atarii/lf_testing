require File.expand_path('../../../spec_helper', __FILE__)
require 'device_log_upload'
require 'authentication'
require 'child_management'
require 'customer_management'

=begin
Verify uploadGameLog service works correctly
=end

describe "TS02 - uploadGameLog - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  local_time = '2013-11-11T00:00:00'
  filename = 'Stretchy monkey.log'
  content_path = "#{Misc::CONST_PROJECT_PATH}/data/Log2.xml"
  child_id = nil
  res = nil

  context 'TC02.001 - uploadGameLog - Successful Response' do
    device_log1 = device_log2 = device_log3 = nil

    before :all do
      register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
      arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
      customer_id = arr_register_cus_res[:id]

      xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
      session = xml_acquire_session_res.xpath('//session').text

      xml_register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
      child_id = xml_register_child_res.xpath('//child').attr('id').text

      xml_fetch_upload_res1 = ChildManagement.fetch_child_upload_history(caller_id, 'service', session, child_id)
      device_log1 = xml_fetch_upload_res1.xpath('//device-log').count

      DeviceLogUpload.upload_game_log(caller_id, child_id, local_time, filename, content_path)
      xml_fetch_upload_res2 = ChildManagement.fetch_child_upload_history(caller_id, 'service', session, child_id)
      device_log2 = xml_fetch_upload_res2.xpath('//device-log').count

      DeviceLogUpload.upload_game_log(caller_id, child_id, local_time, filename, content_path)
      xml_fetch_upload_res3 = ChildManagement.fetch_child_upload_history(caller_id, 'service', session, child_id)
      device_log3 = xml_fetch_upload_res3.xpath('//device-log').count
    end

    it 'Verify no device-log after registering Child' do
      expect(device_log1).to eq(0)
    end

    it 'Verify one device-log after uploading Game log at the 1st time' do
      expect(device_log2).to eq(1)
    end

    it 'Verify two device-log after uploading Game log at the 2nd time' do
      expect(device_log3).to eq(2)
    end
  end

  context 'TC02.003 - uploadGameLog - Invalid Request' do
    child_id3 = 'invalid'

    before :all do
      res = DeviceLogUpload.upload_game_log(caller_id, child_id3, '', '', '')
    end

    it "Verify 'Unmarshalling Error: For input string: \"invalid\"' error responses" do
      expect(res).to eq("Unmarshalling Error: For input string: \"invalid\" ")
    end
  end

  context 'TC02.004 - uploadGameLog - cannot upload' do
    content_path4 = 'D:\\eclipse_workspace\\ServicesTesting\\test\\P09-devicelogs-upload\\not_exist.xml'

    before :all do
      res = DeviceLogUpload.upload_game_log(caller_id, child_id, local_time, filename, content_path4)
    end

    it "Verify 'Unexpected error while parsing log file' error responses" do
      expect(res).to eq('Unexpected error while parsing log file')
    end
  end

  context 'TC02.005 - uploadGameLog - invalid content' do
    content_path5 = ''

    before :all do
      res = DeviceLogUpload.upload_game_log(caller_id, child_id, local_time, filename, content_path5)
    end

    it "Verify 'Unexpected error while parsing log file' error responses" do
      expect(res).to eq('Unexpected error while parsing log file')
    end
  end
end
