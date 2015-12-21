require 'rexml/document'

def xml_file_to_hash(filename)
  xml = Nokogiri::XML(File.read(filename))
  Hash.from_xml(xml.to_s)
end

def to_pretty_xml(xml)
  pretty_xml = ''
  formatter = REXML::Formatters::Pretty.new
  formatter.compact = true
  formatter.write REXML::Document.new(xml), pretty_xml
  pretty_xml
end

config = Rails.application.config
default_config = xml_file_to_hash ENV['CONFIG_FILE']
machine_default = {
  'configuration' => {
    'machineSettings' => {
      'stationName' => '',
      'networkName' => config.server_name,
      'ip' => config.server_ip,
      'port' => config.server_port
    }
  }
}

machine_config = {}
machine_config = xml_file_to_hash ENV['MACHINE_FILE'] if File.exist?(ENV['MACHINE_FILE'])

# Add missing settings
machine_default.deep_merge!(machine_config)
machine_default.deep_merge!(default_config) { |_key, v1, _v2| v1 }

pretty_xml = to_pretty_xml machine_default['configuration'].to_xml(root: 'configuration').gsub('nil="true"', '')
File.open(ENV['MACHINE_FILE'], 'w') { |xml| xml.write pretty_xml }

config.server_role = machine_default['configuration']['machineSettings']['stationName']
config.server_name = machine_default['configuration']['machineSettings']['networkName']

# Configure email server
smtp_setting = machine_default['configuration']['smtpSetting']
config.action_mailer.smtp_settings.merge!(
  address: smtp_setting['address'],
  port: smtp_setting['port'],
  domain: smtp_setting['domain'],
  user_name: smtp_setting['username'],
  password: smtp_setting['password'],
  attachment_type: smtp_setting['attachmentType']
)
