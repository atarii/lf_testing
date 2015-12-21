class ChildManagement
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:namespace]

  def self.register_child(caller_id, session, customer_id, child_name = "Ronaldo#{LFCommon.get_current_time}")
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :register_child,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <customer-id>#{customer_id}</customer-id>
      <child id='1122' name='#{child_name}' dob='2001-10-08' grade='5' gender='male' can-upload='true'  titles='1' screen-name='D' locale='en-us' />"
    )
  end

  def self.register_child_credentials(caller_id, session, customer_id, child_name = "Ronaldo#{LFCommon.get_current_time}", child_username = "Ronaldo#{LFCommon.get_current_time}")
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :register_child,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <customer-id>#{customer_id}</customer-id>
      <child id='1122' name='#{child_name}' dob='2001-10-08' grade='5' gender='male' can-upload='true'  titles='1' screen-name='D' locale='en-us'>
        <credentials username='#{child_username}' password='123456'/>
      </child>"
    )
  end

  def self.register_child_smoketest(caller_id, session, customer_id, child_name, gender, grade)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :register_child,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <customer-id>#{customer_id}</customer-id>
      <child id='' name='#{child_name}' dob='2009-07-07-07:00' gender='#{gender}' grade='#{grade}' can-upload='true'/>"
    )
  end

  def self.register_child_info(register_child_res)
    {
      child_id: register_child_res.xpath('//child/@id').text,
      child_name: register_child_res.xpath('//child/@name').text,
      gender: register_child_res.xpath('//child/@gender').text,
      grade: register_child_res.xpath('//child/@grade').text
    }
  end

  def self.fetch_child(caller_id, session, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_child,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <child-id>#{child_id}</child-id>"
    )
  end

  def self.fetch_child_info(fetch_child_res)
    {
      child_id: fetch_child_res.xpath('//child/@id').text,
      child_name: fetch_child_res.xpath('//child/@name').text,
      gender: fetch_child_res.xpath('//child/@gender').text,
      grade: fetch_child_res.xpath('//child/@grade').text,
      locale: fetch_child_res.xpath('//child/@locale').text
    }
  end

  def self.list_children(caller_id, session, customer_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_children,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session><sort-type>creation date</sort-type>
      <customer-id>#{customer_id}</customer-id>"
    )
  end

  def self.lookup_child_by_username(caller_id, session, username, session_type = 'service')
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :lookup_child_by_username,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{session_type}'>#{session}</session>
      <username>#{username}</username>"
    )
  end

  def self.update_child(caller_id, session, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :update_child,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <child id='#{child_id}' name='Ronaldo#{LFCommon.get_current_time}' dob='2013-10-06-07:00' grade='2' gender='female' screen-name='new_scrname' locale='fr_FR' titles='' last-upload=''/>"
    )
  end

  def self.remove_child(caller_id, session, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :remove_child,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <child-id>#{child_id}</child-id>"
    )
  end

  def self.fetch_child_upload_summary(caller_id, session, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_child_upload_summary,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <child-id>#{child_id}</child-id>"
    )
  end

  def self.unlink_play_data(caller_id, session, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :unlink_play_data,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <child-id>#{child_id}</child-id>"
    )
  end

  def self.fetch_child_upload_history(caller_id, session_type, session, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_child_upload_history,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{session_type}'>#{session}</session>
      <child-id>#{child_id}</child-id>"
    )
  end

  def self.fetch_child_for_profile(caller_id, session, device_serial, slot)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_child_for_profile,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device>#{device_serial}</device>
      <slot>#{slot}</slot>"
    )
  end

  def self.list_platforms(caller_id, session, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_platforms,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <child-id>#{child_id}</child-id>"
    )
  end

  def self.list_titles(caller_id, session, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_titles,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <customer-id/>
      <child-id>#{child_id}</child-id>"
    )
  end
end
