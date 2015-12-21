require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'

=begin
Verify that user can login with an existing account successfully
=end

# initial variables
HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_login_register_page = nil
atg_my_profile_page = nil
cookie_session_id = nil

# Account info
email = Data::EMAIL_EXIST_EMPTY_CONST
password = Data::PASSWORD_CONST
first_name = Data::FIRSTNAME_CONST
account_info = "#{first_name} #{Data::LASTNAME_CONST} #{email} #{Data::COUNTRY_CONST}"

feature "DST11A - Account Management - Login User - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  before :all do
    cookie_session_id = atg_home_page.load
  end

  context 'Print Session ID' do
    scenario '' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end

  context 'Login to an existing Account' do
    scenario '1. Click \'Login / Register\' > \'Login / Register\'' do
      atg_login_register_page = atg_home_page.goto_login
      pending "***1. Click Login / Register > Login / Register (URL: #{atg_login_register_page.current_url})"
    end

    scenario "2. Login with an existing account (Email: #{email} - Password: #{password})" do
      atg_my_profile_page = atg_login_register_page.login(email, password)
    end

    scenario '3. Verify My Account Page is loaded' do
      expect(atg_my_profile_page.my_profile_page_exist?).to eq(true)
    end

    scenario '4. Verify \'Login / Register\' menu Item becomes \'My Account\'' do
      expect(atg_my_profile_page.login_register_text).to eq('My Account')
    end

    scenario "5. Verify 'My Account Menu' will have 'Welcome #{first_name}' as the first item" do
      atg_my_profile_page.mouse_hover_my_account_link
      expect(atg_my_profile_page.welcome_text).to eq('Welcome ' + first_name + '!')
    end
  end

  context 'On My Profile page' do
    scenario '1. Go to \'Account Information\' page' do
      atg_my_profile_page.goto_account_information
      pending "***3. Go to My Profile > Account Information (URL: #{atg_my_profile_page.current_url})"
    end

    scenario '2. Verify account information displays correctly' do
      expect(atg_my_profile_page.get_account_info).to eq(account_info)
    end
  end
end
