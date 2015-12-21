class MicromodStore
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:micromod_store][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:micromod_store][:namespace]

  def self.purchase(caller_id, device_serial, slot, package_id, package_name, checksum, href, type, status, cost)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :purchase,
      "<caller-id>#{caller_id}</caller-id>
      <device-serial>#{device_serial}</device-serial>
      <slot>#{slot}</slot>
      <package id='#{package_id}' name='#{package_name}' checksum='#{checksum}' href='#{href}' type='#{type}' status='#{status}'/>
      <cost>#{cost}</cost>"
    )
  end
end
