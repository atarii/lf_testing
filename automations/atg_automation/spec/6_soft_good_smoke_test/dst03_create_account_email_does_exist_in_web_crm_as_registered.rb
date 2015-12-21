require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'

=begin
Verify that user can't register a new account with an email that exists in Web CRM
=end

# ATG page
HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_login_register_page = nil
atg_my_profile_page = nil

# Web Service
customer_info_res = nil
caller_id = ServicesInfo::CONST_CALLER_ID

# Account info
email = Data::EMAIL_GUEST_CONST
first_name = Data::FIRSTNAME_CONST
last_name = Data::LASTNAME_CONST
password = Data::PASSWORD_CONST

feature "DST03 - Account Management - Create Account - Email DOES exist in WEBCRM as REGISTERED - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  context 'Create new ATG account' do
    check_status_url_and_print_session atg_home_page

    context "Pre-Condition: Create new account - Email: #{email}" do
      context 'Go to LF.com and create a new account' do
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
      end

      context 'Verify account information by using Web Service call' do
        scenario 'Fetch customer info' do
          customer_info_res = CustomerManagement.lookup_customer_by_username(caller_id, email)
        end

        scenario "1. Verify First name is '#{first_name}'" do
          expect(customer_info_res.xpath('//customer/@first-name').text).to eq(first_name)
        end

        scenario "2. Verify Last name is '#{last_name}'" do
          expect(customer_info_res.xpath('//customer/@last-name').text).to eq(last_name)
        end

        scenario "3. Verify Email is '#{email}'" do
          expect(customer_info_res.xpath('//customer/email').text).to eq(email)
        end

        after :all do
          atg_my_profile_page.logout
        end
      end
    end

    context 'Register new account with Email meeting Pre-condition' do
      scenario '1. Go to Login/Register page' do
        atg_login_register_page = atg_home_page.goto_login
        pending "***1. Go to Login/Register page (URL: #{atg_login_register_page.current_url})"
      end

      scenario "2. Register new account (Email: #{email})" do
        atg_login_register_page.register(first_name, last_name, email, password, password)
      end

      scenario '3. Verify \'An account has already been created using this email address.\' error message displays' do
        expect(atg_login_register_page.register_error_message).to eq('An account has already been created using this email address.')
      end
    end
  end
end
