class LicenseManagement
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:license_management][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:license_management][:namespace]

  def self.install_package(caller_id, device_serial, slot, package_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :install_package,
      "<caller-id>#{caller_id}</caller-id>
      <device-serial>#{device_serial}</device-serial>
      <slot>#{slot}</slot>
      <package id='#{package_id}' name='' checksum='' href='href' type='purchase' status='' lictype='' productId='' platform='' locale=''/>"
    )
  end

  def self.check_install_package(response, package_id, expected)
    package_count = response.xpath('//package').count

    (1..package_count).each do |i|
      next if response.xpath('//package[' + i.to_s + ']').attr('id').text != package_id

      status = response.xpath('//package[' + i.to_s + ']').attr('status').text
      return 1 if status == expected # package_id exist and correct status
      return 0 # package_id exist but incorrect status
    end

    2 # package is not exist
  end

  def self.check_eligibility(caller_id, cus_key, device_serial, package_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :check_eligibility,
      "<caller-id>#{caller_id}</caller-id>
      <cust-key>#{cus_key}</cust-key>
      <device-serial>#{device_serial}</device-serial>
      <package id='#{package_id}' type='Application' href='' platform='' name=''/>"
    )
  end

  def self.child_inventory(caller_id, session_type, session, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :child_inventory,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{session_type}'>#{session}</session>
      <child-id>#{child_id}</child-id>"
    )
  end

  def self.fetch_restricted_licenses(caller_id, session_type, session, cust_key, device_serial)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_restricted_licenses,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{session_type}'>#{session}</session>
      <cust-key>#{cust_key}</cust-key>
      <device-serial>#{device_serial}</device-serial>"
    )
  end

  def self.grant_license(caller_id, session, cust_key, device_serial, package_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :grant_license,
      "<transaction id='aaaaaaaa' timestamp='' amount='1'/>
      <caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <cust-key>#{cust_key}</cust-key>
      <device-serial>#{device_serial}</device-serial>
      <slot>0</slot>
      <package id='#{package_id}'/>
      <license-type>purchase</license-type>
      <access-level>parent</access-level>"
    )
  end

  def self.install_package_for_child(caller_id, session, child_id, package_id, href)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :install_package_for_child,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <child-id>#{child_id}</child-id>
      <package id='#{package_id}' name='' checksum='' href='#{href}' type='purchase' status='' lictype='' productId='' platform='' locale=''/>"
    )
  end

  def self.revoke_license(caller_id, session, license_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :revoke_license,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <license-id>#{license_id}</license-id>"
    )
  end
end
