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
Verify removeCurriculum service works correctly
=end

describe "TS14 - removeCurriculum - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = DeviceManagement.generate_serial
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  slot = '0'
  cur_id = LFCommon.get_current_time
  cur_name = 'UPLOADLOG_Spelling_' + cur_id
  child_name = 'UPLOADLOG'
  delivered = LFCommon.get_current_time
  grade = 'Ages 5-7'

  # Game log info
  local_time = '2013-11-11T00:00:00'
  filename = 'Stretchy monkey.log'
  content_path = "#{Misc::CONST_PROJECT_PATH}/data/Log2.xml"
  id = nil
  res = nil

  #---Pre-condition: Upload game log
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

  # uploadGameLog1
  DeviceLogUpload.upload_game_log(caller_id, child_id, local_time, filename, content_path)

  # claimDevice
  OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, 'leappad', slot, child_name, child_id)

  # assignDeviceProfiles
  DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, 'leappad', slot, child_name, child_id)
  #---End pre condition

  it 'Precondition - Create Curriculum' do
    Curriculum.remove_curriculum(caller_id, '36133')

    xml_res = Curriculum.create_question_curriculum(caller_id, device_serial, slot, cur_id, cur_name, delivered, child_name, grade)
    id = xml_res.xpath('//curriculum').attr('id').text
  end

  context 'TC14.001 - removeCurriculum - Successful Response' do
    remove_cur_res1 = nil

    before :all do
      Curriculum.remove_curriculum(caller_id, id)
      remove_cur_res1 = Curriculum.remove_curriculum(caller_id, id)
    end

    it "Verify 'InvalidStatusFault: The CYO with id ... has already been removed or completed' error responses" do
      expect(remove_cur_res1).to eq("InvalidStatusFault: The CYO with id \"" + id + "\" has already been removed or completed")
    end
  end

  context 'TC14.002 - removeCurriculum - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Curriculum.remove_curriculum(caller_id2, id)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC14.003 - removeCurriculum - cyo-id - character' do
    cyo_id3 = 'invalid'

    before :all do
      res = Curriculum.remove_curriculum(caller_id, cyo_id3)
    end

    it "Verify 'InvalidStatusFault: The CYO with id \"0\" has already been removed or completed' error responses" do
      expect(res).to eq("InvalidStatusFault: The CYO with id \"0\" has already been removed or completed")
    end
  end

  context 'TC14.004 - removeCurriculum - cyo-id - Nonexistence' do
    cyo_id4 = '-11111'

    before :all do
      res = Curriculum.remove_curriculum(caller_id, cyo_id4)
    end

    it "Verify 'InvalidRequestFault: Unable to complete removeCurriculum for cyoId \"-11111\"' error responses" do
      expect(res).to eq("InvalidRequestFault: Unable to complete removeCurriculum for cyoId \"-11111\"")
    end
  end
end
