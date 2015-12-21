require File.expand_path('../../../spec_helper', __FILE__)
require 'curriculum'

=begin
Verify listCurriculaBySubjectAndStatus service works correctly
=end

describe "TS06 - listCurriculaBySubjectAndStatus - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = '550D2E000001FF002D11'
  slot = '0'
  subject = 'S'
  status = 'removed'
  type = 'SPELLING'
  res = nil

  context 'TC06.001 - listCurriculaBySubjectAndStatus - Successful Response' do
    curriculum_num = nil
    xml_res = nil

    before :all do
      xml_res = Curriculum.list_curricula_by_subject_and_status(caller_id, device_serial, slot, subject, status)
      curriculum_num = xml_res.xpath('//curriculum').count
    end

    it "Verify 'listCurriculaBySubjectAndStatus' calls successfully" do
      (1..curriculum_num).each do |i|
        status1 = xml_res.xpath('//curriculum[' + i.to_s + ']').attr('status').text
        type1 = xml_res.xpath('//curriculum[' + i.to_s + ']').attr('type').text
        expect(status1).to eq(status)
        expect(type1).to eq(type)
      end
    end
  end

  context 'TC06.002 - listCurriculaBySubjectAndStatus - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Curriculum.list_curricula_by_subject_and_status(caller_id2, device_serial, slot, subject, status)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC06.003 - listCurriculaBySubjectAndStatus - device-serial - Empty' do
    device_serial3 = ''

    before :all do
      res = Curriculum.list_curricula_by_subject_and_status(caller_id, device_serial3, slot, subject, status)
    end

    it "Verify 'InvalidRequestFault: Unable to find a device for:' error responses" do
      expect(res).to eq('InvalidRequestFault: Unable to find a device for: ')
    end
  end

  context 'TC06.004 - listCurriculaBySubjectAndStatus - Nonexistent Subject' do
    subject4 = 'nonexistence'

    before :all do
      res = Curriculum.list_curricula_by_subject_and_status(caller_id, device_serial, slot, subject4, status)
    end

    it "Verify 'The service call returned with fault: The code: nonexistence is not a valid CyoSubjectType.  Valid subject codes are:  valid subjects:  M+ S M LA V SCI MUSC' error responses" do
      expect(res).to eq("The service call returned with fault: The code: nonexistence is not a valid CyoSubjectType.  Valid subject codes are: \nvalid subjects: \nM+\nS\nM\nLA\nV\nSCI\nMUSC\n")
    end
  end

  context 'TC06.005 - listCurriculaBySubjectAndStatus - slot - Nonexistence' do
    slot5 = '5'

    before :all do
      res = Curriculum.list_curricula_by_subject_and_status(caller_id, device_serial, slot5, subject, status)
    end

    it "Verify 'InvalidRequestFault: Unable to find a user for slot number: 5 and device id: 319313' error responses" do
      expect(res).to eq('InvalidRequestFault: Unable to find a user for slot number: 5 and device id: 319313')
    end
  end

  context 'TC06.006 - listCurriculaBySubjectAndStatus - Invalid Status' do
    status6 = 'invalid'

    before :all do
      res = Curriculum.list_curricula_by_subject_and_status(caller_id, device_serial, slot, subject, status6)
    end

    it "Verify 'The service call returned with fault: null' error responses" do
      expect(res).to eq('The service call returned with fault: null')
    end
  end

  context 'TC06.007 - listCurriculaBySubjectAndStatus - status - Empty' do
    status7 = ''

    before :all do
      res = Curriculum.list_curricula_by_subject_and_status(caller_id, device_serial, slot, subject, status7)
    end

    it "Verify 'The service call returned with fault: null' error responses" do
      expect(res).to eq('The service call returned with fault: null')
    end
  end
end
