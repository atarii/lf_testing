require File.expand_path('../../spec_helper', __FILE__)

=begin
  Device stores: Verify that user can check out successfully with a new account by using Credit Card payment method
=end

env = Data::ENV_CONST.upcase
if env == 'PREVIEW' || env == 'PROD'
  describe 'Disable order purchasing in tests for the Preview and Production environments' do
    it 'Disable order purchasing for the <b>Preview</b> and <b>Production</b> environments' do
    end
  end
else
  require 'atg_home_page'
  require 'atg_dv_app_center_page'
  require 'atg_dv_check_out_page'
  require 'atg_dv_check_out_review_page'
  require 'atg_dv_check_out_confirmation_page'
  require 'atg_dv_my_account_page'
  require 'mail_home_page'
  require 'mail_detail_page'

  # Webservice info
  device_store = Data::DEVICE_STORE_CONST
  payment_method = Data::PAYMENT_TYPE_CONST

  is_french_language = device_store == 'LFC French' || device_store == 'LeapPad3 FR'
  if is_french_language
    location = 'fr_FR'
  else
    location = 'en_US'
  end
  caller_id = ServicesInfo::CONST_CALLER_ID

  # Account information
  first_name = Data::FIRSTNAME_CONST
  last_name = Data::LASTNAME_CONST
  email = Data::EMAIL_GUEST_CONST
  password = Data::PASSWORD_CONST

  # ATG page info
  if device_store.include? 'LFC'
    url = URL::ATG_DV_APP_CENTER_URL % env.downcase
  else
    url = URL::ATG_DV_APP_CENTER_URL % env.downcase + "emailAddress=#{email}"
  end
  AtgDvAppCenterPage.set_url url

  atg_dv_app_center_page = AtgDvAppCenterPage.new
  atg_dv_review_page = AtgDvCheckOutReviewPage.new
  atg_dv_my_account_page = AtgDvMyAccountPage.new
  mail_home_page = HomePageMail.new
  atg_dv_check_out_page = nil
  atg_dv_confirmation_page = nil
  cookie_session_id = ''

  # Checkout info
  prod_info = {}
  order_review_info = {}
  order_confirmation_info = {}
  order_email_info = {}
  checkout_status = true

  describe "ATG Web Checkout Smoke Test - #{device_store} - #{payment_method} - #{env}", js: true do
    next unless device_support_payment_method? device_store, payment_method

    context 'Pre-Condition: Register new account' do
      create_account_via_webservice(caller_id, first_name, last_name, email, password, location)
    end

    context "Checkout product with #{payment_method}" do
      before :each do
        skip 'SKIP: Error while checking out app' unless checkout_status
      end

      scenario '1. Go to Device Store App Center page' do
        cookie_session_id = atg_dv_app_center_page.load
        pending "***1. Go to Device Store App Center page (URL: #{url})"
      end

      scenario '' do
        pending "***SESSION_ID: #{cookie_session_id}"
      end

      scenario '2. Go to Shop All Apps' do
        atg_dv_app_center_page.dv_go_to_shop_all_apps device_store
      end

      scenario '3. Get random a product info' do
        prod_info = atg_dv_app_center_page.dv_get_random_product_info device_store
        pending "***3. Get random a product info (Prod_ID = #{prod_info[:id]})"
      end

      scenario '4. Add app to Cart' do
        atg_dv_app_center_page.dv_add_to_cart_from_catalog prod_info[:id], device_store
      end

      scenario '5. Go to Check Out page' do
        atg_dv_check_out_page = atg_dv_app_center_page.dv_go_to_check_out_page device_store
        pending "***5. Go to Check Out page (URL: #{atg_dv_check_out_page.current_url})"
      end

      scenario '6. Go to Payment page' do
        atg_dv_payment_page = atg_dv_check_out_page.dv_go_to_payment_page(email, password, device_store)
        pending "***6. Go to Payment page (URL: #{atg_dv_payment_page.current_url})"
      end

      dv_check_out_method(email, payment_method, device_store)

      scenario '8. Get order information on Review page' do
        checkout_status = atg_dv_review_page.play_order_displayed? device_store

        fail 'Fails to check out App. Please re-check!' unless checkout_status

        order_review_info = atg_dv_review_page.dv_order_review_info device_store
      end

      scenario '9. Click on Place Order button' do
        # Click on Place Order button
        atg_dv_confirmation_page = atg_dv_review_page.dv_place_order device_store

        # Get Order information on Confirmation page
        order_confirmation_info = atg_dv_confirmation_page.dv_order_confirmation_info device_store

        # Update Order id into atg_tracking table
        dv_record_order_id(email, order_confirmation_info[:order_id])
      end

      scenario 'Order number' do
        pending "***Order number = #{order_confirmation_info[:order_id]}"
      end
    end

    context 'Verify information on Confirmation page' do
      before :each do
        skip 'SKIP: Error while checking out app' unless checkout_status
      end

      scenario '1. Verify complete order message' do
        if is_french_language
          expect(order_confirmation_info[:message]).to match('Merci. Votre commande est complète.')
        else
          expect(order_confirmation_info[:message]).to match('Thank you. Your order has been completed.')
        end
      end

      scenario '2. Verify Order Sub total' do
        expect(order_confirmation_info[:order_detail][:sub_total]).to eq(order_review_info[:sub_total])
      end

      scenario '3. Verify Order Tax' do
        expect(order_confirmation_info[:order_detail][:tax]).to include(order_review_info[:tax])
      end

      scenario '4. Verify Order Total' do
        expect(order_confirmation_info[:order_detail][:order_total]).to eq(order_review_info[:order_total])
      end

      unless payment_method == 'Credit Card'
        scenario '5. Verify Account Balance' do
          expect(order_confirmation_info[:order_detail][:account_balance]).to eq(order_review_info[:account_balance])
        end
      end
    end

    context 'Verify order number displays on My Account page' do
      before :each do
        skip 'SKIP: Error while checking out app' unless checkout_status
      end

      scenario '1. Go to My Account page' do
        atg_dv_confirmation_page.dv_go_to_my_account device_store, password
      end

      scenario '2. Verify Order number' do
        order_ids = atg_dv_my_account_page.dv_order_ids
        expect(order_ids).to include(order_confirmation_info[:order_id])
      end
    end

    context 'Verify information on Email page' do
      before :each do
        skip 'SKIP: Error while checking out app' unless checkout_status
      end

      scenario '1. Go to Email page' do
        mail_detail_page = mail_home_page.go_to_mail_detail email
        order_email_info = mail_detail_page.order_email_info
      end

      scenario '2. Verify Order number' do
        if is_french_language
          expect(order_email_info[:order_number]).to eq("N° DE COMMANDE : #{order_confirmation_info[:order_id]}")
        else
          expect(order_email_info[:order_number]).to eq("ORDER NUMBER: #{order_confirmation_info[:order_id]}")
        end
      end

      scenario '3. Verify Order Sub total' do
        if is_french_language
          expect(order_email_info[:order_sub_total]).to eq("Sous-total : #{order_confirmation_info[:order_detail][:sub_total]}")
        else
          expect(order_email_info[:order_sub_total]).to eq("Order subtotal: #{order_confirmation_info[:order_detail][:sub_total]}")
        end
      end

      scenario '4. Verify Tax' do
        if order_email_info[:tax] == ''
          expect(order_email_info[:tax]).to eq(order_confirmation_info[:order_detail][:tax])
        else
          expect(order_email_info[:tax]).to eq("Tax: #{order_confirmation_info[:order_detail][:tax]}")
        end
      end

      scenario '5. Verify Purchase Total' do
        if is_french_language
          expect(order_email_info[:order_total]).to eq("Total achats : #{order_confirmation_info[:order_detail][:order_total]}")
        else
          expect(order_email_info[:order_total]).to eq("Purchase Total: #{order_confirmation_info[:order_detail][:order_total]}")
        end
      end

      unless payment_method == 'Credit Card'
        scenario '6. Verify Account Balance' do
          if is_french_language
            expect(order_email_info[:account_balance]).to eq("Solde du compte #{order_confirmation_info[:order_detail][:account_balance]}")
          else
            expect(order_email_info[:account_balance]).to eq("Account Balance #{order_confirmation_info[:order_detail][:account_balance]}")
          end
        end
      end
    end
  end
end
