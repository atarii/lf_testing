require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'
require 'atg_checkout_page.rb'
require 'mail_home_page'
require 'mail_detail_page'

=begin
Verify that user can update password of account
=end

# initial variables
HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_login_register_page = nil
atg_my_profile_page = nil
mail_home_page = HomePageMail.new
mail_detail_page = nil
cookie_session_id = nil

# Account information
email = Data::EMAIL_GUEST_CONST
first_name = Data::FIRSTNAME_CONST
last_name = Data::LASTNAME_CONST
password = Data::PASSWORD_CONST
temp_password = ''

feature "DST10 - Account Management - Login - Forgot Password - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
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

    scenario '3. Log out Account' do
      atg_my_profile_page.logout
    end
  end

  context 'Reset Password' do
    scenario '1. Go to Login/Register page' do
      atg_login_register_page = atg_home_page.goto_login
      pending "***1. Go to Login/Register page (URL: #{atg_login_register_page.current_url})"
    end

    scenario '2. In Log In Section - click \'Forgot Password?\' link and enter Email to reset' do
      atg_login_register_page.reset_password email
    end

    scenario '3. Verify \'Check Your Email\' pop-up displays' do
      expect(atg_login_register_page.sent_password_overlay_display?).to eq(true)
    end
  end

  context 'Check Reset Password Email' do
    scenario '1. Go to \'Guerrillamail\' mail box' do
      mail_detail_page = mail_home_page.go_to_mail_detail(email, 2)
      pending "***1. Go to 'Guerrillamail' mail box (URL: #{mail_detail_page.current_url})"
    end

    scenario '2. Get temporary Password' do
      temp_password = mail_detail_page.get_temp_password
      pending "***2. Get temporary Password: #{temp_password}"
    end

    scenario '3. Go to LF Login/Register page' do
      atg_home_page.load
      atg_login_register_page = atg_home_page.goto_login
      pending "***3. Go to LF Login/Register page (URL: #{atg_login_register_page.current_url})"
    end

    scenario '4. Login with old password' do
      atg_my_profile_page = atg_login_register_page.login(email, password)
    end

    scenario '5. Verify My Account Page is loaded' do
      expect(atg_my_profile_page.my_profile_page_exist?).to eq(true)
    end

    scenario '6. Logout' do
      atg_my_profile_page.logout
    end

    scenario '7. Login with temporary password' do
      atg_login_register_page = atg_home_page.goto_login
      atg_my_profile_page = atg_login_register_page.login(email, temp_password)
    end

    scenario '8. Verify user is taken to Change Password page' do
      expect(atg_my_profile_page.change_password_box_displays?).to eq(true)
    end
  end
end
