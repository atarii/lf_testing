require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'
require 'json'
require 'selenium-webdriver'
require 'capybara'

class LFCommon
  Capybara.default_driver = :selenium
  include Capybara::DSL

  def self.soap_call(endpoint, namespace, method, message)
    client = Savon.client(
      endpoint: endpoint,
      namespace: namespace,
      log: true,
      pretty_print_xml: true,
      namespace_identifier: :man
    )

    res = client.call(method, message: message)
    Nokogiri::XML(res.to_xml)
  rescue Savon::SOAPFault => error
    fault_str = error.to_hash[:fault][:faultstring].to_s
    fault_str << ' ' << error.to_hash[:fault][:detail][:access_denied] if fault_str == 'AccessDeniedFault'
    fault_str
  rescue => e
    e.to_s[0..55] + '...'
  end

  #
  # params is a hash table Ex: { 'device-serial' => devSerial, 'pkg-id' => pkgId}
  # header is a hash table Ex: {'x-caller-id' => callerid,'x-session-token' => session}
  # method is post or get
  #
  def self.rest_call(resource, params, header, method)
    uri = URI.parse("#{LFREST::CONST_ENDPOINT}#{resource}")
    http = Net::HTTP.new(uri.host, uri.port)

    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    request = Net::HTTP::Post.new(uri.request_uri) if method.downcase == 'post'
    request = Net::HTTP::Get.new(uri.request_uri) if method.downcase == 'get'
    request = Net::HTTP::Put.new(uri.request_uri) if method.downcase == 'put'

    # Set HEADER parameters
    request.initialize_http_header(header)

    request.set_form_data params unless params.blank?

    # Execute request
    res = http.request(request)

    return JSON.parse("{ body: #{res.body} }") if res.header.content_type == 'text/html'
    JSON.parse(res.body)
  end

  def self.get_current_time
    time = Time.new
    time.strftime('%Y%-m%-d%H%M%S').to_s + Random.rand(1...100).to_s
  end

  def self.generate_email
    'inpsc_' + LFCommon.get_current_time + '_us@leapfrog.test'
  end

  def self.generate_password
    LFCommon.get_current_time
  end

  #
  # objective: make account known to vindica system
  # 1. navigate to URL
  # 2. login username, password
  #
  def login_to_lfcom(username, password)
    visit LFSOAP::CONST_LF_LOGIN_URL
    fill_in 'atg_loginEmail', with: username
    fill_in 'atg_loginPassword', with: password
    click_button 'Log In'
  end

  #
  # Send a http/https request and return http code status
  #
  def self.get_http_code(url)
    uri = URI.parse url
    if uri.scheme == 'http'
      response = Net::HTTP.get_response(URI(uri))
    else # https
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
    end
    response.code
  rescue URI::InvalidURIError
    'Invalid URL'
  rescue SocketError
    'SocketError'
  rescue NoMethodError => e
    e.to_s
  rescue => e
    e.class.name.to_s
  end

  def self.endpoint_status(endpoint_file, url_prefix)
    endpoints = []

    File.open(endpoint_file, 'r') do |file_obj|
      file_obj.each_line do |line|
        url = line % url_prefix
        res = get_http_code(url).to_s
        endpoints.push(url: url, res: res)
      end
    end

    endpoints
  rescue
    []
  end
end
