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

describe "TS04 - fetchSublevelCurriculum - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = DeviceManagement.generate_serial
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  slot = '0'
  cur_id = LFCommon.get_current_time
  cur_name = 'UPLOADLOG_MathFactsddd_' + LFCommon.get_current_time
  child_name = 'UPLOADLOG'
  type = 'M'
  delivered = started = created = LFCommon.get_current_time
  grade = 'Ages 5-7'

  # Game log info
  local_time = '2013-11-11T00:00:00'
  filename = 'Stretchy monkey.log'
  content_path = "#{Misc::CONST_PROJECT_PATH}/data/Log2.xml"
  cyo_id = nil
  res = nil

  it 'Pre condition - Upload game log' do
    # Register customer and get CustomerID
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    # acquireServiceSession - Login
    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    # registerChild and get ChildID
    xml_register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = xml_register_child_res.xpath('//child').attr('id').text

    DeviceLogUpload.upload_game_log(caller_id, child_id, local_time, filename, content_path)
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, 'leappad', slot, child_name, child_id)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, 'leappad', slot, child_name, child_id)
  end

  it 'Precondition - createSublevelCurriculum' do
    list_cur_res = Curriculum.list_curricula(caller_id, device_serial, slot)
    Curriculum.remove_all_curriculum(caller_id, list_cur_res)

    xml_response = Curriculum.create_sublevel_curriculum(caller_id, device_serial, slot, cur_id, cur_name, child_name, type, delivered, started, created, grade)
    cyo_id = xml_response.xpath('//curriculum').attr('id').text
  end

  context 'TC04.001 - fetchSublevelCurriculum - Successful Response' do
    xml_response = nil

    before :all do
      xml_response = Curriculum.fetch_sub_level_curriculum(caller_id, cyo_id)
    end

    it 'Check for existance of [sublevel-groups]' do
      expect(xml_response.xpath('//curriculum/data-set/sublevel-groups').count).not_to eq(0)
    end

    it 'Check for existance of [sublevel]' do
      expect(xml_response.xpath('//curriculum/data-set/sublevel-groups/sublevel').count).not_to eq(0)
    end

    it 'Match content of [@id]' do
      expect(xml_response.xpath('//curriculum/curriculum').attr('id').text).to eq(cyo_id)
    end

    it 'Match content of [@name]' do
      expect(xml_response.xpath('//curriculum/curriculum').attr('name').text).to eq(cur_name)
    end
  end

  context 'TC04.002 - fetchSublevelCurriculum - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Curriculum.fetch_sub_level_curriculum(caller_id2, '36515')
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC04.003 - fetchSublevelCurriculum - Invalid Request' do
    cyo_id3 = '-147258'

    before :all do
      res = Curriculum.fetch_sub_level_curriculum(caller_id, cyo_id3)
    end

    it "Verify 'InvalidRequestFault: Unable to complete findSubLevelCurriculumById for cyoId \"" + cyo_id3 + "\"' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete findSubLevelCurriculumById for cyoId \"" + cyo_id3 + "\"")
    end
  end
end
