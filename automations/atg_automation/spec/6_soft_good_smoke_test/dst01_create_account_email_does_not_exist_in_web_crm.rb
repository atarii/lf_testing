require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'

=begin
Verify that user can register a new account when a email that does not exist in Web CRM
=end

# ATG page
HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_login_register_page = nil
atg_my_profile_page = nil

# Web Service
env = Data::ENV_CONST.downcase
caller_id = ServicesInfo::CONST_CALLER_ID
customer_info_res = nil

# Account information
first_name = Data::FIRSTNAME_CONST
last_name = Data::LASTNAME_CONST
password = Data::PASSWORD_CONST
account_data = [
  { email: Generate.email('atg', env, 'en_us'), locale: 'en_US', country: 'USA', code: '99801-1267' },
  { email: Generate.email('atg', env, 'en_ca'), locale: 'en_CA', country: 'Canada', code: 'L0R 1P0' },
  { email: Generate.email('atg', env, 'en_uk'), locale: 'en_GB', country: 'UK', code: 'AB10 6AA' },
  { email: Generate.email('atg', env, 'en_ie'), locale: 'en_IE', country: 'Ireland', code: '99801-1267' },
  { email: Generate.email('atg', env, 'en_au'), locale: 'en_AU', country: 'Australia', code: '3146' },
  { email: Generate.email('atg', env, 'en_nz'), locale: 'en_NZ', country: 'New Zealand', code: '3444' },
  { email: Generate.email('atg', env, 'en_oe'), locale: 'en_OE', country: 'Other', code: nil }
]

feature "DST01 - Account Management - Create Account - Email does not exist in WEBCRM - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  account_data.each do |data|
    context "Create new ATG account - Country: '#{data[:country]}'" do
      check_status_url_and_print_session atg_home_page

      context 'Go to Login/Register page and register new account' do
        scenario '1. Go to Login/Register page' do
          atg_login_register_page = atg_home_page.goto_login
          pending "***1. Go to Login/Register page (URL: #{atg_login_register_page.current_url})"
        end

        scenario "2. Register new account (Email: #{data[:email]})" do
          atg_my_profile_page = atg_login_register_page.register(first_name, last_name, data[:email], password, password, data[:code], data[:locale])
        end

        scenario '3. Verify My Profile page displays' do
          expect(atg_my_profile_page.my_profile_page_exist?).to eq(true)
        end

        scenario "4. Verify 'Login / Register' Menu Item becomes 'My Account'" do
          expect(atg_my_profile_page.login_register_text).to eq('My Account')
        end

        scenario "5. Verify 'My Account Menu' will have 'Welcome #{first_name}' as the first item" do
          atg_my_profile_page.mouse_hover_my_account_link
          expect(atg_my_profile_page.welcome_text).to eq('Welcome ' + first_name + '!')
        end
      end

      context 'Verify account information by using Web Service call' do
        scenario 'Fetch customer info' do
          customer_info_res = CustomerManagement.lookup_customer_by_username(caller_id, data[:email])
        end

        scenario "1. Verify First name is '#{first_name}'" do
          expect(customer_info_res.xpath('//customer/@first-name').text).to eq(first_name)
        end

        scenario "2. Verify Last name is '#{last_name}'" do
          expect(customer_info_res.xpath('//customer/@last-name').text).to eq(last_name)
        end

        scenario "3. Verify Email is '#{data[:email]}'" do
          expect(customer_info_res.xpath('//customer/email').text).to eq(data[:email])
        end

        scenario "4. Verify Zip-code is '#{data[:code]}'" do
          expect(customer_info_res.xpath('//customer/address/region/@postal-code').text).to eq(data[:code])
        end unless data[:code].nil?

        scenario "5. Verify Locale is '#{data[:locale]}'" do
          expect(customer_info_res.xpath('//customer/@locale').text).to eq(data[:locale])
        end
      end

      after :all do
        atg_my_profile_page.logout
      end
    end
  end
end
