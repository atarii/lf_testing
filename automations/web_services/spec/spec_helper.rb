$LOAD_PATH.unshift('automations/lib')
$LOAD_PATH.unshift('automations/web_services')
$LOAD_PATH.unshift('automations/web_services/lib')
$LOAD_PATH.unshift('automations/web_services/lib/learning_path')
$LOAD_PATH.unshift('automations/web_services/lib/inmon')
$LOAD_PATH.unshift('automations/web_services/lib/glasgow')

require 'savon'
require 'nokogiri'
require 'connection'
require 'test_driver_manager'
require 'lib/const'
require 'lib/lfcommon'
require 'lib/oobe_common'
require 'lib/restfulcalls'
require 'lib/restfulcalls_jump'

module Capybara
  class << self
    alias_method :old_reset_sessions!, :reset_sessions!

    def reset_sessions!
    end
  end
end

class TimeOut
  READTIMEOUT_CONST = 260
  WAIT_CONTROL_CONST = 45
end

def start_browser
  xml_content = File.read $LOAD_PATH.detect { |path| path.index('data.xml') }
  web_driver = Nokogiri::XML(xml_content).search('//web_driver').text if xml_content

  case web_driver
  when 'FIREFOX'
    TestDriverManager.run_with(:firefox)
  when 'CHROME'
    TestDriverManager.run_with(:chrome)
  when 'IE'
    TestDriverManager.run_with(:internet_explorer)
  else
    TestDriverManager.run_with(:webkit)
  end
end
