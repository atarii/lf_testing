require 'json'
require 'net/http'
require 'uri'

def fetch_device_activation_code(x_caller_id, serial)
  headers = { 'x-caller-id' => x_caller_id }
  LFCommon.rest_call LFRESOURCES::CONST_DEVICES_ACTIVATION % serial, nil, headers, 'post'
end

def lookup_device_by_activation_code(x_caller_id, activation_code)
  headers = { 'x-caller-id' => x_caller_id }
  LFCommon.rest_call LFRESOURCES::CONST_DEVICES_ACTIVATION % activation_code, nil, headers, 'get'
end
