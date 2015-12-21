class OwnerManagement
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:namespace]

  def self.claim_device(caller_id, session, _customer_id, device_serial, platform, slot, profile_name, child_id, dob = Time.now, grade = '5', gender = 'male')
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :claim_device,
      "<caller-id>#{caller_id}</caller-id>
       <session type='service'>#{session}</session>
       <device serial='#{device_serial}' auto-create='false' product-id='0' platform='#{platform}' pin=''>
          <profile slot='#{slot}' name='#{profile_name}' weak-id='1' uploadable='true' claimed='true' child-id='#{child_id}' dob='#{dob}' grade='#{grade}' gender='#{gender}' auto-create='false' points='0' rewards='0'/>
       </device>"
    )
  end

  def self.claim_rio_device(caller_id, session, email, device_serial, profile_name, child_id, grade = '5', gender = 'male', dob = Time.now)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :claim_device,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device serial='#{device_serial}' product-id='0' platform='leappad3' auto-create='true'>
        <profile slot='0' name='#{profile_name}' uploadable='false' claimed='false' dob='#{dob}' grade='#{grade}' gender='#{gender}' auto-create='true' weak-id='0' points='0' rewards='0' child-id='#{child_id}'/>
        <properties>
          <property key='erasesize' value='8192'/>
          <property key='parentemail' value='#{email}'/>
          <property key='model' value='1'/>
          <property key='writesize' value='2097152'/>
        </properties>
      </device>"
    )
  end

  def self.claim_device_info(claim_device_res)
    {
      device_serial: claim_device_res.xpath('//claimed-device').attr('serial').text,
      platform: claim_device_res.xpath('//claimed-device').attr('platform').text
    }
  end

  def self.unclaim_device(caller_id, session, type, device_serial)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :unclaim_device,
      "<caller-id>#{caller_id}</caller-id>
      <session type='#{type}'>#{session}</session>
      <device-serial>#{device_serial}</device-serial>
      <release-licenses>true</release-licenses>"
    )
  end
end
