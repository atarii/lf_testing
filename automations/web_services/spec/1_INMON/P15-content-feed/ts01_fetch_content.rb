require File.expand_path('../../../spec_helper', __FILE__)
require 'content_feed'

=begin
Verify fetchContent service works correctly
=end

describe "TS01 - fetchContent - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  parent_id = '2773426'
  child_id = '2773427'
  title = ''
  content_type = 'activity'
  res = nil

  context 'TC01.001 - fetchContent - Successful Response' do
    content_exist = nil

    before :all do
      xml_res = ContentFeed.fetch_content(caller_id, parent_id, child_id, title, content_type)
      content_exist = xml_res.xpath('//content').count
    end

    it 'Check for existence of [content]' do
      expect(content_exist).not_to eq(0)
    end
  end

  context 'TC01.002 - fetchContent - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = ContentFeed.fetch_content(caller_id2, parent_id, child_id, title, content_type)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - fetchContent - Invalid ParentID' do
    parent_id3 = '123123'

    before :all do
      res = ContentFeed.fetch_content(caller_id, parent_id3, child_id, title, content_type)
    end

    it "Verify 'Child '...' doesn't belong to parent '...'' error responses" do
      expect(res).to eq("Child '" + child_id + "' doesn't belong to parent '" + parent_id3 + "'")
    end
  end

  context 'TC01.004 - fetchContent - Invalid ChildID' do
    child_id4 = '123123'

    before :all do
      res = ContentFeed.fetch_content(caller_id, parent_id, child_id4, title, content_type)
    end

    it "Verify 'Child '...' doesn't belong to parent '...'' error responses" do
      expect(res).to eq("Child '" + child_id4 + "' doesn't belong to parent '" + parent_id + "'")
    end
  end

  context 'TC01.005 - fetchContent - Parent Id is null' do
    parent_id5 = ''

    before :all do
      res = ContentFeed.fetch_content(caller_id, parent_id5, child_id, title, content_type)
    end

    it "Verify 'Child '...' doesn't belong to parent '...'' error responses" do
      expect(res).to eq("Child '" + child_id + "' doesn't belong to parent '0'")
    end
  end

  context 'TC01.006 - fetchContent - Parent Id is so long' do
    parent_id6 = 'DeprecatedChildManagementPort fetchChild fetchChildSummaryInfo updateChild listChildren removeChild listDeviceLogUploads listTitles unlinkPlayData fetchChildForProfile registerChild'

    before :all do
      res = ContentFeed.fetch_content(caller_id, parent_id6, child_id, title, content_type)
    end

    it "Verify 'Child '...' doesn't belong to parent '...'' error responses" do
      expect(res).to eq("Child '" + child_id + "' doesn't belong to parent '0'")
    end
  end

  context 'TC01.007 - fetchContent - Parent Id is special characters' do
    parent_id7 = '@##$$%%'

    before :all do
      res = ContentFeed.fetch_content(caller_id, parent_id7, child_id, title, content_type)
    end

    it "Verify 'Child '...' doesn't belong to parent '...'' error responses" do
      expect(res).to eq("Child '" + child_id + "' doesn't belong to parent '0'")
    end
  end

  context 'TC01.008 - fetchContent - Parent Id is negative numbers' do
    parent_id8 = '-123123'

    before :all do
      res = ContentFeed.fetch_content(caller_id, parent_id8, child_id, title, content_type)
    end

    it "Verify 'Child '...' doesn't belong to parent '...'' error responses" do
      expect(res).to eq("Child '" + child_id + "' doesn't belong to parent '" + parent_id8 + "'")
    end
  end

  context 'TC01.009 - fetchContent - Child id is null' do
    child_id9 = ''

    before :all do
      res = ContentFeed.fetch_content(caller_id, parent_id, child_id9, title, content_type)
    end

    it "Verify 'Child '...' doesn't belong to parent '...'' error responses" do
      expect(res).to eq("Child '0' doesn't belong to parent '" + parent_id + "'")
    end
  end

  context 'TC01.010 - fetchContent - Child id is so long' do
    child_id10 = 'DeprecatedChildManagementPort fetchChild fetchChildSummaryInfo updateChild listChildren removeChild listDeviceLogUploads listTitles unlinkPlayData fetchChildForProfile registerChild'

    before :all do
      res = ContentFeed.fetch_content(caller_id, parent_id, child_id10, title, content_type)
    end

    it "Verify 'Child '...' doesn't belong to parent '...'' error responses" do
      expect(res).to eq("Child '0' doesn't belong to parent '" + parent_id + "'")
    end
  end

  context 'TC01.011 - fetchContent - Child id is special characters' do
    child_id11 = '@!##'

    before :all do
      res = ContentFeed.fetch_content(caller_id, parent_id, child_id11, title, content_type)
    end

    it "Verify 'Child '...' doesn't belong to parent '...'' error responses" do
      expect(res).to eq("Child '0' doesn't belong to parent '" + parent_id + "'")
    end
  end

  context 'TC01.012 - fetchContent - Child id is negative numbers' do
    child_id12 = '-799'

    before :all do
      res = ContentFeed.fetch_content(caller_id, parent_id, child_id12, title, content_type)
    end

    it "Verify 'Child '...' doesn't belong to parent '...'' error responses" do
      expect(res).to eq("Child '" + child_id12 + "' doesn't belong to parent '" + parent_id + "'")
    end
  end
end
