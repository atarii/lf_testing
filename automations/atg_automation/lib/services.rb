require 'nokogiri'
require 'savon'
require 'net/http'
require 'uri'
require 'base64'
require 'lib/localesweep'
require 'rails'

class LFCommon
  def self.soap_call(endpoint, namespace, method, message)
    client = Savon.client(
      endpoint: endpoint,
      namespace: namespace,
      log: true,
      pretty_print_xml: true,
      namespace_identifier: :man
    )

    res = client.call(method, message: message)
  rescue Savon::SOAPFault => error
    fault_str = error.to_hash[:fault][:faultstring].to_s
    fault_str << ' ' << error.to_hash[:fault][:detail][:access_denied] if fault_str == 'AccessDeniedFault'
  else
    Nokogiri::XML(res.to_xml)
  end

  def self.generate_asset_endpoints(title)
    base_asset = title['baseassetname'].gsub(/\s+/, '')
    asset_endpoints = {}
    asset_endpoints[:beauty_shot] = 'http://s7.leapfrog.com/is/image/LeapFrog/' + base_asset + '_1'
    asset_endpoints[:icon] = 'http://s7.leapfrog.com/is/image/LeapFrog/' + title['sku'] unless title['platformcompatibility'].split(',').include?('LeapTV')
    asset_endpoints[:video] = 'http://s7.leapfrog.com/e2/LeapFrog/' + base_asset + '_video_1'
    asset_endpoints[:carousel_image_1] = 'http://s7.leapfrog.com/is/image/LeapFrog/' + base_asset + '_2'
    asset_endpoints[:carousel_image_2] = 'http://s7.leapfrog.com/is/image/LeapFrog/' + base_asset + '_3'
    asset_endpoints[:leaptv_icon_link] = 'http://s7.leapfrog.com/is/image/LeapFrog/' + title['sku'] + '_LTV' if title['platformcompatibility'].split(',').include?('LeapTV')

    # test if there is 2 or more details and a corresponding details title 1-5
    details = Title.get_details title['details']
    unless details.blank? && details.length > 2
      details.delete_at 0
      details.each_with_index do |_details, index|
        asset_endpoints["detail_image_#{index + 1}"] = 'http://s7.leapfrog.com/is/image/LeapFrog/' + base_asset + "_detail_#{index + 1}"
      end
    end

    asset_endpoints.symbolize_keys
  end

  def self.get_http_code(url)
    uri = URI.parse url
    res = Net::HTTP.get_response(URI(uri))
    res.code
  rescue URI::InvalidURIError
    'Invalid URL'
  rescue SocketError
    'SocketError'
  rescue NoMethodError => e
    e.to_s
  end

  def self.get_content_length(url)
    uri = URI.parse url
    res = Net::HTTP.get_response(URI(uri))
    res.header['content-length'].to_i
  rescue URI::InvalidURIError
    'Invalid URL'
  rescue SocketError
    'SocketError'
  rescue NoMethodError => e
    e.to_s
  end

  def self.get_content_type(url)
    uri = URI.parse url
    res = Net::HTTP.get_response(URI(uri))
    res.header['content-type']
  rescue URI::InvalidURIError
    'Invalid URL'
  rescue SocketError
    'SocketError'
  rescue NoMethodError => e
    e.to_s
  end
end

class SoftGoodManagement
  @endpoint = ServicesInfo::CONST_INMON_ENDPOINTS[:soft_good_management][:endpoint]
  @namespace = ServicesInfo::CONST_INMON_ENDPOINTS[:soft_good_management][:namespace]

  def self.reserve_gift_pin(caller_id, locale = 'en_US')
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :reserve_gift_pin,
      "<caller-id>#{caller_id}</caller-id>
      <locale>#{locale}</locale>"
    )
  end

  def self.purchase_gift_pin(caller_id, cus_id, pin)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :purchase_gift_pin,
      "<caller-id>#{caller_id}</caller-id>
      <cust-key>#{cus_id}</cust-key>
      <references key='currency' value='USD'/>
      <references key='sku.count' value='1'/>
      <references key='locale' value='en_US'/>
      <references key='transactionId' value='transactionid_111'/>
      <references key='transactionAmount' value='10.00'/>
      <references key='sku.code_0' value='58129-96914'/>
      <reserved-pin>#{pin}</reserved-pin>"
    )
  end
end

class CustomerManagement
  @endpoint = ServicesInfo::CONST_INMON_ENDPOINTS[:customer_management][:endpoint]
  @namespace = ServicesInfo::CONST_INMON_ENDPOINTS[:customer_management][:namespace]

  def self.search_for_customer(caller_id, email)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :search_for_customer,
      "<caller-id>#{caller_id}</caller-id>
      <customer-email>#{email}</customer-email>"
    )
  end

  def self.clear_account_licenses(email, password)
    # Authenticate & get session token
    ses = AuthenticationService.acquire_service_session(ServicesInfo::CONST_CALLER_ID, email, password).at_xpath('//session').text

    # -> list all licenses of customer (params are session and customer id)
    # get customer id by username
    cus_id = search_for_customer(ServicesInfo::CONST_CALLER_ID, email).xpath('//customer/@id').text

    # fetchRestrictedLicenses
    licenses = LicenseManagementService.fetch_restricted_licenses(ServicesInfo::CONST_CALLER_ID, ses, cus_id).xpath('//licenses')

    # revokeLicense for each license
    # Params:- session and licese id
    licenses.each do |el|
      LicenseManagementService.revoke_license(ServicesInfo::CONST_CALLER_ID, ses, el['id'])
    end
  end

  def self.register_customer(caller_id, first_name, last_name, email, username, password, locale)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :register_customer,
      "<caller-id>#{caller_id}</caller-id>
      <customer id='' first-name='#{first_name}' last-name='#{last_name}' middle-name='mdname' salutation='sal' locale='#{locale}' alias='LTRCTester' screen-name='#{email}' modified='' created=''>
      <email>#{email}</email>
      <credentials username='#{username}' password='#{password}' hint='#{password}' expiration='2015-12-30T00:00:00' last-login=''/>
      </customer>"
    )
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

  def self.lookup_customer_by_username(caller_id, username)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :lookup_customer_by_username,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>"
    )
  end
end

class AuthenticationService
  @endpoint = ServicesInfo::CONST_INMON_ENDPOINTS[:authentication_management][:endpoint]
  @namespace = ServicesInfo::CONST_INMON_ENDPOINTS[:authentication_management][:namespace]

  def self.acquire_service_session(caller_id, email, password)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :acquire_service_session,
      "<caller-id>#{caller_id}</caller-id>
      <credentials username='#{email}' password='#{password}'/>"
    )
  end
end

class LicenseManagementService
  @endpoint = ServicesInfo::CONST_INMON_ENDPOINTS[:license_management][:endpoint]
  @namespace = ServicesInfo::CONST_INMON_ENDPOINTS[:license_management][:namespace]

  def self.fetch_restricted_licenses(caller_id, session, cus_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_restricted_licenses,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <cust-key>#{cus_id}</cust-key>"
    )
  end

  def self.get_restricted_licenses_id(caller_id, session, cus_id)
    res = LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_restricted_licenses,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <cust-key>#{cus_id}</cust-key>"
    )

    xml = Nokogiri::XML(res.to_s)
    package_arr = []
    licenses_count = xml.xpath('//licenses').count
    (1..licenses_count).each do |i|
      package_arr.push(xml.xpath('//licenses[' + i.to_s + ']').attr('package-id').text)
    end

    package_arr
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

class ChildManagementService
  @endpoint = ServicesInfo::CONST_INMON_ENDPOINTS[:child_management][:endpoint]
  @namespace = ServicesInfo::CONST_INMON_ENDPOINTS[:child_management][:namespace]

  def self.register_child(caller_id, session, customer_id, child_name = "Ronaldo#{Generate.get_current_time}", gender = 'male', grade = '5')
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :register_child,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <customer-id>#{customer_id}</customer-id>
      <child id='1122' name='#{child_name}' dob='2001-10-08' grade='#{grade}' gender='#{gender}' can-upload='true'  titles='1' screen-name='D' locale='en-us' />"
    )
  end
end

class OwnerManagementService
  @endpoint = ServicesInfo::CONST_INMON_ENDPOINTS[:owner_management][:endpoint]
  @namespace = ServicesInfo::CONST_INMON_ENDPOINTS[:owner_management][:namespace]

  def self.claim_device(caller_id, session, device_serial, platform, slot, profile_name, child_id, dob = Time.now, grade = '5', gender = 'male')
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
end

class DeviceProfileManagementService
  @endpoint = ServicesInfo::CONST_INMON_ENDPOINTS[:device_profile_management][:endpoint]
  @namespace = ServicesInfo::CONST_INMON_ENDPOINTS[:device_profile_management][:namespace]

  def self.assign_device_profile(caller_id, customer_id, device_serial, platform, slot, profile_name, child_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :assign_device_profile,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id>#{customer_id}</customer-id>
      <device-profile device='#{device_serial}' platform='#{platform}' slot='#{slot}' name='#{profile_name}' child-id='#{child_id}'/>
      <child-id>#{child_id}</child-id>"
    )
  end

  def self.list_device_profiles(caller_id, username, customer_id, total, length, offset)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_device_profiles,
      "<caller-id>#{caller_id}</caller-id>
      <username>#{username}</username>
      <customer-id>#{customer_id}</customer-id>
      <page total='#{total}' length='#{length}' offset='#{offset}'/>"
    )
  end
end

class DeviceManagementService
  @endpoint = ServicesInfo::CONST_INMON_ENDPOINTS[:device_management][:endpoint]
  @namespace = ServicesInfo::CONST_INMON_ENDPOINTS[:device_management][:namespace]

  def self.generate_serial(platform = 'LP')
    "#{platform}xyz123321xyz" + Generate.get_current_time
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

  def self.fetch_device(caller_id, device_serial)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_device,
      "<caller-id>#{caller_id}</caller-id>
      <device serial='#{device_serial}' product-id='' platform='' auto-create='false' pin=''>
      <properties/>
      </device>"
    )
  end

  def self.get_nominated_devices(caller_id, session, type)
    xml_response = list_nominated_devices(caller_id, session, type)
    device_arr = []
    (1..xml_response.xpath('//device').count).each do |i|
      device_arr.push(xml_response.xpath('//device[' + i.to_s + ']/@serial').text)
    end

    device_arr
  end
end

class DeviceLogUploadService
  @endpoint = ServicesInfo::CONST_INMON_ENDPOINTS[:device_log_upload][:endpoint]
  @namespace = ServicesInfo::CONST_INMON_ENDPOINTS[:device_log_upload][:namespace]

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
    content = (File.exist? content_path) ? Base64.encode64(File.read("#{content_path}")) : ''
    message = "<caller-id>#{caller_id}</caller-id>
              <log child-id='#{child_id}' local-time='#{local_time}' filename='#{filename}'/>
              <content>#{content}</content>"

    client = Savon.client(
      endpoint: ServicesInfo::CONST_GAME_LOG_UPLOAD_ENDPOINT,
      namespace: ServicesInfo::CONST_GAME_LOG_UPLOAD_NAMESPACE,
      log: true,
      pretty_print_xml: true
    )
    res = client.call(:upload_game_log, message: message)
  rescue Savon::SOAPFault => error
    fault_str = error.to_hash[:fault][:faultstring].to_s
    fault_str << ' ' << error.to_hash[:fault][:detail][:access_denied] if fault_str == 'AccessDeniedFault'
    fault_str
  else
    Nokogiri::XML(res.to_xml)
  end
end

class PinManagementService
  @endpoint = ServicesInfo::CONST_INMON_ENDPOINTS[:pin_management][:endpoint]
  @namespace = ServicesInfo::CONST_INMON_ENDPOINTS[:pin_management][:namespace]

  def self.redeem_value_card(caller_id, cus_id, pin, locale)
    pin_info = generate_pin_info(locale)[0]
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :redeem_value_card,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'/>
      <cust-key>#{cus_id}</cust-key>
      <pin-text>#{pin}</pin-text>
      <locale>#{pin_info[:locale]}</locale>
      <references key='accountSuffix' value='#{pin_info[:reference][:accountSuffix]}'/>
      <references key='currency' value='#{pin_info[:reference][:currency]}'/>
      <references key='locale' value='#{pin_info[:reference][:locale]}'/>
      <references key='CUST_KEY' value='#{cus_id}'/>
      <references key='transactionId' value='#{pin_info[:reference][:transactionId]}'/>"
    )
  end

  def self.fetch_pin_attributes(caller_id, pin)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_pin_attributes,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'/>
      <pin-text>#{pin}</pin-text>"
    )
  end

  def self.get_pin_information(caller_id, pin)
    res = fetch_pin_attributes(caller_id, pin)
    return { has_error: 'error', message: res[1] } unless res.is_a?(Nokogiri::XML::Document)

    {
      has_error: 'none',
      status: res.xpath('//pins/@status').text,
      locale: res.xpath('//pins/@locale').text,
      currency: res.xpath('//pins/@currency').text,
      amount: res.xpath('//pins/@amount').text,
      type: res.xpath('//pins/@type').text
    }
  end

  def self.generate_pin_info(locale)
    pin_info = [
      { locale: 'US', reference: { accountSuffix: 'USD', currency: 'USD', locale: 'en_US', transactionId: 'testUS' } },
      { locale: 'CA', reference: { accountSuffix: 'CAD', currency: 'CAD', locale: 'en_CA', transactionId: 'testCA' } },
      { locale: 'GB', reference: { accountSuffix: 'GBP', currency: 'GBP', locale: 'en_UK', transactionId: 'testUK' } },
      { locale: 'IE', reference: { accountSuffix: 'EUR', currency: 'EUR', locale: 'en_IE', transactionId: 'testIE' } },
      { locale: 'AU', reference: { accountSuffix: 'AUD', currency: 'AUD', locale: 'en_AU', transactionId: 'testROW' } },
      { locale: 'ROW', reference: { accountSuffix: 'USD', currency: 'USD', locale: 'en_ROW', transactionId: 'testROW' } },
      { locale: 'fr_FR', reference: { accountSuffix: 'EUR', currency: 'EUR', locale: 'fr_FR', transactionId: 'testFR_FR' } },
      { locale: 'fr_CA', reference: { accountSuffix: 'CAD', currency: 'CAD', locale: 'fr_CA', transactionId: 'testFR_CA' } },
      { locale: 'fr_ROW', reference: { accountSuffix: 'USD', currency: 'USD', locale: 'fr_ROW', transactionId: 'testFR_ROW' } }
    ]

    pin_info.select { |pin| pin[:locale] == locale }
  end
end
