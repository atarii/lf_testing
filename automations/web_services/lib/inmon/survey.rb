class Survey
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:survey][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:survey][:namespace]

  def self.fetch_survey(caller_id, customer_id, survey_id, locale)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_survey,
      "<caller-id>#{caller_id}</caller-id>
      <customer-id>#{customer_id}</customer-id>
      <survey-id>#{survey_id}</survey-id>
      <locale>#{locale}</locale>"
    )
  end

  def self.submit_survey(caller_id, customer_id, survey_id, sort_order, question_id, answer_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :submit_survey,
      "<caller-id>#{caller_id}</caller-id>
      <customer-id>#{customer_id}</customer-id>
      <survey id='#{survey_id}' locale='en-gb' heading='asd'>
        <question id='#{question_id}' text='What is this?' multiple='false' sort-order='1'>
          <answer id='#{answer_id}' selected='false' sort-order='#{sort_order}'>I don't know</answer>
        </question>
      </survey>"
    )
  end
end
