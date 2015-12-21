require File.expand_path('../../spec_helper', __FILE__)
require 'capybara/rspec'
require 'atg_home_page'
require 'csc_login_page'

=begin
ATG Heartbeat checking: Verify ATG Content web, ATG Cabo links work well (response status is 200)
=end

endpoint_file = "#{Data::CONST_PROJECT_PATH}/data/atg_endpoint.txt"
endpoints = []
sessionid = nil

feature "ATG Heartbeat Checking - #{Data::ENV_CONST}", js: true do

  file_obj = File.new(endpoint_file, 'r')
  while (line = file_obj.gets)
    url = Title.convert_env(line.chomp % Data::ENV_CONST.downcase)
    res = LFCommon.get_http_code(url).to_s
    endpoints.push(url: url, res: res)
  end
  file_obj.close # remember to close the file

  endpoints.each do |endpoint|
    context "URL #{endpoint[:url]}" do
      # Send request and check response status
      scenario "response: #{endpoint[:res]}" do
        if endpoint[:url].include?('atg') && endpoint[:url].include?('csc')
          visit endpoint[:url]

          if Capybara.default_driver == :webkit
            sessionid = page.driver.cookies['JSESSIONID']
          else
            cookies = Capybara.current_session.driver.browser.manage.all_cookies
            cookies.each do |cookie|
              sessionid = cookie[:value] if cookie[:name] == 'JSESSIONID'
            end
          end
          expect(sessionid).not_to eq(nil)
        else
          expect(endpoint[:res]).to eq('200')
        end
      end
    end
  end
end
