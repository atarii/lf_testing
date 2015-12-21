require File.expand_path('../../spec_helper', __FILE__)

=begin
  Verify User must pay remaining balance of the purchase (not covered by account balance) with a Credit card
  Total should equal the total amount minus the remainder of the account balance
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
  atg_my_profile_page = MyProfileATG.new
  atg_checkout_page = nil
  atg_review_page = nil
  atg_confirmation_page = nil
  atg_checkout_payment_page = nil
  account_balance_before = nil
  account_balance_after = nil
  currency = Title.map_currency Data::LOCALE_CONST.upcase
  pin = nil
  order_id = nil

  # Account information
  first_name = Data::FIRSTNAME_CONST
  last_name = Data::LASTNAME_CONST
  email = Data::EMAIL_GUEST_CONST
  password = Data::PASSWORD_CONST

  feature "DST26 - Checkout - Purchase Flow - Account Balance + Saved CC - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
    next unless pin_available?(Data::ENV_CONST, Data::LOCALE_CONST)

    check_status_url_and_print_session atg_home_page

    context 'Create new account and link to all devices' do
      create_account_and_link_all_devices(first_name, last_name, email, password, password)
    end

    context 'Redeem a Value Code' do
      scenario '1. Get existing Account Balance' do
        atg_my_profile_page.mouse_hover_my_account_link
        account_balance_before = atg_my_profile_page.account_balance
        pending "***1. Get existing Account Balance before redeem : #{account_balance_before}"
      end

      scenario '2. Click on Redeem Code link' do
        atg_my_profile_page.click_redeem_code_link
      end

      scenario '3. Redeem a value code' do
        pin = atg_my_profile_page.redeem_code
      end

      scenario '4. Get Account Balance after redeem' do
        if pin.blank?
          skip 'Error while redeem code. Please re-check!'
        else
          atg_my_profile_page.mouse_hover_my_account_link
          account_balance_after = atg_my_profile_page.account_balance
          pending "***4. Get existing Account Balance after redeem: #{account_balance_after}"
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

    context 'Add app and go to Checkout page' do
      scenario '1. Go to App Center home page' do
        atg_home_page.load
        pending("***1. Go to App Center home page (URL:#{atg_home_page.current_url})")
      end

      scenario '2. Add a digital item or items to the cart that so that the subtotal is greater than the user\'s account balance' do
        atg_app_center_page.mouse_hover_my_account_link
        current_ab = atg_app_center_page.account_balance
        product_info = atg_app_center_page.get_random_pro_greater_acc_balance(current_ab.delete(currency).to_f)
        atg_app_center_page.add_to_cart_from_catalog product_info[:prod_id]
      end

      scenario '3. Go to App Center check out page' do
        atg_checkout_page = atg_app_center_page.sg_go_to_check_out
        pending("***3. Go to App Center check out page (URL: #{atg_checkout_page.current_url})")
      end
    end

    context 'Go to Payment page and enter Credit Card' do
      scenario '1. Go to Payment page' do
        atg_checkout_payment_page = atg_checkout_page.sg_go_to_payment
        pending("***1. Go to Payment page (URL: #{atg_checkout_payment_page.current_url})")
      end

      scenario '2. Enter credit card and Billing address' do
        credit_card = {
          card_number: Data::CARD_NUMBER_CONST,
          card_name: Data::NAME_ON_CARD_CONST,
          exp_month: Data::EXP_MONTH_NAME_CONST,
          exp_year: Data::EXP_YEAR_CONST,
          security_code: Data::SECURITY_CODE_CONST
        }

        billing_address = {
          street: Data::ADDRESS1_CONST,
          city: Data::CITY_CONST,
          state: Data::STATE_CODE_CONST,
          postal: Data::ZIP_CONST,
          phone_number: Data::PHONE_CONST
        }

        atg_review_page = atg_checkout_payment_page.add_credit_card(credit_card, billing_address)
      end

      scenario '3. Place order and go to Confirmation page' do
        atg_confirmation_page = atg_review_page.place_order
        order_id = atg_confirmation_page.get_order_id
        atg_confirmation_page.record_order_id email
      end

      scenario 'Order number =' do
        pending("***Order number = #{order_id})")
      end
    end

    context 'Verify information on Confirmation page' do
      scenario '1. Verify Payment Method include Credit Card' do
        expect(atg_confirmation_page.payment_method?(Data::CARD_TYPE_CONST)).to eq(true)
      end

      scenario '2. Verify Payment Method include Account Balance' do
        expect(atg_confirmation_page.payment_method?('Account Balance')).to eq(true)
      end

      scenario '3. Verify Total equal the total amount minus the remainder of the account balance' do
        order_total = atg_confirmation_page.order_total.split(currency)[1].to_f
        account_balance = atg_confirmation_page.get_account_balance.split(currency)[1].to_f
        sale_tax = atg_confirmation_page.sale_tax.split(currency)[1].to_f
        order_subtotal = atg_confirmation_page.sub_total.split(currency)[1].to_f

        expect(order_total).to eq(order_subtotal - account_balance + sale_tax)
      end
    end
  end
else
  feature 'Disable order purchasing in tests for the Preview and Production environments' do
    scenario 'Disable order purchasing for the <b>Preview</b> and <b>Production</b> environments' do
    end
  end
end
