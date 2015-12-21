class DeviceProfileContent
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_content][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_content][:namespace]

  def self.fetch_content_index(caller_id, session, device_serial, slot)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_content_index,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <source device-serial='#{device_serial}' slot='#{slot}' product-id=''/>"
    )
  end

  def self.request_interests(caller_id, device_serial, slot, platform)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :request_interests,
      "<caller-id>#{caller_id}</caller-id>
      <source device-serial='#{device_serial}' slot='#{slot}' product-id='0'/>
      <platform>#{platform}</platform>"
    )
  end

  def self.upload_content(caller_id, session, device_serial, slot, package_id, content)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :upload_content,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <source device-serial='#{device_serial}' slot='#{slot}' product-id=''/>
      <package id='#{package_id}' name='' checksum='' href='' type='' status='' lictype='' productId='' platform='leappad3' locale=''/>
      <content>#{content}</content>"
    )
  end

  def self.upload_content_wo_handle_exception(caller_id, session, device_serial, slot, package_id, content)
    content_path = "#{Misc::CONST_PROJECT_PATH}/data/#{content}"
    content = File.exist? content_path ? Base64.encode64(File.read(content_path)) : content

    client = Savon.client(
      endpoint: @endpoint,
      namespace: @namespace,
      log: true,
      pretty_print_xml: true,
      namespace_identifier: :man
    )

    message = <<-INTERPOLATE_HEREDOC.strip_heredoc
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <source device-serial='#{device_serial}' slot='#{slot}' product-id=''/>
      <package id='#{package_id}' name='' checksum='c14c8837310eb85926fd82e711cfb2a98c7ce436' href='' type='' status='' lictype='' productId='' platform='' locale=''/>
      <content>#{content}</content>"
    INTERPOLATE_HEREDOC

    client.call(:upload_content, message: message)
  end
end
