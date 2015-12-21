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
Verify createSublevelCurriculum service works correctly
=end

describe "TS02 - createSublevelCurriculum - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:curriculum][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:curriculum][:namespace]
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
    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, 'leappad', slot, child_name, child_id)
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, 'leappad', slot, child_name, child_id)

    fetch_device_res = fetch_device(caller_id, device_serial)
    device_id = fetch_device_res['data']['devId']
    user_id = fetch_device_res['data']['devUsers'][0]['userId']
  end

  it 'Precondition - Remove MathFACTS CYO' do
    list_cur_res = Curriculum.list_curricula(caller_id, device_serial, slot)
    Curriculum.remove_all_curriculum(caller_id, list_cur_res)
  end

  context 'TC02.001 - createSublevelCurriculum - Successful Response' do
    cyo_id1 = nil
    xml_response = nil

    before :all do
      xml_response = Curriculum.create_sublevel_curriculum(caller_id, device_serial, slot, cur_id, cur_name, child_name, type, delivered, started, created, grade)
      cyo_id = xml_response.xpath('//curriculum').attr('id').text

      xml_response = Curriculum.fetch_sub_level_curriculum(caller_id, cyo_id)
    end

    it 'Check for existence of [sublevel-groups]' do
      expect(xml_response.xpath('//curriculum/data-set/sublevel-groups').count).not_to eq(0)
    end

    it 'Check for existence of [sublevel]' do
      expect(xml_response.xpath('//curriculum/data-set/sublevel-groups/sublevel').count).not_to eq(0)
    end

    it 'Match content of [@id]' do
      expect(xml_response.xpath('//curriculum/curriculum').attr('id').text).to eq(cyo_id)
    end

    it 'Match content of [@name]' do
      expect(xml_response.xpath('//curriculum/curriculum').attr('name').text).to eq(cur_name)
    end

    it 'Match content of [@type]' do
      expect(xml_response.xpath('//curriculum/curriculum').attr('type').text).to eq('MATHFACTS')
    end

    after :all do
      Curriculum.remove_curriculum(caller_id, cyo_id1)
    end
  end

  context 'TC02.002 - createSublevelCurriculum - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Curriculum.create_sublevel_curriculum(caller_id2, device_serial, slot, cur_id, cur_name, child_name, type, delivered, started, created, grade)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC02.003 - createSublevelCurriculum - device-serial - Empty' do
    device_serial3 = ''

    before :all do
      res = Curriculum.create_sublevel_curriculum(caller_id, device_serial3, slot, cur_id, cur_name, child_name, type, delivered, started, created, grade)
    end

    it "Verify 'InvalidRequestFault: Unable to find a device for:' error responses" do
      expect(res).to eq('InvalidRequestFault: Unable to find a device for: ')
    end
  end

  context 'TC02.004 - createSublevelCurriculum - Nonexistent Sublevel Element' do
    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :create_sublevel_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='123456789' name='#{cur_name}' owner-name='#{child_name}' type='M' completion-param='10' completion-rate='0' status='pending' delivered='' started='' created='#{created}'/>
        <sublevel-groups/>"
      )
    end

    it "Verify 'IncompleteCurriculumFault: Curriculum must contain at least one sublevel element' error responses" do
      expect(res).to eq('IncompleteCurriculumFault: Curriculum must contain at least one sublevel element')
    end
  end

  context 'TC02.005 - createSublevelCurriculum - Nonexistent Grade' do
    cur_id5 = LFCommon.get_current_time
    cur_name5 = 'UPLOADLOG_MathFactsddd_' + LFCommon.get_current_time
    delivered5 = started5 = created5 = LFCommon.get_current_time
    grade5 = 'Ages 20-30'

    before :all do
      list_cur_res = Curriculum.list_curricula(caller_id, device_serial, slot)
      Curriculum.remove_all_curriculum(caller_id, list_cur_res)

      res = Curriculum.create_sublevel_curriculum(caller_id, device_serial, slot, cur_id5, cur_name5, child_name, type, delivered5, started5, created5, grade5)
    end

    it "Verify 'InvalidRequestFault: Unable to complete storeSubLevelCurriculum for user id...' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete storeSubLevelCurriculum for user id \"#{user_id}\", curriculum name \"" + cur_name5 + "\", and curriculum subject \"MATHFACTS\"")
    end
  end

  context 'TC02.006 - createSublevelCurriculum - @name - Duplicate' do
    cur_id6 = LFCommon.get_current_time
    cur_name6 = 'UPLOADLOG_MathFactsddd_' + LFCommon.get_current_time
    delivered6 = started6 = created6 = LFCommon.get_current_time
    cyo_id6 = nil

    before :all do
      list_cur_res = Curriculum.list_curricula(caller_id, device_serial, slot)
      Curriculum.remove_all_curriculum(caller_id, list_cur_res)

      xml_response = Curriculum.create_sublevel_curriculum(caller_id, device_serial, slot, cur_id6, cur_name6, child_name, type, delivered6, started6, created6, grade)
      cyo_id6 = xml_response.xpath('//curriculum').attr('id').text

      res = Curriculum.create_sublevel_curriculum(caller_id, device_serial, slot, cur_id6, cur_name6, child_name, type, delivered6, started6, created6, grade)
    end

    it "Verify 'CurriculumAlreadyExistsFault: A curriculum for this user already exists. User with Id: #{user_id} curriculum name: " + cur_name6 + "' error responses" do
      expect(res).to eq("CurriculumAlreadyExistsFault: A curriculum for this user already exists. User with Id: #{user_id} curriculum name: " + cur_name6)
    end

    after :all do
      Curriculum.remove_curriculum(caller_id, cyo_id6)
    end
  end

  context 'TC02.007 - createSublevelCurriculum - @name - Empty' do
    cur_id7 = LFCommon.get_current_time
    cur_name7 = ''

    before :all do
      res = Curriculum.create_sublevel_curriculum(caller_id, device_serial, slot, cur_id7, cur_name7, child_name, type, delivered, started, created, grade)
    end

    it "Verify 'IncompleteCurriculumFault: Curriculum name must contain a value' error responses" do
      expect(res).to eq('IncompleteCurriculumFault: Curriculum name must contain a value')
    end
  end

  context 'TC02.008 - createSublevelCurriculum - @type - Empty' do
    cur_id8 = LFCommon.get_current_time
    cur_name8 = 'UPLOADLOG_MathFactsddd_' + LFCommon.get_current_time
    type8 = ''

    before :all do
      res = Curriculum.create_sublevel_curriculum(caller_id, device_serial, slot, cur_id8, cur_name8, child_name, type8, delivered, started, created, grade)
    end

    it "Verify 'The service call returned with fault: null' error responses" do
      expect(res).to eq('The service call returned with fault: null')
    end
  end

  context 'TC02.009 - createSublevelCurriculum - @type - Nonexistence' do
    cur_id9 = LFCommon.get_current_time
    cur_name9 = 'UPLOADLOG_MathFactsddd_' + LFCommon.get_current_time
    type9 = 'inexistence'

    before :all do
      res = Curriculum.create_sublevel_curriculum(caller_id, device_serial, slot, cur_id9, cur_name9, child_name, type9, delivered, started, created, grade)
    end

    it "Verify 'The service call returned with fault: null' error responses" do
      expect(res).to eq('The service call returned with fault: null')
    end
  end

  context 'TC02.010 - createSublevelCurriculum - @competition-param - Input characters' do
    cur_id10 = LFCommon.get_current_time
    cur_name10 = 'UPLOADLOG_MathFactsddd_' + LFCommon.get_current_time
    completion_param = 'char'

    before :all do
      list_cur_res = Curriculum.list_curricula(caller_id, device_serial, slot)
      Curriculum.remove_all_curriculum(caller_id, list_cur_res)

      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :create_sublevel_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='#{cur_id10}' name='#{cur_name10}' owner-name='#{child_name}' type='#{type}' completion-param='#{completion_param}' completion-rate='0' status='pending' delivered='#{delivered}' started='#{started}' created='#{created}'/>
        <sublevel-groups>
          <sublevel-groups grade='#{grade}'>
            <sublevel id='1' status='NOT-STARTED'>
              <name>nam</name>
              <description>description</description>
              <example>example</example>
              </sublevel>
          </sublevel-groups>
        </sublevel-groups>"
      )
    end

    it "Verify 'Unmarshalling Error: Not a number: char' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: char ')
    end
  end

  context 'TC02.011 - createSublevelCurriculum - @completition-param - Negative Number' do
    cur_id11 = LFCommon.get_current_time
    cur_name11 = 'UPLOADLOG_MathFactsddd_' + LFCommon.get_current_time
    completion_param = '-1111'

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :create_sublevel_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='#{cur_id11}' name='#{cur_name11}' owner-name='#{child_name}' type='#{type}' completion-param='#{completion_param}' completion-rate='0' status='pending' delivered='#{delivered}' started='#{started}' created='#{created}'/>
        <sublevel-groups>
          <sublevel-groups grade='#{grade}'>
            <sublevel id='1' status='NOT-STARTED'>
              <name>nam</name>
              <description>description</description>
              <example>example</example>
              </sublevel>
          </sublevel-groups>
        </sublevel-groups>"
      )
    end

    it "Verify 'InvalidRequestFault: Unable to complete storeSubLevelCurriculum for user id...' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete storeSubLevelCurriculum for user id \"#{user_id}\", curriculum name \"" + cur_name11 + "\", and curriculum subject \"MATHFACTS\"")
    end
  end

  context 'TC02.012 - createSublevelCurriculum - @competition-param - Out of boundary' do
    cur_id12 = LFCommon.get_current_time
    cur_name12 = 'UPLOADLOG_MathFactsddd_' + LFCommon.get_current_time
    completion_param = '9999999999'

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :create_sublevel_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='#{cur_id12}' name='#{cur_name12}' owner-name='#{child_name}' type='#{type}' completion-param='#{completion_param}' completion-rate='0' status='pending' delivered='#{delivered}' started='#{started}' created='#{created}'/>
        <sublevel-groups>
          <sublevel-groups grade='#{grade}'>
            <sublevel id='1' status='NOT-STARTED'>
              <name>nam</name>
              <description>description</description>
              <example>example</example>
              </sublevel>
          </sublevel-groups>
        </sublevel-groups>"
      )
    end

    it "Verify 'InvalidRequestFault: Unable to complete storeSubLevelCurriculum for user id...' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete storeSubLevelCurriculum for user id \"#{user_id}\", curriculum name \"" + cur_name12 + "\", and curriculum subject \"MATHFACTS\"")
    end
  end

  context 'TC02.013 - createSublevelCurriculum - sublevel id is not existed' do
    cur_id13 = LFCommon.get_current_time
    cur_name13 = 'UPLOADLOG_MathFactsddd_' + LFCommon.get_current_time

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :create_sublevel_curriculum,
        "<caller-id>#{caller_id}</caller-id>
        <device-serial>#{device_serial}</device-serial>
        <slot>#{slot}</slot>
        <curriculum id='#{cur_id13}' name='#{cur_name13}' owner-name='#{child_name}' type='#{type}' completion-param='10' completion-rate='0' status='pending' delivered='#{delivered}' started='#{started}' created='#{created}'/>
        <sublevel-groups>
          <sublevel-groups grade='Ages 5-7'>
            <sublevel id='1' status='NOT-STARTED'>
              <name>name</name>
              <description>description</description>
              <example>example</example>
            </sublevel>
            <sublevel id='7' status='NOT-STARTED'>
              <name>das</name>
              <description>asdas</description>
              <example>asdasdsa</example>
            </sublevel>
          </sublevel-groups>
        </sublevel-groups>"
      )
    end

    it "Verify 'InvalidRequestFault: Unable to complete storeSubLevelCurriculum for user id...' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete storeSubLevelCurriculum for user id \"#{user_id}\", curriculum name \"" + cur_name13 + "\", and curriculum subject \"MATHFACTS\"")
    end
  end
end
