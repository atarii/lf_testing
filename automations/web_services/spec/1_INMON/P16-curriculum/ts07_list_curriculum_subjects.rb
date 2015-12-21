require File.expand_path('../../../spec_helper', __FILE__)
require 'curriculum'

=begin
Verify listCurriculumSubjects service works correctly
=end

describe "TS07 - listCurriculumSubjects - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  res = nil

  context 'TC07.001 - listCurriculumSubjects - Successful Response - Successful Response' do
    subject_num = nil

    before :all do
      xml_res = Curriculum.list_curriculum_subjects(caller_id)
      subject_num = xml_res.xpath('//subject').count
    end

    it "Verify 'listCurriculumSubjects' calls successfully" do
      expect(subject_num).not_to eq(0)
    end
  end

  context 'TC07.002 - listCurriculumSubjects - Invalid CallerID - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Curriculum.list_curriculum_subjects(caller_id2)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end
end
