require File.expand_path('../../../spec_helper', __FILE__)
require 'weekly_content'

=begin
REST call: Verify fetchWeeklyContent for Milestome model service works correctly
=end

describe "TS02 - fetchWeeklyContent - For Milestone Model - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  milestone = 'c5d91f7f-e92b-45fa-9b7b-103e04b302fe'
  calendar_week = '1'
  res = nil

  context 'TC02.001 - fetchWeeklyContent - Successful Response' do
    before :all do
      res = WeeklyContent.fetch_weekly_content_milestones(caller_id, milestone, calendar_week)
    end

    it 'Valid HTTP Status Codes = true' do
      expect(res['status']).to eq(true)
    end
  end

  context 'TC02.002 - fetchWeeklyContent - Invalid calendarWeek' do
    calendar_week2 = '12345'

    before :all do
      res = WeeklyContent.fetch_weekly_content_milestones(caller_id, milestone, calendar_week2)
    end

    it "Verify error message is 'Invalid calendar week : " + calendar_week2 + "'" do
      expect(res['data']['message']).to eq('Invalid calendar week : ' + calendar_week2)
    end
  end

  context 'TC02.003 - fetchWeeklyContent - Invalid MilestoneID' do
    milestone3 = '52352352'

    before :all do
      res = WeeklyContent.fetch_weekly_content_milestones(caller_id, milestone3, calendar_week)
    end

    it "Verify error message is 'Invalid Milestone : " + milestone3 + "'" do
      expect(res['data']['message']).to eq('Invalid Milestone : ' + milestone3)
    end
  end

  context 'TC02.004 - fetchWeeklyContent - calendarWeek is negative numbers' do
    calendar_week4 = '-10'

    before :all do
      res = WeeklyContent.fetch_weekly_content_milestones(caller_id, milestone, calendar_week4)
    end

    it "Verify error message is 'Invalid calendar week : " + calendar_week4 + "'" do
      expect(res['data']['message']).to eq('Invalid calendar week : ' + calendar_week4)
    end
  end

  context 'TC02.005 - fetchWeeklyContent - calendarWeek is special characters' do
    calendar_week5 = '%21%40%40%23%40%40%23' # = '!@@\#@@#'

    before :all do
      res = WeeklyContent.fetch_weekly_content_milestones(caller_id, milestone, calendar_week5)
    end

    it "Verify error message is 'Failed to convert value of type 'java.lang.String' to required type 'int'; nested exception is java.lang.NumberFormatException: For input string: \"!@@\#@@#\"'" do
      expect(res['data']['message']).to eq("Failed to convert value of type 'java.lang.String' to required type 'int'; nested exception is java.lang.NumberFormatException: For input string: \"!@@\#@@#\"")
    end
  end
end
