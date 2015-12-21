class Authentication
  CONST_CALLER_ID = ENV['CONST_CALLER_ID']

  def initialize(env = 'QA')
    @service_info = CommonMethods.service_info :authentication_management, env
  end

  def acquire_service_session(username, password)
    CommonMethods.soap_call(
      @service_info[:endpoint],
      @service_info[:namespace],
      :acquire_service_session,
      "<caller-id>#{CONST_CALLER_ID}</caller-id>
      <credentials username='#{username}' password='#{password}' hint='' expiration=''/>"
    )
  end

  def get_service_session(username, password)
    session_xml = CommonMethods.soap_call(
      @service_info[:endpoint],
      @service_info[:namespace],
      :acquire_service_session,
      "<caller-id>#{CONST_CALLER_ID}</caller-id>
      <credentials username='#{username}' password='#{password}' hint='' expiration=''/>"
    )

    return session_xml if session_xml[0] == 'error'
    session_xml.at_xpath('//session').text
  end
end
