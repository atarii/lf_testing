require 'savon'
require 'nokogiri'

class CommonMethods
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
    ['error', error.to_hash[:fault][:faultstring]]
  else
    Nokogiri::XML(res.to_xml)
  end

  def self.service_info(method, env)
    case env
    when 'PROD'
      url = 'http://evplcis.leapfrog.com:8080/inmon/services/'
    when 'STAGING'
      url = 'http://evslcis2.leapfrog.com:8080/inmon/services/'
    else
      url = 'http://emqlcis.leapfrog.com:8080/inmon/services/'
    end

    inmon_endpoints = JSON.parse(File.read('config/inmon_endpoints.json'), symbolize_names: true)
    {
      endpoint: url + inmon_endpoints[method][:endpoint],
      namespace: inmon_endpoints[method][:namespace]
    }
  end

  def self.current_time
    time = Time.new
    "#{time.year}#{time.month}#{time.day}#{time.hour}#{time.min}#{time.sec}"
  end
end
