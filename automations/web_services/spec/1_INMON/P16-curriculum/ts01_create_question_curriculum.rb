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
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:curriculum][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:curriculum][:namespace]
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
  customer_id = session = child_id = device_id = user_id = nil
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

    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, 'leappad', slot, owner_name, child_id)

    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, 'leappad', slot, owner_name, child_id)

    fetch_device_res = fetch_device(caller_id, device_serial)
    device_id = fetch_device_res['data']['devId']
    user_id = fetch_device_res['data']['devUsers'][0]['userId']
  end

  it 'Precondition - Remove Spelling CYO' do
    list_cur_res = Curriculum.list_curricula(caller_id, device_serial, slot)
    Curriculum.remove_all_curriculum(caller_id, list_cur_res)
  end

  context 'TC01.001 - createQuestionCurriculum - Successful Response' do
    xml_fetch_res = nil

    before :all do
      xml_create_question_res = Curriculum.create_question_curriculum(caller_id, device_serial, slot, cur_id, cur_name, delivered, owner_name, grade)
      cyo_id = xml_create_question_res.xpath('//curriculum').attr('id').text

      xml_fetch_res = Curriculum.fetch_question_curriculum(caller_id, cyo_id)
    end

    it 'Match content of [@owner-name]' do
      expect(xml_fetch_res.xpath('//curriculum/curriculum').attr('owner-name').text).to eq(owner_name)
    end

    it 'Match content of [@id]' do
      expect(xml_fetch_res.xpath('//curriculum/curriculum').attr('id').text).to eq(cyo_id)
    end

    it 'Match content of [@name]' do
      expect(xml_fetch_res.xpath('//curriculum/curriculum').attr('name').text).to eq(cur_name)
    end

    it 'Match content of [@type]' do
      expect(xml_fetch_res.xpath('//curriculum/curriculum').attr('type').text).to eq('SPELLING')
    end

    it 'Match content of [@grade]' do
      expect(xml_fetch_res.xpath('//curriculum/data-set').attr('grade').text).to eq(grade)
    end

    it 'Check count of [operand]' do
      expect(xml_fetch_res.xpath('//curriculum/data-set/operand').count).not_to eq(0)
    end

    after :all do
      Curriculum.remove_curriculum(caller_id, cyo_id)
    end
  end

  context 'TC01.002 - createQuestionCurriculum - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Curriculum.create_question_curriculum(caller_id2, device_serial, slot, cur_id, cur_name, delivered, owner_name, grade)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - createQuestionCurriculum - Invalid Request - device-serial' do
    device_serial3 = ''

    before :all do
      res = Curriculum.create_question_curriculum(caller_id, device_serial3, slot, cur_id, cur_name, delivered, owner_name, grade)
    end

    it "Verify 'InvalidRequestFault: Unable to find a device for:' error responses" do
      expect(res).to eq('InvalidRequestFault: Unable to find a device for: ')
    end
  end

  context 'TC01.004 - createQuestionCurriculum - Invalid Request - slot' do
    cur_id4 = LFCommon.get_current_time
    cur_name4 = 'UPLOADLOG_Spelling_' + LFCommon.get_current_time
    delivered4 = LFCommon.get_current_time
    slot4 = '-123'

    before :all do
      res = Curriculum.create_question_curriculum(caller_id, device_serial, slot4, cur_id4, cur_name4, delivered4, owner_name, grade)
    end

    it "Verify 'InvalidRequestFault: Unable to find a user for slot number: -123 and device id: #{device_id}" do
      expect(res).to eq("InvalidRequestFault: Unable to find a user for slot number: -123 and device id: #{device_id}")
    end
  end

  context 'TC01.005 - createQuestionCurriculum - Nonexistent CurriculumId' do
    cur_id5 = 'invalid'

    before :all do
      res = Curriculum.create_question_curriculum(caller_id, device_serial, slot, cur_id5, cur_name, delivered, owner_name, grade)
    end

    it "Verify 'Unmarshalling Error: For input string: \"invalid\" ' error responses" do
      expect(res).to eq("Unmarshalling Error: For input string: \"invalid\" ")
    end
  end

  context 'TC01.006 - createQuestionCurriculum - Invalid Curriculum Type' do
    cur_type6 = 'invalid'

    before :all do
      res = LFCommon.soap_call(
        namespace,
        endpoint,
        :create_question_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='6666' status='pending' name='UPLOADLOG_Spelling' type='#{cur_type6}' completion-param='3' delivered='#{delivered}' completion-rate='0' owner-name='#{owner_name}'/>
        <operands grade='Ages 5-7' category='0'>
          <operand>a</operand>
          <operand>an</operand>
          <operand>on</operand>
          <operand>of</operand>
          <operand>to</operand>
        </operands>"
      )
    end

    it "Verify 'IncompleteCurriculumFault: Curriculum must contain a valid subject.  One of:  M+ S M LA V SCI MUSC' error responses" do
      expect(res).to eq("IncompleteCurriculumFault: Curriculum must contain a valid subject.  One of: \nM+\nS\nM\nLA\nV\nSCI\nMUSC\n")
    end
  end

  context 'TC01.007 - createQuestionCurriculum - Invalid Operands' do
    before :all do
      res = LFCommon.soap_call(
        namespace,
        endpoint,
        :create_question_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='666666' status='pending' name='UPLOADLOG_Spelling' type='S' completion-param='3' delivered='#{delivered}' completion-rate='0' owner-name='#{owner_name}'/>
        <operands grade='Ages 5-7' category='0'/>"
      )
    end

    it "Verify 'IncompleteCurriculumFault: Curriculum must contain at least one question/spelling element' error responses" do
      expect(res).to eq('IncompleteCurriculumFault: Curriculum must contain at least one question/spelling element')
    end
  end

  context 'TC01.008 - createQuestionCurriculum - Operands - Less Than 5 Words' do
    before :all do
      list_cur_res = Curriculum.list_curricula(caller_id, device_serial, slot)
      Curriculum.remove_all_curriculum(caller_id, list_cur_res)

      res = LFCommon.soap_call(
        namespace,
        endpoint,
        :create_question_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='6666' status='pending' name='UPLOADLOG_Spelling' type='S' completion-param='3' delivered='#{delivered}' completion-rate='0' owner-name='#{owner_name}'/>
        <operands grade='Ages 5-7' category='0'>
          <operand>a</operand>
          <operand>an</operand>
        </operands>"
      )
    end

    it 'Report bug' do
      expect('#36347: Web Services: curriculum: createQuestionCurriculum: The services accept entered of Operands that are lesser than 5 words').to eq(res)
    end
  end

  context 'TC01.009 - createQuestionCurriculum - Operands - More Than 25 Words' do
    xml_response = cur_name9 = nil

    before :all do
      cur_id9 = LFCommon.get_current_time
      cur_name9 = 'UPLOADLOG_Spelling_' + LFCommon.get_current_time
      delivered9 = LFCommon.get_current_time

      list_cur_res = Curriculum.list_curricula(caller_id, device_serial, slot)
      Curriculum.remove_all_curriculum(caller_id, list_cur_res)

      xml_response = LFCommon.soap_call(
        namespace,
        endpoint,
        :create_question_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='#{cur_id9}' status='pending' name='#{cur_name9}' type='S' completion-param='3' delivered='#{delivered9}' completion-rate='0' owner-name='#{owner_name}' created=''/>
        <operands grade='Ages 5-7' category='0'>
          <operand>on</operand>
          <operand>an</operand>
          <operand>a</operand>
          <operand>and</operand>
          <operand>the</operand>
          <operand>run</operand>
          <operand>ran</operand>
          <operand>all</operand>
          <operand>alone</operand>
          <operand>about</operand>
          <operand>again</operand>
          <operand>to</operand>
          <operand>do</operand>
          <operand>done</operand>
          <operand>did</operand>
          <operand>am</operand>
          <operand>is</operand>
          <operand>are</operand>
          <operand>you</operand>
          <operand>these</operand>
          <operand>those</operand>
          <operand>there</operand>
          <operand>this</operand>
          <operand>that</operand>
          <operand>what</operand>
          <operand>when</operand>
        </operands>"
      )
    end

    it "Verify service response \"Verify service response \"InvalidRequestFault: Unable to complete storeQuestionCurriculum for user id \"#{user_id}\", curriculum name \"#{cur_name9}\", curriculum subject \"SPELLING\"\"" do
      expect(xml_response).to eq("InvalidRequestFault: Unable to complete storeQuestionCurriculum for user id \"#{user_id}\", curriculum name \"#{cur_name9}\", curriculum subject \"SPELLING\"")
    end

    after :all do
      list_cur_res = Curriculum.list_curricula(caller_id, device_serial, slot)
      Curriculum.remove_all_curriculum(caller_id, list_cur_res)
    end
  end

  context 'TC01.010 - createQuestionCurriculum - Operands - Duplicate Words' do
    cur_name10 = 'UPLOADLOG_Spelling_' + LFCommon.get_current_time

    before :all do
      delivered10 = LFCommon.get_current_time
      cur_id10 = LFCommon.get_current_time

      res = LFCommon.soap_call(
        namespace,
        endpoint,
        :create_question_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='#{cur_id10}' status='pending' name='#{cur_name10}' type='S' completion-param='3' delivered='#{delivered10}' completion-rate='0' owner-name='#{owner_name}'/>
        <operands grade='Ages 5-7' category='0'>
          <operand>on</operand>
          <operand>on</operand>
          <operand>an</operand>
          <operand>a</operand>
          <operand>and</operand>
          <operand>the</operand>
          <operand>run</operand>
          <operand>ran</operand>
        </operands>"
      )
    end

    it "Verify 'InvalidRequestFault: Unable to complete storeQuestionCurriculum for user id \"#{user_id}\", curriculum name \"UPLOADLOG_Spelling_201461810365898\", curriculum subject \"SPELLING\"' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete storeQuestionCurriculum for user id \"#{user_id}\", curriculum name \"" + cur_name10 + "\", curriculum subject \"SPELLING\"")
    end
  end

  context 'TC01.011 - createQuestionCurriculum - Operands - Out of @category range' do
    cur_id11 = LFCommon.get_current_time
    cur_name11 = 'UPLOADLOG_Spelling_' + LFCommon.get_current_time
    delivered11 = LFCommon.get_current_time

    before :all do
      res = LFCommon.soap_call(
        namespace,
        endpoint,
        :create_question_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='#{cur_id11}' status='pending' name='#{cur_name11}' type='S' completion-param='3' delivered='#{delivered11}' completion-rate='0' owner-name='#{owner_name}'/>
        <operands grade='Ages 5-7' category='1000'>
          <operand>on</operand>
          <operand>on</operand>
          <operand>an</operand>
          <operand>a</operand>
          <operand>and</operand>
          <operand>the</operand>
          <operand>run</operand>
          <operand>ran</operand>
        </operands>"
      )
    end

    it "Verify 'InvalidRequestFault: Unable to complete storeQuestionCurriculum for user id \"#{user_id}\", curriculum name \"UPLOADLOG_Spelling_201461810365898\", curriculum subject \"SPELLING\"' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete storeQuestionCurriculum for user id \"#{user_id}\", curriculum name \"" + cur_name11 + "\", curriculum subject \"SPELLING\"")
    end
  end

  context 'TC01.012 - createQuestionCurriculum - Invalid grades' do
    cur_id12 = LFCommon.get_current_time
    cur_name12 = 'UPLOADLOG_Spelling_' + LFCommon.get_current_time
    delivered12 = LFCommon.get_current_time
    grade12 = 'invalid'

    before :all do
      res = Curriculum.create_question_curriculum(caller_id, device_serial, slot, cur_id12, cur_name12, delivered12, owner_name, grade12)
    end

    it "Verify 'InvalidRequestFault: Unable to complete storeQuestionCurriculum for user id \"#{user_id}\", curriculum name \"UPLOADLOG_Spelling_201461810365898\", curriculum subject \"SPELLING\"' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete storeQuestionCurriculum for user id \"#{user_id}\", curriculum name \"" + cur_name12 + "\", curriculum subject \"SPELLING\"")
    end
  end

  context 'TC01.013 - createQuestionCurriculum - Invalid operand' do
    cur_id13 = LFCommon.get_current_time
    cur_name13 = 'UPLOADLOG_Spelling_' + LFCommon.get_current_time
    delivered13 = LFCommon.get_current_time

    before :all do
      res = LFCommon.soap_call(
        namespace,
        endpoint,
        :create_question_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='#{cur_id13}' status='pending' name='#{cur_name13}' type='S' completion-param='3' delivered='#{delivered13}' completion-rate='0' owner-name='#{owner_name}'/>
        <operands grade='Ages 5-7' category='0'>
          <operand>a</operand>
          <operand>an</operand>
          <operand>on</operand>
          <operand>of</operand>
          <operand>to</operand>
          <operand>airplane</operand>
        </operands>"
      )
    end

    it "Verify 'InvalidRequestFault: Unable to complete storeQuestionCurriculum for user id \"#{user_id}\", curriculum name \"UPLOADLOG_Spelling_201461810365898\", curriculum subject \"SPELLING\"' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete storeQuestionCurriculum for user id \"#{user_id}\", curriculum name \"" + cur_name13 + "\", curriculum subject \"SPELLING\"")
    end
  end
end
