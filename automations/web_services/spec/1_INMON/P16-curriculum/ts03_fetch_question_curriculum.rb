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
Verify fetchQuestionCurriculum service works correctly
=end

describe "TS03 - fetchQuestionCurriculum - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = DeviceManagement.generate_serial
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  slot = '0'
  cur_id = LFCommon.get_current_time
  cur_name = 'UPLOADLOG_Spelling_' + LFCommon.get_current_time
  child_name = 'UPLOADLOG'
  delivered = LFCommon.get_current_time
  grade = 'Ages 5-7'

  # Game log info
  local_time = '2013-11-11T00:00:00'
  filename = 'Stretchy monkey.log'
  content_path = "#{Misc::CONST_PROJECT_PATH}/data/Log2.xml"
  cyo_id = nil
  res = nil

  before :all do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = xml_register_child_res.xpath('//child').attr('id').text

    DeviceLogUpload.upload_game_log(caller_id, child_id, local_time, filename, content_path)
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, 'leappad', slot, child_name, child_id)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, 'leappad', slot, child_name, child_id)
  end

  context 'TC03.001 - fetchQuestionCurriculum - Successful Response' do
    xml_response = nil

    before :all do
      list_curicula_res = Curriculum.list_curricula(caller_id, device_serial, slot)

      Curriculum.remove_all_curriculum(caller_id, list_curicula_res)

      xml_create_question_res = Curriculum.create_question_curriculum(caller_id, device_serial, slot, cur_id, cur_name, delivered, child_name, grade)
      cyo_id = xml_create_question_res.xpath('//curriculum').attr('id').text

      xml_response = Curriculum.fetch_question_curriculum(caller_id, cyo_id)
    end

    it 'Match content of [@id]' do
      expect(xml_response.xpath('//curriculum/curriculum').attr('id').text).to eq(cyo_id)
    end

    it 'Match content of [@name]' do
      expect(xml_response.xpath('//curriculum/curriculum').attr('name').text).to eq(cur_name)
    end

    it 'Match content of [@type]' do
      expect(xml_response.xpath('//curriculum/curriculum').attr('type').text).to eq('SPELLING')
    end

    it 'Match content of [@grade]' do
      expect(xml_response.xpath('//curriculum/data-set').attr('grade').text).to eq(grade)
    end

    it 'Check count of [operand]' do
      expect(xml_response.xpath('//curriculum/data-set/operand').count).not_to eq(0)
    end
  end

  context 'TC03.002 - fetchQuestionCurriculum - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Curriculum.fetch_question_curriculum(caller_id2, cyo_id)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC03.003 - fetchQuestionCurriculum - cyo-id - character' do
    it 'Ignore will-not-fix defect: UPC# 36383 Web Services: curriculum: removeCurriculum: The service returns "InvalidStatusFault: The CYO with id "0" has already been removed or completed" when removing curriculum with invalid value of @cyo-id' do
    end
  end

  context 'TC03.004 - fetchQuestionCurriculum - cyo-id - Nonexistence' do
    cyo_id4 = '-11111'

    before :all do
      res = Curriculum.fetch_question_curriculum(caller_id, cyo_id4)
    end

    it "Verify 'InvalidRequestFault: Unable to complete findSpellingCurriculumById for cyoId...' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete findSpellingCurriculumById for cyoId \"" + cyo_id4 + "\"")
    end
  end
end
