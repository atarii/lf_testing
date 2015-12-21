class CustomerManagement
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:customer_management][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:customer_management][:namespace]

  def self.generate_screenname
    'ltrc_' + LFCommon.get_current_time + '_us@leapfrog.test'
  end

  def self.register_customer(caller_id, screen_name, email, username, password = '123456')
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :register_customer,
      "<caller-id>#{caller_id}</caller-id>
      <customer id='' first-name='LTRC' last-name='Tester' middle-name='mdname' salutation='sal' locale='en_US' alias='LTRCTester' screen-name='#{screen_name}' modified='' created=''>
        <email opted='true' verified='true' type='work'>#{email}</email>
        <credentials username='#{username}' password='#{password}' hint='#{password}' expiration='2015-12-30T00:00:00' last-login=''/>
      </customer>"
    )
  end

  def self.get_customer_info(response)
    xml = Nokogiri::XML(response.to_s)

    { screen_name: xml.xpath('//customer').attr('screen-name').text,
      str_alias: xml.xpath('//customer').attr('alias').text,
      locale: xml.xpath('//customer').attr('locale').text,
      salutation: xml.xpath('//customer').attr('salutation').text,
      middle_name: xml.xpath('//customer').attr('middle-name').text,
      last_name: xml.xpath('//customer').attr('last-name').text,
      first_name: xml.xpath('//customer').attr('first-name').text,
      id: xml.xpath('//customer').attr('id').text,
      username: xml.xpath('//customer/credentials').attr('username').text,
      password: xml.xpath('//customer/credentials').attr('password').text,
      hint: xml.xpath('//customer/credentials').attr('hint').text,
      expiration: xml.xpath('//customer/credentials').attr('expiration').text,
      email: xml.xpath('//customer/email').text }
  rescue => e
    e.to_s
  end

  def self.fetch_customer(caller_id, customer_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_customer,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id>#{customer_id}</customer-id>"
    )
  end

  def self.search_for_customer(caller_id, first_name, last_name, email)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :search_for_customer,
      "<caller-id>#{caller_id}</caller-id>
      <customer-first-name>#{first_name}</customer-first-name>
      <customer-last-name>#{last_name}</customer-last-name>
      <customer-email>#{email}</customer-email>"
    )
  end

  def self.update_customer(caller_id, customer_id, username, email, password, screen_name)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :update_customer,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>
      <customer-id>#{customer_id}</customer-id>
      <customer id='111' first-name='uLTRC' last-name='uTester' middle-name='' salutation='' locale='fr_FR' alias='' screen-name='#{screen_name}' modified='' created='' type='' registration-date=''>
        <credentials username='#{username}' password='#{password}' hint='' expiration='' last-login='' password-temporary='?'/>
        <email>#{email}</email>
      </customer>"
    )
  end

  def self.change_password(caller_id, customer_id, username, current_password, new_password, hint)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :change_password,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>
      <customer-id>#{customer_id}</customer-id>
      <current-credentials username='#{username}' password='#{current_password}' hint='' expiration='' last-login='' password-temporary=''/>
      <new-credentials username='#{username}' password='#{new_password}' hint='#{hint}' expiration='' last-login='' password-temporary=''/>"
    )
  end

  def self.add_email(caller_id, customer_id, username, new_email)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :add_email,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>
      <customer-id>#{customer_id}</customer-id>
      <email opted='?' verified='?' type='?' lp-opted='?' vendors-opted='?'>#{new_email}</email>"
    )
  end

  def self.fetch_emails(caller_id, customer_id, username)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_emails,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>
      <customer-id>#{customer_id}</customer-id>"
    )
  end

  def self.remove_email(caller_id, customer_id, email)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :remove_email,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id>#{customer_id}</customer-id>
      <email opted='?' verified='?' type='?' lp-opted='?' vendors-opted='?'>#{email}</email>"
    )
  end

  def self.add_address(caller_id, customer_id, username, type, street, unit, city, country, province, postal_code)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :add_address,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>
      <customer-id>#{customer_id}</customer-id>
      <address type='#{type}'>
        <street unit='#{unit}'>#{street}</street>
        <region city='#{city}' country='#{country}' province='#{province}' postal-code='#{postal_code}'/>
      </address>"
    )
  end

  def self.fetch_addresses(caller_id, customer_id, username)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_addresses,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>
      <customer-id>#{customer_id}</customer-id>"
    )
  end

  def self.remove_address(caller_id, customer_id, username, address_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :remove_address,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>
      <customer-id>#{customer_id}</customer-id>
      <address id='#{address_id}' type='billing'>
        <street unit=''/>
        <region province='' city='' country='' postal-code=''/>
      </address>"
    )
  end

  def self.add_phone(caller_id, customer_id, username, number, type, extension)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :add_phone,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>
      <customer-id>#{customer_id}</customer-id>
      <phone type='#{type}' extension='#{extension}' number='#{number}'/>"
    )
  end

  def self.fetch_phones(caller_id, customer_id, username)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_phones,
      "<caller-id>#{caller_id}</caller-id>
       <username>#{username}</username>
       <customer-id>#{customer_id}</customer-id>"
    )
  end

  def self.identify_customer(caller_id, username, password)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :identify_customer,
      "<caller-id>#{caller_id}</caller-id>
      <credentials username='#{username}' password='#{password}' hint='?' expiration='?' last-login='?' password-temporary='?'/>"
    )
  end

  def self.identify_customer_segments(caller_id, username, password)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :identify_customer_segments,
      "<caller-id>#{caller_id}</caller-id>
      <credentials username='#{username}' password='#{password}' hint='?' expiration='?' last-login='?' password-temporary='?'/>"
    )
  end

  def self.lookup_customer_by_username(caller_id, username)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :lookup_customer_by_username,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>"
    )
  end

  def self.reset_password(caller_id, email)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :reset_password,
      "<caller-id>#{caller_id}</caller-id>
      <email opted='false' verified='true' type='work'>#{email}</email>"
    )
  end

  def self.fetch_customer_devices(caller_id, customer_id, device_serial)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_customer_devices,
      "<caller-id>#{caller_id}</caller-id>
       <customer-id>#{customer_id}</customer-id>
       <device-serial>#{device_serial}</device-serial>
       <sendEmail>false</sendEmail>"
    )
  end
end
