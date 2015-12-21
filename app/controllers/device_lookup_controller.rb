require 'json'
require 'net/http'
require 'uri'
require 'yaml'

class DeviceLookupController < ApplicationController
  def index
    app_url_format = 'http://%{instance}.leapfrog.com:8080/inmon/resting/v1/devices/%%{code}/activation'
    @environments = [
      { env: 'Dev', instance: 'emdlcis' },
      { env: 'QA', instance: 'emqlcis' },
      { env: 'PROD', instance: 'evplcis' }
    ]
    @environments.each { |e| e[:url_format] = app_url_format % { instance: e[:instance] } }

    @lookup = nil
    params[:query] && @lookup = { query: params[:query] }
    !@lookup && return

    @lookup[:devices] = @environments.map { |e| { env: e[:env], url_format: e[:url_format] } }
    @lookup[:devices].each { |d| get_raw_data @lookup[:query], d }
    @lookup[:devices].each { |d| d[:formatted_data] = d[:data].to_yaml.split("\n")[1..-1].join("\n") }
  end

  def get_raw_data(query, device)
    result = http_fetch_contents device[:url_format] % { code: query }, :get

    if result[:body] && result[:body]['status']
      device[:activation] = query
      device[:serial] = result[:body]['data']['devSerial']
      device[:data] = result[:body]['data']
      return
    end

    result = http_fetch_contents device[:url_format] % { code: query }, :post

    return unless result[:body] && result[:body]['status']

    device[:serial] = query
    device[:activation] = result[:body]['data']['activationCode']

    result = http_fetch_contents device[:url_format] % { code: device[:activation] }, :get
    result[:body] && result[:body]['status'] && device[:data] = result[:body]['data']
  end

  # code adapted from activation_code_management.rb
  def http_fetch_contents(url, method)
    uri = URI.parse(url)

    begin
      if method == :post
        request = Net::HTTP::Post.new uri.request_uri
      else
        request = Net::HTTP::Get.new uri.request_uri
      end

      x_caller_id = 'ededd6a8-587c-470f-a74d-5d1a9697719b'
      http = Net::HTTP.new uri.host, uri.port
      request.initialize_http_header 'x-caller-id' => x_caller_id, 'Content-Type' => 'application/json; charset=UTF-8'
      response = http.request request

      if response.body.include? '<html><head>'
        { error: 'Known bug: #33984' }
      elsif response.header.content_type == 'application/json'
        { body: (JSON.parse response.body) }
      else
        { body: response.body }
      end
    rescue EOFError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EINVAL, Errno::ETIMEDOUT, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, SocketError, Timeout::Error => e
      { error: e.class.name }
    end
  end
end
