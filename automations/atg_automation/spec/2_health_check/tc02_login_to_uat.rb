require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'

=begin
Verify that ATG site is up and user login login successfully
=end

# initial variables
atg_home_page = HomeATG.new
atg_login_page = nil
atg_my_profile_page = nil

# account information
username = Data::EMAIL_EXIST_EMPTY_CONST
password = Data::PASSWORD_CONST

feature "TC02 - Login to UAT server (#{URL::ATG_CONST}) with existing credentials", js: true do
  before :all do
    atg_home_page.load
  end

  context "1. Verify 'Log In / Register' link displays on Top navigate bar" do
    scenario 'Log In / Register' do
      expect(atg_home_page.nav_account_menu.login_register_link.text).to eq('Log In / Register')
    end
  end

  context "2. Verify 'Create a Leap Frog Account' and 'Login' buttons display on 'Login Register' page" do
    scenario 'Go to LF Login page' do
      atg_login_page = atg_home_page.goto_login
    end

    scenario "Verify 'Create a LeapFrog Account' button displays" do
      expect(atg_login_page.create_account_h2.text).to eq('Create a LeapFrog Account')
    end

    scenario "Verify 'Log In' button displays" do
      expect(atg_login_page.log_in_h2.text).to eq('Log In')
    end
  end

  context '3. Login with existing account' do
    scenario "Login to ATG with account: #{username} / #{password}" do
      atg_my_profile_page = atg_login_page.login(username, password)
    end

    scenario "Verify 'My Account' link displays" do
      expect(atg_my_profile_page.nav_account_menu.login_register_link.text).to eq('My Account')
    end

    scenario "Verify 'My Profile' page displays" do
      expect(atg_my_profile_page.my_profile_page_exist?).to eq(true)
    end
  end

  # Log out account
  after :all do
    atg_my_profile_page.logout
  end
end
