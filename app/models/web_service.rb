require 'net/http'
require 'uri'
require 'parallel'

class WebService
  def self.update_data_info_to_xml(path, data)
    xml_content = Nokogiri::XML(File.read(path))

    # update ENV into data.xml file
    xml_content.search('//env')[0].inner_html = data[:env].to_s
    xml_content.search('//web_driver')[0].inner_html = data[:web_driver].to_s
    File.open(path, 'w') { |f| f.print(xml_content.to_xml) }
  end

  def self.http_fetch_contents(endpoint)
    uri = URI.parse(endpoint[:url])
    endpoint[:subdomain] = uri.host.rpartition('.leapfrog.com')[0]
    endpoint[:port] = uri.port

    begin
      Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        request = Net::HTTP::Get.new uri
        response = http.request request
        response.code != '200' && endpoint[:error] = "HTTP status error: #{response.code}"
        endpoint[:body] = response.body unless endpoint[:error]
      end
    rescue EOFError, Errno::ECONNRESET, Errno::EINVAL, Errno::ETIMEDOUT, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, OpenSSL::SSL::SSLError, SocketError, Timeout::Error => e
      endpoint[:error] = e.class.name
    rescue Errno::ECONNREFUSED
      endpoint[:error] = 'Network permission denied'
    end
  end

  def self.get_inmon_version(env = 'QA')
    endpoint = { url: 'http://emqlcis.leapfrog.com:8080/inmon/maven/versions.txt' } if env == 'QA'
    endpoint = { url: 'http://evplcis.leapfrog.com:8080/inmon/maven/versions.txt' } if env == 'PROD'
    version_file_contents = http_fetch_contents endpoint
    version_file_contents.lines.first.chomp.split(':')[2] || version_file_contents.lines.first.chomp.split(':')[1]
  end

  def get_running_test_cases(test_suite, test_run)
    all_test_suite = test_suite.split(',')
    if all_test_suite.size > 1
      all_case_ids = CaseSuiteMap.where(suite_id: all_test_suite).pluck(:case_id)
    else
      all_case_ids = test_run
    end
    Case.where(id: all_case_ids).pluck(:script_path)
  end
end
