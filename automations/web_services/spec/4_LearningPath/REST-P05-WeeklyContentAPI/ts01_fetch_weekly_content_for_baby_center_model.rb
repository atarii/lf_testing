require File.expand_path('../../../spec_helper', __FILE__)
require 'weekly_content'

=begin
REST call: Verify fetchWeeklyContent for baby Center model service works correctly
=end

describe "TS01 - fetchWeeklyContent - For Baby Center Model - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  res = nil

  context 'TC01.001 - fetchWeeklyContent - Successful Response' do
    before :all do
      res = WeeklyContent.fetch_weekly_content_baby_center(caller_id, '50')
    end

    it 'Valid HTTP Status Codes = true' do
      expect(res['status']).to eq(true)
    end
  end

  context 'TC01.002 - fetchWeeklyContent - Invalid weekSinceBirth' do
    week_since_birth2 = '21423423'

    before :all do
      res = WeeklyContent.fetch_weekly_content_baby_center(caller_id, week_since_birth2)
    end

    it "Verify error message is 'Cannot find a milestone for this age(months) : 4943866'" do
      expect(res['data']['message']).to eq('Cannot find a milestone for this age(months) : 4943866')
    end
  end

  context 'TC01.003 - fetchWeeklyContent - weekSinceBirth - greater than 103' do
    it 'Ignore will-not-fix defect: UPC# 37264 Web Services: Learning Path/REST-P05-WeeklyContentAPI: The service returns null data when performing fetchWeeklyContent REST call with @weekSinceBirth is greater than 103' do
    end
  end

  context 'TC01.004 - fetchWeeklyContent - weekSinceBirth is characters' do
    week_since_birth4 = 'invalid'

    before :all do
      res = WeeklyContent.fetch_weekly_content_baby_center(caller_id, week_since_birth4)
    end

    it 'Match content of [faultCode]' do
      expect(res['data']['faultCode']).to eq('OOPS')
    end

    it "Verify error message is 'Failed to convert value of type 'java.lang.String' to required type 'int'; nested exception is java.lang.NumberFormatException: For input string: \"" + week_since_birth4 + "\"'" do
      expect(res['data']['message']).to eq("Failed to convert value of type 'java.lang.String' to required type 'int'; nested exception is java.lang.NumberFormatException: For input string: \"" + week_since_birth4 + "\"")
    end
  end

  context 'TC01.005 - fetchWeeklyContent - weekSinceBirth is special characters' do
    week_since_birth5 = '%21%40%40%23%40%40%23' # = '!@@\#@@#'

    before :all do
      res = WeeklyContent.fetch_weekly_content_baby_center(caller_id, week_since_birth5)
    end

    it 'Match content of [faultCode]' do
      expect(res['data']['faultCode']).to eq('OOPS')
    end

    it "Verify error message is 'Failed to convert value of type 'java.lang.String' to required type 'int'; nested exception is java.lang.NumberFormatException: For input string: \"!@@\#@@#\"'" do
      expect(res['data']['message']).to eq("Failed to convert value of type 'java.lang.String' to required type 'int'; nested exception is java.lang.NumberFormatException: For input string: \"!@@\#@@#\"")
    end
  end
end
