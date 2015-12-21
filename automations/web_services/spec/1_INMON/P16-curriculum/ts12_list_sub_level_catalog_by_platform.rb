require File.expand_path('../../../spec_helper', __FILE__)
require 'curriculum'

=begin
Verify listSubLevelCatalogByPlatform service works correctly
=end

describe "TS12 - listSubLevelCatalogByPlatform - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  subject = 'M'
  platform = 'explorer2'
  res = nil

  context 'TC12.001 - listSubLevelCatalogByPlatform - Successful Response' do
    sublevel_num = nil

    before :all do
      xml_res = Curriculum.list_sub_level_catalog_by_platform(caller_id, subject, platform)
      sublevel_num = xml_res.xpath('//catalog/sublevel-groups/sublevel').count
    end

    it "Verify 'listSubLevelCatalogByPlatform' calls successfully" do
      expect(sublevel_num).not_to eq(0)
    end
  end

  context 'TC12.002 - listSubLevelCatalogByPlatform - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Curriculum.list_sub_level_catalog_by_platform(caller_id2, subject, platform)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC12.003 - listSubLevelCatalogByPlatform - Subject - Empty' do
    subject3 = ''

    before :all do
      res = Curriculum.list_sub_level_catalog_by_platform(caller_id, subject3, platform)
    end

    it "Verify 'The service call returned with fault: The code:  is not a valid CyoSubjectType.  Valid subject codes are:  valid subjects:  M+ S M LA V SCI MUSC" do
      expect(res).to eq("The service call returned with fault: The code:  is not a valid CyoSubjectType.  Valid subject codes are: \nvalid subjects: \nM+\nS\nM\nLA\nV\nSCI\nMUSC\n")
    end
  end

  context 'TC12.004 - listSubLevelCatalogByPlatform - Subject - Nonexistence' do
    subject4 = 'nonexistence'

    before :all do
      res = Curriculum.list_sub_level_catalog_by_platform(caller_id, subject4, platform)
    end

    it "Verify 'The service call returned with fault: The code: nonexistence is not a valid CyoSubjectType.  Valid subject codes are:  valid subjects:  M+ S M LA V SCI MUSC" do
      expect(res).to eq("The service call returned with fault: The code: nonexistence is not a valid CyoSubjectType.  Valid subject codes are: \nvalid subjects: \nM+\nS\nM\nLA\nV\nSCI\nMUSC\n")
    end
  end

  context 'TC12.005 - listSubLevelCatalogByPlatform - Platform - Nonexistence' do
    platform5 = 'nonexistent_platform'
    catalog_num = catalog_content = nil

    before :all do
      xml_res = Curriculum.list_sub_level_catalog_by_platform(caller_id, subject, platform5)
      catalog_num = xml_res.xpath('//catalog').count
      catalog_content = xml_res.xpath('//catalog').text
    end

    it 'Check number of Catalog' do
      expect(catalog_num).to eq(1)
    end

    it 'Check content of Catalog' do
      expect(catalog_content).to eq('')
    end
  end

  context 'TC12.006 - listSubLevelCatalogByPlatform - Platform - Empty' do
    platform6 = ''
    catalog_num = catalog_content = nil

    before :all do
      xml_res = Curriculum.list_sub_level_catalog_by_platform(caller_id, subject, platform6)
      catalog_num = xml_res.xpath('//catalog').count
      catalog_content = xml_res.xpath('//catalog').text
    end

    it 'Check number of Catalog' do
      expect(catalog_num).to eq(1)
    end

    it 'Check content of Catalog' do
      expect(catalog_content).to eq('')
    end
  end
end
