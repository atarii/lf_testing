require File.expand_path('../../../spec_helper', __FILE__)
require 'curriculum'

=begin
Verify listSubLevelCatalog service works correctly
=end

describe "TS11 - listSubLevelCatalog - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  subject = 'M'
  res = nil

  context 'TC11.001 - listSubLevelCatalog - Successful Response' do
    sublevel_num = nil

    before :all do
      xml_res = Curriculum.list_sub_level_catalog(caller_id, subject)
      sublevel_num = xml_res.xpath('//catalog/sublevel-groups/sublevel').count
    end

    it "Verify 'listCurriculumSubjects' calls successfully" do
      expect(sublevel_num).not_to eq(0)
    end
  end

  context 'TC11.002 - listSubLevelCatalog - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Curriculum.list_sub_level_catalog(caller_id2, subject)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC11.003 - listSubLevelCatalog - Subject - Nonexistence' do
    subject3 = 'invalid'

    before :all do
      res = Curriculum.list_sub_level_catalog(caller_id, subject3)
    end

    it "Verify 'The service call returned with fault: The code: invalid is not a valid CyoSubjectType.  Valid subject codes are:  valid subjects:  M+ S M LA V SCI MUSC" do
      expect(res).to eq("The service call returned with fault: The code: invalid is not a valid CyoSubjectType.  Valid subject codes are: \nvalid subjects: \nM+\nS\nM\nLA\nV\nSCI\nMUSC\n")
    end
  end

  context 'TC11.004 - listSubLevelCatalog - Subject - Empty' do
    subject4 = ''

    before :all do
      res = Curriculum.list_sub_level_catalog(caller_id, subject4)
    end

    it "Verify 'The service call returned with fault: The code: invalid is not a valid CyoSubjectType.  Valid subject codes are:  valid subjects:  M+ S M LA V SCI MUSC" do
      expect(res).to eq("The service call returned with fault: The code:  is not a valid CyoSubjectType.  Valid subject codes are: \nvalid subjects: \nM+\nS\nM\nLA\nV\nSCI\nMUSC\n")
    end
  end
end
