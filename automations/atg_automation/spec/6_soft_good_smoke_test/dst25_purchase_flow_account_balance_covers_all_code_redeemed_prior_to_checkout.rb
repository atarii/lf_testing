require File.expand_path('../../spec_helper', __FILE__)

=begin
  Verify that user can check out successfully with an existing account by using Redeem Code
=end

env = Data::ENV_CONST.upcase
if env != 'PREVIEW' && env != 'PROD'
  require 'atg_home_page'
  require 'atg_app_center_page'
  require 'atg_login_register_page'
  require 'atg_my_profile_page'
  require 'mail_home_page'
  require 'mail_detail_page'

  HomeATG.set_url URL::ATG_APP_CENTER_URL
  atg_home_page = HomeATG.new
  atg_app_center_page = AppCenterCatalogATG.new
  atg_login_register_page = nil
  atg_my_profile_page = nil
  atg_checkout_page = nil
  atg_review_page = ReviewATG.new
  atg_confirmation_page = nil
  mail_home_page = HomePageMail.new
  mail_detail_page = nil

  # Account information
  email = Data::EMAIL_EXIST_BALANCE_CONST
  password = Data::PASSWORD_CONST

  # Product checkout info
  currency = Title.map_currency Data::LOCALE_CONST.upcase
  ab_before = ab_after = ab_after_place_order = ab_on_confirmation_page = ''
  pin = ''
  order_id = nil
  prod_info = nil
  prod_price = nil
  overview_info = nil
  payment_method = nil

  feature "DST25 - Checkout - Purchase Flow - Account Balance covers all - Code redeemed prior to checkout - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
    next unless pin_available?(Data::ENV_CONST, Data::LOCALE_CONST)

    check_status_url_and_print_session atg_home_page

    context "Login to an existing account '#{email}'" do
      scenario '1. Go to Login/Register page' do
        atg_login_register_page = atg_home_page.goto_login
        pending "***1. Go to Login/Register page (URL: #{atg_login_register_page.current_url})"
      end

      scenario "2. Login to an existing account (Email: #{email})" do
        atg_my_profile_page = atg_login_register_page.login(email, password)
      end

      after :all do
        atg_checkout_page = atg_app_center_page.sg_go_to_check_out
        atg_checkout_page.delete_all_checkout
      end
    end

    context 'Redeem value card' do
      scenario '1. Get existing Account Balance before redeem' do
        atg_my_profile_page.mouse_hover_my_account_link
        ab_before = atg_my_profile_page.account_balance
        pending "***1. Get existing Account Balance before redeem: '#{ab_before}'"
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
          ab_after = atg_my_profile_page.account_balance
          pending "***4. Get existing Account Balance after redeem: '#{ab_after}'"
        end
      end

      scenario '5. Verify Account Balance is updated' do
        if pin.blank?
          skip 'Error while redeem code. Please re-check!'
        else
          expect(Title.cal_account_balance(ab_before, pin['amount'], Data::LOCALE_CONST.upcase)).to eq(ab_after)
        end
      end
    end

    context 'Add product to Cart and go to Checkout page' do
      scenario '1. Go to App Center home page' do
        atg_home_page.load
        atg_home_page.search_chosen_product_by
        pending("***1. Go to App Center home page #{atg_home_page.current_url}")
      end

      scenario '2. Add product to cart' do
        prod_info = atg_home_page.get_chosen_product_info
        (prod_info[:price].blank?) ? prod_price = prod_info[:sale] : prod_price = prod_info[:price]
        atg_app_center_page.add_to_cart_from_catalog prod_info[:id]
      end

      scenario '3. Go to Check Out page' do
        atg_checkout_page = atg_app_center_page.sg_go_to_check_out
        pending("***3. Go to Check Out page #{atg_checkout_page.current_url}")
      end
    end

    context 'Click Checkout button and verify Payment page is skipped' do
      scenario '1. Click Checkout button' do
        atg_checkout_page.sg_go_to_payment
      end

      scenario '2. Verify Payment page is skipped' do
        expect(atg_review_page.review_page_exist?).to eq(true)
      end

      scenario '3. Go to Review page' do
        atg_confirmation_page = atg_review_page.place_order
        pending("***3. Go to Review page(URL: #{atg_confirmation_page.current_url})")
      end
    end

    context 'Verify information on Confirmation page' do
      scenario 'Go to Confirmation page' do
        ab_on_confirmation_page = atg_confirmation_page.get_account_balance.split(currency)[1]
        order_id = atg_confirmation_page.get_order_id
        overview_info = atg_confirmation_page.get_order_overview_info
        atg_confirmation_page.record_order_id(email)
      end

      scenario '1. Verify complete order message' do
        expect(overview_info[:complete]).to match(ProductInformation::ORDER_COMPLETE_MESSAGE_CONST)
      end

      scenario '2. Verify Order detail info' do
        expect(overview_info[:details]).to include('Order Details Digital Download Items Price')
      end

      scenario '3. Verify Order total should be 0.00' do
        order_total = atg_confirmation_page.order_total_cost_txt.text
        expect(order_total).to include('0.00')
      end

      scenario '4. Verify My Download Credits in the My Account Dropdown displays accurate' do
        # get account balance after place
        atg_confirmation_page.mouse_hover_my_account_link
        ab_after_place_order = atg_confirmation_page.account_balance.delete(currency).to_f

        expect(ab_after_place_order).to eq(ab_after.delete("#{currency}").to_f - ab_on_confirmation_page.to_f)
      end

      scenario "5. Verify Payment method is 'Account Balance'" do
        payment_method = "Account Balance #{currency}#{ab_on_confirmation_page}"
        expect(overview_info[:details]).to include("Payment Method #{payment_method}")
      end
    end

    context 'Verify information on Email page' do
      scenario 'Go to Email page' do
        mail_detail_page = mail_home_page.go_to_mail_detail email
      end

      scenario '1. Verify Order number' do
        expect(mail_detail_page.order_number_txt.text).to include(order_id)
      end

      scenario '2. Verify Order Sub total' do
        pending '*** Skipping all price comparisons'
      end

      scenario '3. Verify Payment method info' do
        expect(mail_detail_page.payment_method_txt.text).to eq(payment_method)
      end
    end
  end
else
  feature 'Disable order purchasing in tests for the Preview and Production environments' do
    scenario 'Disable order purchasing for the <b>Preview</b> and <b>Production</b> environments' do
    end
  end
end
