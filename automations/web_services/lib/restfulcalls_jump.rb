require 'net/http'
require 'json'
require 'uri'
require 'lib/inmon/customer_management'
require 'lib/inmon/authentication'
require 'lib/inmon/child_management'
require 'lib/inmon/owner_management'
require 'lib/inmon/device_management'

def put_petathlon_companion_app_data(x_caller_id, x_session_token, serial, data)
  uri = URI.parse("#{LFREST::CONST_ENDPOINT}/devices/#{serial}/extras/petathlon")
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  request = Net::HTTP::Put.new(uri.request_uri)

  # Set HEADER parameters
  request.initialize_http_header(
    'x-caller-id' => x_caller_id,
    'x-session-token' => x_session_token,
    'Content-Type' => 'application/json; charset=UTF-8'
  )

  # Set body data
  request.body = data

  # Execute request
  res = http.request(request)

  return JSON.parse(res.body) if res.header.content_type == 'application/json'

  res.body
end

def get_petathlon_companion_app_data(x_caller_id, x_session_token, serial)
  headers = { 'x-caller-id' => x_caller_id, 'x-session-token' => x_session_token }
  LFCommon.rest_call LFRESOURCES::CONST_PETATHLON_COMPANION_APP_DATA % serial, nil, headers, 'get'
end

# Put leapband data for a service
def put_leapband_data(x_caller_id, x_session_token, serial, data)
  uri = URI.parse("#{LFREST::CONST_ENDPOINT}/devices/#{serial}/extras/leapband")
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  request = Net::HTTP::Put.new(uri.request_uri)

  # Set HEADER parameters
  request.initialize_http_header(
    'x-caller-id' => x_caller_id,
    'x-session-token' => x_session_token,
    'Accept' => 'application/json',
    'Content-Type' => 'application/json'
  )

  # Set body data
  request.body = data

  # Execute request
  res = http.request(request)

  return KnownBug::CONST_BUG_ID_33984 if res.header.content_type == 'text/html'

  JSON.parse(res.body)
end

def get_leapband_data(x_caller_id, x_session_token, serial)
  headers = { 'x-caller-id' => x_caller_id, 'x-session-token' => x_session_token }
  LFCommon.rest_call LFRESOURCES::CONST_LEAPBAND_DATA % serial, nil, headers, 'get'
end

def get_all_buckets(x_caller_id, x_session_token, serial)
  headers = { 'x-caller-id' => x_caller_id, 'x-session-token' => x_session_token }
  LFCommon.rest_call LFRESOURCES::CONST_BUCKETS % serial, nil, headers, 'get'
end

# Put multiple buckets in a single call
def put_multiple_buckets(x_caller_id, x_session_token, serial, data)
  uri = URI.parse("#{LFREST::CONST_ENDPOINT}/devices/#{serial}/extras")
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  request = Net::HTTP::Put.new(uri.request_uri)

  # Set HEADER parameters
  request.initialize_http_header(
    'x-caller-id' => x_caller_id,
    'x-session-token' => x_session_token,
    'Accept' => 'application/json',
    'Content-Type' => 'application/json'
  )

  # Set body data
  request.body = data

  # Execute request
  res = http.request(request)

  return KnownBug::CONST_BUG_ID_33984 if res.header.content_type == 'text/html'

  JSON.parse(res.body)
end

def remove_dynamic_source(str)
  str = str.to_s
  index1 = str.index('Source')
  str = str[0..index1] + '}}' unless index1.nil?
  str.gsub('\\n', '')
end

def remove_dynamic_timestamp(str)
  index1 = str.index('@')
  index2 = str.rindex('@')
  str = str[0..index1] + str[index2 + 10..-1] unless index1.nil? || index2.nil?

  # remove timestamp
  index1 = str.index('timestamp')
  index2 = str.rindex('timestamp')
  str = str[0..index1] + str[index2 + 30..-1] unless index1.nil? || index2.nil?
  str.gsub('\\n', '')
end

def remove_dynamic_at_sign(str)
  index1 = str.index('@')
  index2 = str.rindex('@')
  str = str[0..index1] + str[index2 + 10..-1] unless index1.nil? || index2.nil?
  str.gsub('\\n', '')
end

class Customer
  attr_accessor :session, :serial

  def initialize
    @session = nil
    @serial = nil
  end

  def register_customer_and_claim_device
    # 1. registerCustomer
    # 2. acquireServiceSession
    # 3. registerChild
    # 4. claimDevice

    email = username = LFCommon.generate_email
    reg_res = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, email, username)

    cus_id = reg_res.xpath('//customer/@id').text
    username = reg_res.xpath('//customer/credentials/@username').text
    password = reg_res.xpath('//customer/credentials/@password').text

    # 2. acquireServiceSession
    acq_res = Authentication.acquire_service_session(Misc::CONST_CALLER_ID, username, password)
    @session = acq_res.xpath('//session').text

    # 3. registerChild
    reg_chi_res = ChildManagement.register_child(Misc::CONST_CALLER_ID, @session, cus_id)
    child_id = reg_chi_res.xpath('//child/@id').text

    # 4. claimDevice
    @serial = DeviceManagement.generate_serial
    OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_id, @serial, 'leappad', '0', 'profile', child_id)
  rescue
    raise 'Error occur when calling SOAP services'
  end

  # update customer
  def update_customer(id, session, serial)
    Connection.my_sql_connection("update ws_restfulcalls set session='#{session}', devserial='#{serial}' where id='#{id}'") if session.to_s.strip.length != 0 && serial.to_s.strip.length != 0
  end

  # update session, serial in restfulcalls DB
  def update_account(id)
    begin
      register_customer_and_claim_device
      update_customer(id, @session, @serial)
      is_update = true
    end

    is_update
  end
end
