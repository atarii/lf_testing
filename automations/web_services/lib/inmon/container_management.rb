class ContainerManagement
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:container_management][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:container_management][:namespace]

  def self.create_container(caller_id, customer_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :create_container,
      "<caller-id>#{caller_id}</caller-id>
      <customer-id>#{customer_id}</customer-id>"
    )
  end

  def self.add_package(caller_id, container_id, package_name, code, uri, checksum)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :add_package,
      "<caller-id>#{caller_id}</caller-id>
      <container id='#{container_id}'/>
      <package name='#{package_name}' code='#{code}' uri='#{uri}' checksum='#{checksum}' id='' version='' min-version='' status='' locale=''/>"
    )
  end
end
