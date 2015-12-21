class DeviceManagement
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:namespace]

  def self.generate_serial(platform = 'LP')
    "#{platform}xyz123321xyz" + LFCommon.get_current_time
  end

  def self.anonymous_update_profiles(caller_id, device_serial, platform, slot, profile_name, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :anonymous_update_profiles,
      "<caller-id>#{caller_id}</caller-id>
      <device serial='#{device_serial}' product-id='0' platform='#{platform}' auto-create='false' pin='1111'>
        <profile slot='#{slot}' name='#{profile_name}' child-id='#{child_id}' auto-create='false' points='0' rewards='0' weak-id='1' uploadable='false' claimed='true' dob='2005-9-05' grade='1' gender='female'/>
      </device>"
    )
  end

  def self.fetch_device(caller_id, device_serial, platform)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_device,
      "<caller-id>#{caller_id}</caller-id>
      <device serial='#{device_serial}' product-id='' platform='#{platform}' auto-create='false' pin=''>
        <properties>
        </properties>
      </device>"
    )
  end

  def self.reset_device(caller_id, session, device_serial, release_licenses)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :reset_device,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device-serial>#{device_serial}</device-serial>
      <release-licenses>#{release_licenses}</release-licenses>"
    )
  end

  def self.list_nominated_devices(caller_id, session, type)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_nominated_devices,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{type}'>#{session}</session>
      <type>ANY</type>
      <get-child-info>true</get-child-info>"
    )
  end

  def self.nominate_device(caller_id, session, type, device_serial, platform)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :nominate_device,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{type}'>#{session}</session>
      <device serial='#{device_serial}' product-id='' platform='#{platform}' auto-create='false' pin='1111'/>"
    )
  end

  def self.unnominate_device(caller_id, session, type, device_serial, platform)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :unnominate_device,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{type}'>#{session}</session>
      <device serial='#{device_serial}' product-id='0' platform='#{platform}'/>"
    )
  end

  def self.update_profiles(caller_id, session, type, device_serial, platform, slot, profile_name, child_id, grade = '5', gender = 'male')
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :update_profiles,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{type}'>#{session}</session>
      <device serial='#{device_serial}' platform='#{platform}' product-id='0' auto-create='true'>
        <profile slot='#{slot}' name='#{profile_name}' points='0' rewards='0' weak-id='1' uploadable='true' claimed='true' dob='2014-06-09+07:00' grade='#{grade}' gender='#{gender}' child-id='#{child_id}' auto-create='true'/>
      </device>"
    )
  end

  def self.update_profiles_with_properties(caller_id, email, session, type, device_serial, platform, slot, profile_name, dob, grade, gender, child_id, pin = '1111')
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :update_profiles,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{type}'>#{session}</session>
      <device serial='#{device_serial}' platform='#{platform}' product-id='0' auto-create='true'>
        <profile slot='#{slot}' name='#{profile_name}' points='0' rewards='0' weak-id='1' uploadable='true' claimed='true' dob='#{dob}' grade='#{grade}' gender='#{gender}' child-id='#{child_id}' auto-create='true'/>
        <properties><property key='pin' value='#{pin}'/><property key='parentemail' value='#{email}'/></properties>
      </device>"
    )
  end

  def self.register_device(caller_id, device_serial, platform)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :update_profiles,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'></session>
      <device serial='#{device_serial}' platform='#{platform}' product-id='0' auto-create='false'>
      </device>"
    )
  end

  def self.fetch_device_activation_code(caller_id, device_serial)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_device_activation_code,
      "<caller-id>#{caller_id}</caller-id>
      <token type='device-serial'>#{device_serial}</token>"
    )
  end

  def self.lookup_device_by_activation_code(caller_id, session, act_code)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :lookup_device_by_activation_code,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <token type=''/>
      <activation-code>#{act_code}</activation-code>"
    )
  end

  # @param [XmlDocument] xml
  # @param [Object] xpath
  # @return [Array] Array of children
  def self.get_children_node_values(xml, xpath)
    arr = []
    items = xml.xpath(xpath)
    items.map do |e|
      arr.push(
        slot: e.at_xpath('@slot').content,
        name: e.at_xpath('@name').content,
        gender: e.at_xpath('@gender').content,
        grade: e.at_xpath('@grade').content,
        dob: (e.at_xpath('@dob').content)[0, 10]
      )
    end

    arr
  end
end
