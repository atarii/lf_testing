require File.expand_path('../../../spec_helper', __FILE__)
require 'curriculum'
require 'restfulcalls'
require 'device_log_upload'
require 'authentication'
require 'child_management'
require 'customer_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'

=begin
Verify listCurricula service works correctly
=end

describe "TS05 - listCurricula - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = DeviceManagement.generate_serial
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  slot = '0'

  # Curiculum info
  cur_id = LFCommon.get_current_time
  cur_name = 'UPLOADLOG_Spelling_' + LFCommon.get_current_time
  owner_name = 'Ronaldo'
  delivered = LFCommon.get_current_time
  grade = 'Ages 5-7'

  # Game log info
  local_time = '2013-11-11T00:00:00'
  filename = 'Stretchy monkey.log'
  content_path = "#{Misc::CONST_PROJECT_PATH}/data/Log2.xml"
  device_id = nil
  res = nil

  before :all do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = xml_register_child_res.xpath('//child').attr('id').text

    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, 'leappad', slot, owner_name, child_id)
    DeviceManagement.update_profiles(caller_id, session, 'service', device_serial, 'leappad', 0, owner_name, child_id)

    fetch_device_res = fetch_device(caller_id, device_serial)
    device_id = fetch_device_res['data']['devId']

    DeviceLogUpload.upload_game_log(caller_id, child_id, local_time, filename, content_path)
    Curriculum.create_question_curriculum(caller_id, device_serial, slot, cur_id, cur_name, delivered, owner_name, grade)
  end

  context 'TC05.001 - listCurricula - Successful Response' do
    owner_name1 = nil
    curriculum_num = nil
    xml_response = nil

    before :all do
      xml_response = Curriculum.list_curricula(caller_id, device_serial, slot)
      curriculum_num = xml_response.xpath('//curriculum').count
      owner_name1 = xml_response.xpath('//curriculum[1]').attr('owner-name').text
    end

    it "Verify 'listCurricula' calls successfully" do
      (1..curriculum_num).each do |i|
        owner_name2 = xml_response.xpath('//curriculum[' + i.to_s + ']').attr('owner-name').text
        expect(owner_name2).to eq(owner_name1)
      end
    end
  end

  context 'TC05.002 - listCurricula - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Curriculum.list_curricula(caller_id2, device_serial, slot)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC05.003 - listCurricula - device-serial - Empty' do
    device_serial3 = ''

    before :all do
      res = Curriculum.list_curricula(caller_id, device_serial3, slot)
    end

    it "Verify 'InvalidRequestFault: Unable to find a device for:' error responses" do
      expect(res).to eq('InvalidRequestFault: Unable to find a device for: ')
    end
  end

  context 'TC05.004 - listCurricula - slot - Nonexistence' do
    slot4 = '5'

    before :all do
      res = Curriculum.list_curricula(caller_id, device_serial, slot4)
    end

    it "Verify 'InvalidRequestFault: Unable to find a user for slot number: 5 and device id: #{device_id}' error responses" do
      expect(res).to eq('InvalidRequestFault: Unable to find a user for slot number: ' + slot4 + " and device id: #{device_id}")
    end
  end
end
