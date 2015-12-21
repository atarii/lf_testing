$LOAD_PATH.unshift('automations/lib')
$LOAD_PATH.unshift('automations/atg_automation')
$LOAD_PATH.unshift('automations/atg_automation/pages/atg')
$LOAD_PATH.unshift('automations/atg_automation/pages/atg_dv')
$LOAD_PATH.unshift('automations/atg_automation/pages/csc')
$LOAD_PATH.unshift('automations/atg_automation/pages/vindicia')
$LOAD_PATH.unshift('automations/atg_automation/pages/mail')

require 'json'
require 'nokogiri'
require 'connection'
require 'test_driver_manager'
require 'lib/const'
require 'lib/encode'
require 'lib/excelprocessing'
require 'lib/generate'
require 'lib/localesweep'
require 'lib/services'
require 'lib/soft_good_common_methods'
require 'lib/atg_dv_common'

module Capybara
  class << self
    alias_method :old_reset_sessions!, :reset_sessions!

    def reset_sessions!
    end
  end
end

xml_content = Nokogiri::XML(File.read $LOAD_PATH.detect { |path| path.index('data.xml') }) || 'TEMPORARY DATA FILE IS MISSING. PLEASE RECHECK!'
web_driver = xml_content.search('//information/webdriver').text

device_store = xml_content.search('//devices/device_store').text
device_store_info = JSON.parse(File.read("#{File.expand_path('..', File.dirname(__FILE__))}/data/device_store_urls.json"))[device_store]
user_agent = device_store_info.nil? ? '' : device_store_info['user_agent']

case web_driver
when 'FIREFOX'
  TestDriverManager.run_with(:firefox, user_agent)
when 'CHROME'
  TestDriverManager.run_with(:chrome, user_agent)
when 'IE'
  TestDriverManager.run_with(:internet_explorer, user_agent)
else
  TestDriverManager.run_with(:webkit, user_agent)
end

def app_exist?
  titles_count = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_CHECK_APP_EXIST).count
  return true unless titles_count.zero?
  skip 'BLOCKED: No titles found in MOAS for this release'
  false
end

def app_available?(titles_count, message = 'There were no apps found in MOAS')
  return true unless titles_count.zero?

  it message do
  end

  false
end

def pin_available?(env, locale)
  code_env = (env.upcase == 'PROD') ? 'PROD' : 'QA'
  code_type = "#{locale.upcase}V1"
  pin = PinRedemption.get_pin_info(code_env, code_type, 'Available')

  return true unless pin.blank?

  skip 'BLOCKED: There is no available code in DB. Please upload code before running test case'
  false
end
