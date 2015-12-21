require File.expand_path('../../spec_helper', __FILE__)

=begin
  Verify that user can't checkout when entering a Credit Card with the expiration date in the past
=end

env = Data::ENV_CONST.upcase
if env != 'PREVIEW' && env != 'PROD'
  require 'atg_home_page'
  require 'atg_app_center_page'
  require 'atg_login_register_page'

  # initial variables
  HomeATG.set_url URL::ATG_APP_CENTER_URL
  atg_home_page = HomeATG.new
  atg_app_center_page = AppCenterCatalogATG.new
  atg_checkout_page = nil
  atg_checkout_payment_page = nil

  # Account information
  first_name = Data::FIRSTNAME_CONST
  last_name = Data::LASTNAME_CONST
  email = Data::EMAIL_GUEST_CONST
  password = Data::PASSWORD_CONST

  feature "DST30: Check out - Purchase Flow - Credit Card - Registered User - Expired CC tied to account - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
    check_status_url_and_print_session atg_home_page

    context 'Create new account and link to all devices' do
      create_account_and_link_all_devices(first_name, last_name, email, password, password)
    end

    context 'Check out product with an Expired Credit Card' do
      scenario '1. Go to App Center home page' do
        atg_home_page.load
        pending "***1. Go to AppCenter page (URL: #{atg_home_page.current_url})"
      end

      scenario '2. Perform Add to Cart from the App Center Catalog Page' do
        prod_info = atg_app_center_page.sg_get_random_product_info
        atg_app_center_page.add_to_cart_from_catalog prod_info[:id]
      end

      scenario '3. Go to App Center Cart page' do
        atg_checkout_page = atg_app_center_page.sg_go_to_check_out
        pending "***3. Go to App Center Cart page (URL: #{atg_home_page.current_url})"
      end

      scenario '4. Proceed through Checkout to the payment page' do
        atg_checkout_payment_page = atg_checkout_page.sg_go_to_payment
      end

      scenario '5. Select the card with the expiration date in the past and click Continue' do
        credit_card = {
          card_number: Data::CARD_NUMBER_CONST,
          card_name: Data::NAME_ON_CARD_CONST,
          exp_month: 'January',
          exp_year: '2015',
          security_code: Data::SECURITY_CODE_CONST
        }

        billing_address = {
          street: Data::ADDRESS1_CONST,
          city: Data::CITY_CONST,
          state: Data::STATE_CODE_CONST,
          postal: Data::ZIP_CONST,
          phone_number: Data::PHONE_CONST
        }

        atg_checkout_payment_page.add_credit_card(credit_card, billing_address)
      end

      scenario '6. Verify \'Select a valid expiration date.\' error appears' do
        expect(atg_checkout_payment_page.invalid_exp_date_text).to eq('Select a valid expiration date.')
      end
    end
  end
else
  feature 'Disable Credit Card testing on the Preview and Production environments' do
    scenario 'Disable Credit Card testing on <b>Preview</b> and <b>Production</b> environments' do
    end
  end
end
