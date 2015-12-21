require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'

=begin
Verify that ATG site is up
=end

# initial variables
atg_home_page = HomeATG.new

feature "TC01 - Health check for UAT server (#{URL::ATG_CONST}) : #{Data::ENV_CONST} - #{Data::LOCALE_CONST}", js: true do
  scenario '1. Go to LF.com page' do
    atg_home_page.load
  end

  scenario '2. Verify LeapFrog Logo displays' do
    expect(atg_home_page.leapfrog_logo['alt']).to eq('LeapFrog Logo')
    expect(atg_home_page.leapfrog_logo['src']).to eq('http://s7.leapfrog.com/is/image/LeapFrog/cq_lf_logo?$cq-png-alpha-no-resize$&hei=60')
  end

  scenario "3. Verify 'Log In / Register' link displays on Top navigate bar" do
    expect(atg_home_page.nav_account_menu.login_register_link.text).to eq('Log In / Register')
  end
end
