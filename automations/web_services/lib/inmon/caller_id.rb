class CallerID
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:caller_id][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:caller_id][:namespace]

  def self.generate_id(caller_id, title, version, build)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :generate_id,
      "<caller-id>#{caller_id}</caller-id>
      <application title='#{title}' version='#{version}' build='#{build}'>
        <cal:caller-id xmlns:cal='http://services.leapfrog.com/inmon/callerid/'/>
      </application>"
    )
  end

  def self.lookup_id(caller_id, query)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :lookup_id,
      "<caller-id>#{caller_id}</caller-id>
      <query>#{query}</query>"
    )
  end
end
