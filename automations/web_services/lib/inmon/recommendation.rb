class Recommendation
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:recommendation][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:recommendation][:namespace]

  def self.fetch_connected_products(caller_id, customer_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_connected_products,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id>#{customer_id}</customer-id>
      <sort-type/>"
    )
  end

  def self.recommend_engaged_skills(caller_id, username, customer_id, sort_type)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :recommend_engaged_skills,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>
      <customer-id>#{customer_id}</customer-id>
      <sort-type>#{sort_type}</sort-type>"
    )
  end

  def self.recommend_needed_skills(caller_id, customer_id, sort_type)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :recommend_needed_skills,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id>#{customer_id}</customer-id>
      <sort-type>#{sort_type}</sort-type>"
    )
  end

  def self.recommend_products(caller_id, session, rule_type)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :recommend_products,
      "<caller-id>#{caller_id}</caller-id>
      <session type='child'>#{session}</session>
      <rule-type>#{rule_type}</rule-type>
      <args key='leappad' value='en_US'>
        <values>en_US</values>
      </args>"
    )
  end
end
