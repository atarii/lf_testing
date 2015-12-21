require File.expand_path('../../../spec_helper', __FILE__)
require 'caller_id'

=begin
Verify generateId service works correctly
=end

describe "TS01 - generateId - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  title = 'UPCA'
  version = '1.6.2.0'
  build = LFCommon.get_current_time
  res = nil

  context 'TC01.001 - generateId - Successful Response' do
    new_caller_id = nil

    before :all do
      xml_res = CallerID.generate_id(caller_id, title, version, build)
      new_caller_id = xml_res.xpath('//new-caller-id').text
    end

    it 'Check for existence of new-caller-id' do
      expect(new_caller_id).not_to be_empty
    end
  end

  context 'TC01.002 - generateId - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CallerID.generate_id(caller_id2, title, version, build)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - generateId - Invalid Request' do
    before :all do
      res = CallerID.generate_id(caller_id, '', '', '')
    end

    it "Verify 'Unexpected internal error' error responses" do
      expect(res).to eq('Unexpected internal error')
    end
  end

  context 'TC01.004 - generateId - Invalid Data Type(@build)' do
    build4 = 'invalid'

    before :all do
      res = CallerID.generate_id(caller_id, title, version, build4)
    end

    it "Verify 'Unmarshalling Error: Not a number: invalid' error responses" do
      expect(res).to eq('Unmarshalling Error: Not a number: invalid ')
    end
  end

  context 'TC01.005 - generateId - @build overflow' do
    build5 = '12345' + LFCommon.get_current_time
    new_caller_id = nil
    build1 = version1 = title1 = new_caller_id1 = nil

    before :all do
      xml_generate_id_res = CallerID.generate_id(caller_id, title, version, build5)

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
      if build1 != build
        expect('#36345: Web Services: caller-id: generateId: The services call  return successful responses with negative value of @build when calling service with @build value is out of range').to eq(build1 + ' should equal ' + build)
      else
        expect(build1).to eq(build)
      end
    end
  end

  context 'TC01.006 - generateId - Duplicate Build' do
    before :all do
      res = CallerID.generate_id(caller_id, title, version, build)
    end

    it "Verify 'Unexpected internal error' error responses" do
      expect(res).to eq('Unexpected internal error')
    end
  end
end
