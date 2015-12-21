require File.expand_path('../../spec_helper', __FILE__)

=begin
  Verify Paypal is not an option when user has account balance
=end

env = Data::ENV_CONST.upcase
if env != 'PREVIEW' && env != 'PROD'
  require 'atg_home_page'
  require 'atg_app_center_page'
  require 'atg_login_register_page'
  require 'atg_my_profile_page'

  # initial variables
  HomeATG.set_url URL::ATG_APP_CENTER_URL
  atg_home_page = HomeATG.new
  atg_app_center_page = AppCenterCatalogATG.new
  atg_my_profile_page = MyProfileATG.new
  atg_checkout_page = nil

  # Account information
  email = Data::EMAIL_GUEST_CONST
  password = Data::PASSWORD_CONST
  account_balance = nil
  atg_checkout_payment_page = nil

  feature "DST24 - Verify Paypal is not an option when user has account balance - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
    next unless pin_available?(Data::ENV_CONST, Data::LOCALE_CONST)

    check_status_url_and_print_session atg_home_page

    context 'Precondition - Create new account and link to all devices' do
      context 'Create new account and link to all devices' do
        create_account_and_link_all_devices(Data::FIRSTNAME_CONST, Data::LASTNAME_CONST, email, password, password)
      end
    end

    context 'Redeem value card' do
      scenario '1. Click on Redeem Code link' do
        atg_my_profile_page.mouse_hover_my_account_link
        atg_my_profile_page.click_redeem_code_link
      end

      scenario '2. Redeem a value code' do
        pin = atg_my_profile_page.redeem_code
        if pin.blank?
          fail 'Error while redeem code. Please re-check!'
        else
          pending "***3. Redeem a value code: '#{pin}'"
        end
      end
    end

    context 'Add to Cart from the App Center Catalog Page' do
      scenario '1. Go to App Center home page' do
        atg_home_page.load
        pending("***1. Go to App Center home page #{atg_home_page.current_url}")
      end

      scenario '2. Get current account balance' do
        atg_app_center_page.mouse_hover_my_account_link
        account_balance = atg_app_center_page.account_balance
      end

      scenario '3. Add app to Cart' do
        product_id = atg_app_center_page.get_random_pro_greater_acc_balance(account_balance.delete('$').to_f)
        atg_app_center_page.add_to_cart_from_catalog product_id[:prod_id]
      end

      scenario '4. Go to App Center check out page' do
        atg_checkout_page = atg_app_center_page.sg_go_to_check_out
        pending("***4. Go to App Center check out page #{atg_checkout_page.current_url}")
      end
    end

    context 'Verify PayPal button does not display on Payment page' do
      scenario '1. Go to Payment page' do
        atg_checkout_payment_page = atg_checkout_page.sg_go_to_payment
        pending("***1. Go to Payment page #{atg_checkout_payment_page.current_url}")
      end

      scenario "2. Verify the Account Balance amount is #{account_balance}" do
        acc_balance_in_payment = atg_checkout_payment_page.account_balance.text
        expect(acc_balance_in_payment).to include(account_balance)
      end

      scenario '3. Verify the cart total is greater Account Balance' do
        cart_total = atg_checkout_payment_page.cart_total.text.delete('$').to_f
        expect(cart_total).to be > account_balance.delete('$').to_f
      end

      scenario '3. Verify PayPal button does not display on the Payment page' do
        expect(atg_checkout_payment_page.paypal_button_exist?).to eq(false)
      end
    end
  end
else
  feature 'Disable order purchasing in tests for the Preview and Production environments' do
    scenario 'Disable order purchasing for the <b>Preview</b> and <b>Production</b> environments' do
    end
  end
end
