class PackageManagement
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:package_management][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:package_management][:namespace]

  def self.authorize_installation(caller_id, session, device_serial, package_id, package_name)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :authorize_installation,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device-serial>#{device_serial}</device-serial>
      <slot>0</slot>
      <package id='#{package_id}' name='#{package_name}' checksum='' href='' type='' status='' lictype='' productId='' platform='' locale=''/>"
    )
  end

  def self.cart_buddies(caller_id, device_serial, package_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :cart_buddies,
      "<caller-id>#{caller_id}</caller-id>
      <device-serial>#{device_serial}</device-serial>
      <package-id>#{package_id}</package-id>"
    )
  end

  def self.delete_installation(caller_id, session, device_serial, package_id, package_name, package_type)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :delete_installation,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device-serial>#{device_serial}</device-serial>
      <slot>0</slot>
      <package id='#{package_id}' name='#{package_name}' checksum='' href='' type='#{package_type}' status='' lictype='' productId='0' platform='' locale=''/>"
    )
  end

  def self.check_delete_installation(delete_install_resp, package_id, expected)
    package_count = delete_install_resp.xpath('//device/package').count

    (1..package_count).each do |i|
      if delete_install_resp.xpath('//device/package[' + i.to_s + ']').attr('id').text == package_id
        status = delete_install_resp.xpath('//device/package[' + i.to_s + ']').attr('status').text
        return (status == expected) ? 1 : 0 # return 1 if package_id exist and correct status else return 0
      end
    end

    0 # package_id not exist
  end

  def self.device_inventory(caller_id, type, device_serial, license_type)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :device_inventory,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{type}'></session>
      <device-serial>#{device_serial}</device-serial>
      <include-license-type>#{license_type}</include-license-type>"
    )
  end

  def self.package_dependencies(caller_id, package_id, package_name)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :package_dependencies,
      "<caller-id>#{caller_id}</caller-id>
      <package>
        <package version-date='' id='#{package_id}' name='#{package_name}' uri='' checksum='' code='' size=''/>
      </package>"
    )
  end

  def self.package_dot_spaces(caller_id, locale, platform, package_title, package_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :package_dot_spaces,
      "<caller-id>#{caller_id}</caller-id>
      <locale>#{locale}</locale>
      <platform>#{platform}</platform>
      <dotspace refresh='false'>
        <package-title>#{package_title}</package-title>
        <package-id>#{package_id}</package-id>
      </dotspace>"
    )
  end

  def self.package_rewards(caller_id, device_serial, product_id, platform, slot, weak_id, child_id, property_value)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :package_rewards,
      "<caller-id>#{caller_id}</caller-id>
      <device serial='#{device_serial}' product-id='#{product_id}' platform='#{platform}' auto-create='false' pin='1111'>
        <profile slot='#{slot}' name='DATA-TEST' points='0' rewards='0' weak-id='#{weak_id}' uploadable='false' claimed='true' dob='' grade='' gender='' child-id='#{child_id}' auto-create='false'/>
        <properties>
          <property key='packageid' value='#{property_value}'/>
        </properties>
      </device>
      <locale>en-US</locale>
      <product-id>0</product-id>"
    )
  end

  def self.package_versions(caller_id, package_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :package_versions,
      "<caller-id>#{caller_id}</caller-id>
      <package-version>
        <package name='' code='' uri='' checksum='' id='#{package_id}' universal-id='' version='' version-date='' min-version='' status='' display-name='' hidden='true' size='' preview-image-url='' category='' locale=''>
        </package>
        <dependencies>
        </dependencies>
      </package-version>"
    )
  end

  # Check package version exist
  def self.check_pkg_version(pkg_version_resp, package_id)
    pkg_version_count = pkg_version_resp.xpath('//package-version').count

    (1..pkg_version_count).each do |i|
      if pkg_version_resp.xpath('//package-version[' + i.to_s + ']/package').attr('id').text == package_id
        return (pkg_version_resp.xpath('//package-version[' + i.to_s + ']/package').attr('version').text.blank?) ? 0 : 1 # if = return 1 else return 0
      end
    end

    0 # package_id not exist
  end

  def self.remove_installation(caller_id, session, device_serial, slot, package_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :remove_installation,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device-serial>#{device_serial}</device-serial>
      <slot>#{slot}</slot>
      <package id='#{package_id}' name='' checksum='' href='' type='Application' status='' lictype='' productId='' platform='' locale=''/>"
    )
  end

  def self.check_remove_installation(rm_install_resp, package_id, expected)
    package_count = rm_install_resp.xpath('//device/package').count

    (1..package_count).each do |i|
      if rm_install_resp.xpath('//device/package[' + i.to_s + ']').attr('id').text == package_id
        status = rm_install_resp.xpath('//device/package[' + i.to_s + ']/@status').text
        return (status == expected) ? 1 : 0 # return 1 if package_id exist and correct status else return 0
      end
    end

    0 # package_id not exist
  end

  def self.report_installation(caller_id, session, device_serial, slot, package_id, license_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :report_installation,
      "
      <caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device-serial>#{device_serial}</device-serial>
      <slot>#{slot}</slot>
      <package id='#{package_id}' name='' checksum='' href='' type='' status='' lictype='' productId='' platform='' locale=''/>
      <license id='#{license_id}' key='' type='' count='' package-id='' grant-date=''/>"
    )
  end
end
