require 'nokogiri'

class ReadXML
  def smtp_info
    xml_content = File.read("#{File.expand_path File.dirname(__FILE__)}/../config/config.xml")
    doc = Nokogiri::XML(xml_content)
    { address: doc.search('//address').text,
      port: doc.search('//port').text,
      domain: doc.search('//domain').text,
      username: doc.search('//username').text,
      password: doc.search('//password').text,
      attachment_type: doc.search('//attachmentType').text }
  end

  def run_queue_info
    xml_content = File.read("#{File.expand_path File.dirname(__FILE__)}/../config/config.xml")
    doc = Nokogiri::XML(xml_content)
    { limit_run_test: doc.search('//limitRunningTest').text,
      refresh_run_rate: doc.search('//refreshRunningRate').text }
  end
end
