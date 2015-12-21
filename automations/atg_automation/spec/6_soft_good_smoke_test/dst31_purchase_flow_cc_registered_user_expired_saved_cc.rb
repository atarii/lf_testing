require File.expand_path('../../spec_helper', __FILE__)

=begin
  Verify that user can't checkout with an account that has Expired Saved Credit Card
=end

env = Data::ENV_CONST.upcase
if env != 'PREVIEW' && env != 'PROD'
  require 'atg_home_page'
  require 'atg_login_register_page'
  require 'atg_app_center_page'
  require 'atg_app_center_checkout_page'
  require 'atg_checkout_payment_page'

  # initial variables
  HomeATG.set_url URL::ATG_APP_CENTER_URL
  atg_home_page = HomeATG.new
  atg_app_center_page = AppCenterCatalogATG.new
  atg_checkout_page = CheckOutATG.new
  atg_checkout_payment_page = PaymentATG.new

  # Account information
  email = Data::EMAIL_EXP_CREDIT_CARD_CONST
  password = Data::PASSWORD_CONST

  feature "DST31: Check out - Purchase Flow - Credit Card - Registered User - Expired Saved Credit Card - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
    check_status_url_and_print_session atg_home_page

    context 'Pre-condition: Delete all items in Cart page' do
      scenario '1. Login to an existing account that has Credit Card' do
        atg_login_page = atg_home_page.goto_login
        atg_login_page.login(email, password)
      end

      scenario '2. Delete all items in Cart page' do
        atg_app_center_page.sg_go_to_check_out
        atg_checkout_page.delete_all_items_in_cart_page
      end
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

      scenario '4. Go to Checkout to the payment page' do
        atg_checkout_payment_page = atg_checkout_page.sg_go_to_payment
        pending "***4. Go to Checkout to the payment page (URL: #{atg_checkout_payment_page.current_url})"
      end

      scenario '5. Fill in radio button of the saved credit card with an expired date' do
        atg_checkout_page.sg_select_credit_card
      end

      scenario '6. Verify Expired Credit Card Oops pop-up displays ' do
        expect(atg_checkout_payment_page.exp_credit_card_oops_popup_displays?).to eq(true)
      end

      scenario '7. Verify the text Expired Credit Card Oops pop-up' do
        expect(atg_checkout_payment_page.exp_credit_card_oops_text).to eq('Your credit card has expired. Please update your card information or select a different credit card.')
      end

      scenario '8. Close the Pop-up' do
        atg_checkout_payment_page.close_exp_credit_card_oops_popup
      end

      scenario '9. Verify User still stays on Payment page' do
        expect(atg_checkout_payment_page.payment_page_exist?).to eq(true)
      end
    end
  end
else
  feature 'Disable Credit Card testing on the Preview and Production environments' do
    scenario 'Disable Credit Card testing on <b>Preview</b> and <b>Production</b> environments' do
    end
  end
end
