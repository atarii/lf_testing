require File.expand_path('../../../spec_helper', __FILE__)
require 'survey'

=begin
Verify fetchSurvey service works correctly
=end

describe "TS01 - fetchSurvey - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  customer_id = '2773225'
  survey_id = '1'
  locale = 'en_US'
  response = nil

  context 'TC01.001 - fetchSurvey - SuccessfulResponse' do
    heading = id = question = answer = nil

    before :all do
      xml_response = Survey.fetch_survey(caller_id, customer_id, survey_id, locale)
      heading = xml_response.xpath('//survey/@heading').count
      id = xml_response.xpath('//survey/@id').count
      question = xml_response.xpath('//survey/question').count
      answer = xml_response.xpath('//survey/question/answer').count
    end

    it 'Check for existence of [@heading]' do
      expect(heading).not_to eq(0)
    end

    it 'Check for existence of [@id]' do
      expect(id).not_to eq(0)
    end

    it 'Check for existence of [question]' do
      expect(question).not_to eq(0)
    end

    it 'Check for existence of [answer]' do
      expect(answer).not_to eq(0)
    end
  end

  context 'TC01.002 - fetchSurvey - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      response = Survey.fetch_survey(caller_id2, customer_id, survey_id, locale)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(response).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - fetchSurvey - Invalid CustomerId' do
    customer_id3 = 'invalid'

    before :all do
      response = Survey.fetch_survey(caller_id, customer_id3, survey_id, locale)
    end

    it "Verify 'Invalid customer-id' error responses" do
      expect(response).to eq('Invalid customer-id')
    end
  end

  context 'TC01.004 - fetchSurvey - Invalid SurveyId' do
    survey_id4 = 'invalid'

    before :all do
      response = Survey.fetch_survey(caller_id, customer_id, survey_id4, locale)
    end

    it "Verify 'Survey with id invalid does not exist' error responses" do
      expect(response).to eq('Survey with id invalid does not exist')
    end
  end
end
