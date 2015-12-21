require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'

=begin
Verify that user can add a new address into account at Account Management page
=end

# initial variables
HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_login_register_page = nil
atg_my_profile_page = nil
cookie_session_id = nil

# Account info
email = Data::EMAIL_GUEST_CONST
first_name = Data::FIRSTNAME_CONST
last_name = Data::LASTNAME_CONST
password = Data::PASSWORD_CONST

feature "DST05 - Account Management - My profile - Add Address - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  before :all do
    cookie_session_id = atg_home_page.load
  end

  context 'Print Session ID' do
    scenario '' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end

  context 'Add new Address to account' do
    scenario '1. Go to Login/Register page' do
      atg_login_register_page = atg_home_page.goto_login
      pending "***1. Go to Login/Register page (URL: #{atg_login_register_page.current_url})"
    end

    scenario "2. Register new account (Email: #{email})" do
      atg_my_profile_page = atg_login_register_page.register(first_name, last_name, email, password, password)
    end

    scenario '3. Verify My Profile page displays' do
      expect(atg_my_profile_page.my_profile_page_exist?).to eq(true)
    end

    scenario '4. Go to My Profile > Account Information ' do
      atg_my_profile_page.goto_account_information
      pending "***4. Go to My Profile > Account Information (URL: #{atg_my_profile_page.current_url})"
    end

    scenario '5. Add new address information' do
      atg_my_profile_page.add_new_address Data::ADDRESS
    end

    scenario '6. Verify Address information' do
      expect(atg_my_profile_page.get_address_info).to eq(Data::EX_ADDRESS_INFO)
    end
  end

  after :all do
    atg_my_profile_page.delete_all_addresses
  end
end
