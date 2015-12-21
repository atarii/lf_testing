require 'active_support/core_ext/string/strip'
require 'json'
require 'net/http'
require 'rest-client'
require 'uri'

def fetch_device(caller_id, serial)
  headers = { 'x-caller-id' => caller_id }
  LFCommon.rest_call LFRESOURCES::CONST_FETCH_DEVICE % serial, nil, headers, 'get'
end

def device_inventory(caller_id, session, serial)
  headers = { 'x-caller-id' => caller_id, 'x-session-token' => session }
  LFCommon.rest_call LFRESOURCES::CONST_DEVICE_INVENTORY % serial, nil, headers, 'get'
end

def authorize_installation(caller_id, session, serial, pkg_id)
  headers = { 'x-caller-id' => caller_id, 'x-session-token' => session }
  LFCommon.rest_call LFRESOURCES::CONST_AUTHORIZE_INSTALLATION % [serial, pkg_id], nil, headers, 'get'
end

def package_dependencies(caller_id, query_string)
  headers = { 'x-caller-id' => caller_id }
  LFCommon.rest_call LFRESOURCES::CONST_PACKAGE_DEPENDENCIES % query_string, nil, headers, 'get'
end

def report_installation(caller_id, session, dev_serial, pkg_id)
  params = { 'device-serial' => dev_serial, 'pkg-id' => pkg_id }
  headers = { 'x-caller-id' => caller_id, 'x-session-token' => session }
  LFCommon.rest_call LFRESOURCES::CONST_REPORT_INSTALLATION, params, headers, 'post'
end

def update_profiles(caller_id, dev_serial, data)
  uri = URI.parse("#{LFREST::CONST_ENDPOINT}/devices/#{dev_serial}/users")
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  request = Net::HTTP::Post.new(uri.request_uri)

  # Set HEADER parameters
  request.initialize_http_header(
    'x-caller-id' => caller_id,
    'Content-Type' => 'application/json',
    'accept' => '*/*',
    'accept-encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'user-agent' => 'ruby'
  )

  # Set body data
  request.body = data

  # Execute request
  res = http.request(request)

  return KnownBug::CONST_BUG_ID_33984 if res.header.content_type == 'text/html'

  JSON.parse(res.body)
end

def remove_installation(caller_id, session, dev_serial, pkg_id)
  params = { 'device-serial' => dev_serial, 'pkg-id' => pkg_id }
  headers = { 'x-caller-id' => caller_id, 'x-session-token' => session }
  LFCommon.rest_call LFRESOURCES::CONST_REMOVE_INSTALLATION, params, headers, 'post'
end

# Update device and profile information
# Params:
#   "devProps": {
#       "mfgsku": "31576-99903",
#       "pin": "1111",
#       "parentemail": "tin.trinh46@leapfrog.test",
#       "model": "1"
#   }
#   devUsers": [{
#       "userName": "Test",
#       "userGender": "female",
#       "userWeakId": 1,
#       "userEdu": "PRE",
#       "userDob": "2014-3-1"
#   }]
def update_narnia(caller_id, session, dev_serial, dev_props, dev_users, dev_service_code)
  headers = { 'x-caller-id' => caller_id, 'x-session-token' => session, 'Content-Type' => 'application/json' }
  data = <<-INTERPOLATED_HEREDOC.strip_heredoc
  {
    "devProps": #{dev_props},
    "devServiceCode": "#{dev_service_code}",
    "devSerial": "#{dev_serial}",
    "devAutocreateUsers": true,
    "devUsers": #{dev_users}
  }
  INTERPOLATED_HEREDOC

  rest_call_narnia headers, data, "#{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA}" % dev_serial, 'POST'
end

def fetch_narnia(caller_id, dev_serial)
  headers = { 'x-caller-id' => caller_id }
  rest_call_narnia headers, '', "#{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_FETCH_DEVICE}" % dev_serial, 'GET'
end

# Update device and profile information
def reset_narnia(caller_id, dev_serial)
  headers = { 'x-caller-id' => caller_id }
  rest_call_narnia headers, '', "#{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_RESET_NARNIA}" % dev_serial, 'DELETE'
end

def owner_narnia(caller_id, session_token, dev_serial)
  headers = { 'x-caller-id' => caller_id, 'x-session-token' => session_token }
  rest_call_narnia headers, '', "#{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_OWNER_NARNIA}" % dev_serial, 'POST'
end

def rest_call_narnia(headers, data, url, method)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  request = Net::HTTP::Delete.new(uri.request_uri) if method == 'DELETE'
  request = Net::HTTP::Post.new(uri.request_uri) if method == 'POST'
  request = Net::HTTP::Get.new(uri.request_uri) if method == 'GET'

  request.initialize_http_header(headers)
  request.set_body_internal data unless data.blank?
  res = http.request(request)

  return JSON.parse(res.body) if res.header.content_type == 'application/json'
  res.body
end

def upload_game_log(caller_id, dev_serial)
  url = "#{LFREST::CONST_ENDPOINT}/uploads/device/#{dev_serial}"
  filepath = "#{Misc::CONST_PROJECT_PATH}/data/Narnia_Game_Log_080227_103041.bin"

  request = RestClient::Request.new(
    method: :post,
    url: url,
    headers: { 'x-caller-id' => caller_id, 'Content-Type' => 'multipart/form-data' },
    payload: { 'multipart' => true, 'file' => File.new(filepath, 'rb') },
    verify_ssl: OpenSSL::SSL::VERIFY_NONE
  )

  res = request.execute

  return res.body if res.body.include? '<html><head>'

  JSON.parse(res.body)
end
