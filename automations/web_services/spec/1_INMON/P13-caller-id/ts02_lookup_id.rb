require File.expand_path('../../../spec_helper', __FILE__)
require 'caller_id'

=begin
Verify lookupId service works correctly
=end

describe "TS02 - lookupId - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  title = 'UPCA'
  version = '1.6.2.0'
  build = Random.rand(100...1000).to_s
  new_caller_id = nil
  res = nil

  context 'TC02.001 - lookupId - Successful Response' do
    build1 = version1 = title1 = new_caller_id1 = nil

    before :all do
      xml_generate_id_res = CallerID.generate_id(caller_id, title, version, build)

      new_caller_id = xml_generate_id_res.xpath('//new-caller-id').text

      xml_lookup_id_res = CallerID.lookup_id(caller_id, new_caller_id)
      build1 = xml_lookup_id_res.xpath('//application').attr('build').text
      version1 = xml_lookup_id_res.xpath('//application').attr('version').text
      title1 = xml_lookup_id_res.xpath('//application').attr('title').text
      new_caller_id1 = xml_lookup_id_res.xpath('//application/ns3:caller-id', 'ns3' => 'http://services.leapfrog.com/inmon/callerid/').text
    end

    it "Check 'generateId' calls successfully" do
      expect(new_caller_id).not_to be_empty
    end

    it 'Check content of CallerID' do
      expect(new_caller_id1).to eq(new_caller_id)
    end

    it 'Check content of version' do
      expect(version1).to eq(version)
    end

    it 'Check content of Title' do
      expect(title1).to eq(title)
    end

    it 'Check content of Build' do
      expect(build1).to eq(build)
    end
  end

  context 'TC02.002 - lookupId - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CallerID.lookup_id(caller_id2, new_caller_id)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC02.003 - lookupId - Invalid Request' do
    before :all do
      res = CallerID.lookup_id(caller_id, '')
    end

    it "Verify 'Unexpected internal error' error responses" do
      expect(res).to eq('Unexpected internal error')
    end
  end

  context 'TC02.004 - lookupId - Nonexistent CallerID' do
    new_caller_id4 = 'nonexistence'

    before :all do
      res = CallerID.lookup_id(caller_id, new_caller_id4)
    end

    it "Verify 'Unexpected internal error' error responses" do
      expect(res).to eq('Unexpected internal error')
    end
  end
end
