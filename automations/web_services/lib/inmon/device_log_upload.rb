require 'base64'

class DeviceLogUpload
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:device_log_upload][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:device_log_upload][:namespace]

  def self.upload_device_log(caller_id, filename, slot, device_serial, local_time, log_data)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :upload_device_log,
      "<caller-id>#{caller_id}</caller-id>
      <device-log filename='#{filename}' slot='#{slot}' device-serial='#{device_serial}' local-time='#{local_time}'/>
      <device-log-data>#{log_data}</device-log-data>"
    )
  end

  def self.upload_game_log(caller_id, child_id, local_time, filename, content_path)
    content = (File.exist? content_path) ? Base64.encode64(File.read(content_path)) : ''
    message = "<caller-id>#{caller_id}</caller-id>
              <log child-id='#{child_id}' local-time='#{local_time}' filename='#{filename}'/>
              <content>#{content}</content>"

    client = Savon.client(
      endpoint: LFSOAP::CONST_GAME_LOG_UPLOAD_ENDPOINT,
      namespace: LFSOAP::CONST_GAME_LOG_UPLOAD_NAMESPACE,
      log: true,
      pretty_print_xml: true
    )

    res = client.call(:upload_game_log, message: message)
    Nokogiri::XML(res.to_xml)
  rescue Savon::SOAPFault => error
    fault_str = error.to_hash[:fault][:faultstring].to_s
    fault_str << '' << error.to_hash[:fault][:detail][:access_denied] if fault_str == 'AccessDeniedFault'
    fault_str
  rescue => e
    e.message
  end
end
