class GeoipLookupController < ApplicationController
  def index
    @geoip_config = [
      { env: 'DEV', url_prefix: 'http://dev-geo.leapfrog.com:8080/geoip-lookup/lookup?i=' },
      { env: 'QA', url_prefix: 'http://qa-geo.leapfrog.com:8080/geoip-lookup/lookup?i=' },
      { env: 'STAGE', url_prefix: 'http://staging-geo.leapfrog.com:8080/geoip-lookup/lookup?i=' },
      { env: 'PROD', url_prefix: 'http://geo.leapfrog.com:8080/geoip-lookup/lookup?i=' }
    ]

    @ip_inputs = (params[:ip_input] || '80.176.148.22').strip.gsub("\n", ',').split(',').reject(&:empty?).map { |value| { ip: value } }
    @ip_inputs.each do |i|
      i[:endpoints] = []
      @geoip_config.each do |g|
        i[:endpoints] << { url: "#{g[:url_prefix]}#{i[:ip]}" }
      end
    end

    @ip_inputs.each do |i|
      i[:endpoints].each { |e| http_fetch_contents(e) }
    end
  end

  def http_fetch_contents(endpoint)
    uri = URI.parse(endpoint[:url])
    begin
      response = Net::HTTP.get_response(uri)
      endpoint[:body] = response.body
    rescue EOFError, Errno::ECONNRESET, Errno::EINVAL, Errno::ETIMEDOUT, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, OpenSSL::SSL::SSLError, SocketError, Timeout::Error, Errno::ECONNABORTED => e
      endpoint[:error] = e.class.name
    end
  end
end
