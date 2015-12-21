require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'

=begin
Pre-condition: Create a new account with full information (address, credit card, link to all device), a new account that use for testing with Acc Balance only and a new account with empty information
=end

HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_my_profile_page = MyProfileATG.new
atg_login_register_page = nil
cookie_session_id = nil

# Account info
full_email = Data::EMAIL_GUEST_FULL_CONST
balance_email = Data::EMAIL_BALANCE_CONST
empty_email = Data::EMAIL_GUEST_EMPTY_CONST
password = Data::PASSWORD_CONST

feature 'Pre condition - Create new accounts', js: true do
  before :all do
    cookie_session_id = atg_home_page.load
  end

  context 'Print Session ID' do
    scenario '' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end

  context 'Create new account with full information' do
    create_account_and_link_all_devices(
      Data::FIRSTNAME_CONST,
      Data::LASTNAME_CONST,
      full_email,
      password,
      password
    )

    scenario "5. Go to 'Account information' page" do
      atg_my_profile_page.goto_account_information
    end

    scenario '6. Add new address information' do
      atg_my_profile_page.add_new_address Data::ADDRESS
      update_info_account full_email, Data::ADDRESS[:street]
    end

    scenario '7. Log out' do
      atg_my_profile_page.logout
    end
  end

  context 'Create new account with full information (Use for testing with Acc Balance only)' do
    create_account_and_link_all_devices(
      Data::FIRSTNAME_CONST,
      Data::LASTNAME_CONST,
      balance_email,
      password,
      password
    )

    scenario "5. Go to 'Account information' page" do
      atg_my_profile_page.goto_account_information
    end

    scenario '6. Add new address information' do
      atg_my_profile_page.add_new_address Data::ADDRESS
      update_info_account balance_email, Data::ADDRESS[:street]
    end

    scenario '7. Log out' do
      atg_my_profile_page.logout
    end
  end

  context 'Create new account with empty information' do
    scenario '1. Go to register/login page' do
      atg_login_register_page = atg_home_page.goto_login
    end

    scenario '2. Register an account' do
      atg_my_profile_page = atg_login_register_page.register(
        Data::FIRSTNAME_CONST,
        Data::LASTNAME_CONST,
        empty_email,
        password,
        password
      )
    end

    scenario '3. Verify My Profile page displays' do
      expect(atg_my_profile_page.my_profile_page_exist?).to eq(true)
    end
  end
end
