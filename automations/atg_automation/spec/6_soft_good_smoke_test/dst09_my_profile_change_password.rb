require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'
require 'atg_checkout_page.rb'

=begin
Verify that user can update password
=end

# initial variables
HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_login_register_page = nil
atg_my_profile_page = nil
cookie_session_id = nil

# Account information
email = Data::EMAIL_GUEST_CONST
first_name = Data::FIRSTNAME_CONST
last_name = Data::LASTNAME_CONST
password = Data::PASSWORD_CONST
new_password = '987654321'

feature "DST09 - Account Management - My profile - Change Password - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  before :all do
    cookie_session_id = atg_home_page.load
  end

  context 'Print Session ID' do
    scenario '' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end

  context 'Pre-Condition: Create new account' do
    scenario '1. Go to Login/Register page' do
      atg_login_register_page = atg_home_page.goto_login
      pending "***1. Go to Login/Register page (URL: #{atg_login_register_page.current_url})"
    end

    scenario "2. Register new account (Email: #{email} - Password: #{password})" do
      atg_my_profile_page = atg_login_register_page.register(first_name, last_name, email, password, password)
    end
  end

  context 'Change password' do
    scenario '1. Go to My Profile > Account Information ' do
      atg_my_profile_page.goto_account_information
      pending "***1. Go to My Profile > Account Information (URL: #{atg_my_profile_page.current_url})"
    end

    scenario "2. Click \'Change Password\' under Account information and change password (New password = '#{new_password}')" do
      atg_my_profile_page.change_password(password, new_password)
    end

    scenario '3. Log-out account' do
      atg_my_profile_page.logout
    end

    scenario '4. Log-in with old password' do
      atg_login_register_page = atg_home_page.goto_login
      atg_login_register_page.login(email, password)
    end

    scenario "5. Verify an error message 'The email address or password you entered is incorrect. Please try again' displays" do
      expect(atg_login_register_page.login_error_message).to eq('The email address or password you entered is incorrect. Please try again.')
    end

    scenario '6. Log-in with new password' do
      atg_login_register_page.login(email, new_password)
    end

    scenario '7. Verify user can login with new password' do
      expect(atg_my_profile_page.my_profile_page_exist?).to eq(true)
    end
  end
end
