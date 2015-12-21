require File.expand_path('../../spec_helper', __FILE__)
require 'vin_login_page'

=begin
Verify that Vindicia server is up and user login successfully
=end

# initial variables
vin_login_page = LoginVIN.new
vin_common_page = nil

feature "TC06 - Health check for log in to Vindicia server (#{URL::VIN_CONST})", js: true do
  before :all do
    vin_login_page.load
  end

  scenario "1. Login to vindicia sever with account: #{Data::VIN_USERNAME_CONST} / #{Data::VIN_PASSWORD_CONST}" do
    vin_common_page = vin_login_page.login(Data::VIN_USERNAME_CONST, Data::VIN_PASSWORD_CONST)
  end

  scenario "2. Verify 'CONTACT US | LOGOUT' link displays on Top navigate bar" do
    skip 'Check configured password under ATG->Config ATG->Vindicia' if vin_login_page.has_login_error_msg?(wait: TimeOut::WAIT_MID_CONST)
    expect("#{vin_common_page.contact_us_link.text} | #{vin_common_page.log_out_link.text}").to eq('CONTACT US | LOGOUT')
  end
end
