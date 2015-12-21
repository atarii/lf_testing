require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'

=begin
Verify that user can redeem value code to account
=end

# ATG page
HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_login_register_page = nil
atg_my_profile_page = nil
cookie_session_id = nil

# Account info
email = Data::EMAIL_EXIST_BALANCE_CONST
password = Data::PASSWORD_CONST
account_balance_before = account_balance_after = ''
pin = ''

feature "DST04 - Account Management - Redeem Code - Value - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  next unless pin_available?(Data::ENV_CONST, Data::LOCALE_CONST)

  before :all do
    cookie_session_id = atg_home_page.load
  end

  context 'Print Session ID' do
    scenario '' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end

  context "Login to an existing account '#{email}'" do
    scenario '1. Go to Login/Register page' do
      atg_login_register_page = atg_home_page.goto_login
      pending "***1. Go to Login/Register page (URL: #{atg_login_register_page.current_url})"
    end

    scenario "2. Login to an existing account (Email: #{email})" do
      atg_my_profile_page = atg_login_register_page.login(email, password)
    end
  end

  context 'Redeem value card' do
    scenario '1. Get existing Account Balance before redeem' do
      atg_my_profile_page.mouse_hover_my_account_link
      account_balance_before = atg_my_profile_page.account_balance
      pending "***1. Get existing Account Balance before redeem: '#{account_balance_before}'"
    end

    scenario '2. Click on Redeem Code link' do
      atg_my_profile_page.click_redeem_code_link
    end

    scenario '3. Redeem a value code' do
      pin = atg_my_profile_page.redeem_code
      if pin.blank?
        fail 'Error while redeem code. Please re-check!'
      else
        pending "***3. Redeem a value code: '#{pin}'"
      end
    end

    scenario '4. Get Account Balance after redeem' do
      if pin.blank?
        skip 'Error while redeem code. Please re-check!'
      else
        atg_my_profile_page.mouse_hover_my_account_link
        account_balance_after = atg_my_profile_page.account_balance
        pending "***4. Get existing Account Balance after redeem: '#{account_balance_after}'"
      end
    end

    scenario '5. Verify Account Balance is updated' do
      if pin.blank?
        skip 'Error while redeem code. Please re-check!'
      else
        expect(Title.cal_account_balance(account_balance_before, pin['amount'], Data::LOCALE_CONST.upcase)).to eq(account_balance_after)
      end
    end
  end
end
