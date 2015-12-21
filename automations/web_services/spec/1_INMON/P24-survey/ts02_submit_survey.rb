require File.expand_path('../../../spec_helper', __FILE__)
require 'survey'

=begin
Verify submitSurvey service works correctly
=end

describe "TS02 - submitSurvey - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  customer_id = '2773225'
  survey_id = '1'
  sort_order = '1'
  question_id = '4'
  answer_id = '1'
  locale = 'en-gb'
  response = nil

  context 'TC02.001 - submitSurvey - SuccessfulResponse' do
    heading = id = question = answer = nil

    before :all do
      Survey.submit_survey(caller_id, customer_id, survey_id, sort_order, question_id, answer_id)

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

  context 'TC02.002 - submitSurvey - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      response = Survey.submit_survey(caller_id2, customer_id, survey_id, sort_order, question_id, answer_id)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(response).to eq('Error while checking caller id')
    end
  end

  context 'TC02.003 - submitSurvey - Invalid Survey Id' do
    survey_id3 = 'invalid'

    before :all do
      response = Survey.submit_survey(caller_id, customer_id, survey_id3, sort_order, question_id, answer_id)
    end

    it "Verify 'Survey with id invalid_ does not exist' error responses" do
      expect(response).to eq('Survey with id invalid does not exist')
    end
  end

  context 'TC02.004 - submitSurvey - Invalid question id' do
    question_id4 = 'invalid'

    before :all do
      response = Survey.submit_survey(caller_id, customer_id, survey_id, sort_order, question_id4, answer_id)
    end

    it "Verify 'At least one of the request questions does not correspond to the specified survey' error responses" do
      expect(response).to eq('At least one of the request questions does not correspond to the specified survey')
    end
  end

  context 'TC02.005 - submitSurvey - Invalid answer id' do
    answer_id5 = 'invalid'

    before :all do
      response = Survey.submit_survey(caller_id, customer_id, survey_id, sort_order, question_id, answer_id5)
    end

    it "Verify 'One of the answers in the request does not correspond to the enclosing question error responses" do
      expect(response).to eq('One of the answers in the request does not correspond to the enclosing question')
    end
  end

  context 'TC02.006 - submitSurvey - Invalid Sort-order' do
    sort_order6 = 'invalid'

    before :all do
      response = Survey.submit_survey(caller_id, customer_id, survey_id, sort_order6, question_id, answer_id)
    end

    it 'Unmarshalling Error: Not a number: invalid' do
      expect(response).to eq('Unmarshalling Error: Not a number: ' + sort_order6 + ' ')
    end
  end
end
