require File.expand_path('../../spec_helper', __FILE__)

=begin
  Verify that user can check out successfully with a new account by using Credit Card payment method
=end

env = Data::ENV_CONST.upcase
if env != 'PREVIEW' && env != 'PROD'
  require 'atg_home_page'
  require 'atg_app_center_page'
  require 'atg_login_register_page'
  require 'mail_home_page'
  require 'mail_detail_page'

  # initial variables
  HomeATG.set_url URL::ATG_APP_CENTER_URL
  atg_home_page = HomeATG.new
  atg_app_center_page = AppCenterCatalogATG.new
  mail_home_page = HomePageMail.new
  mail_detail_page = nil
  atg_checkout_page = nil
  atg_checkout_payment_page = nil
  atg_review_page = nil
  atg_confirmation_page = nil
  atg_my_profile_page = nil

  # Account information
  email = Data::EMAIL_GUEST_CONST
  password = Data::PASSWORD_CONST

  # Product checkout info
  order_id = nil
  prod_info = nil
  prod_price = nil
  overview_info = nil
  total_price = nil
  order_total_price = nil
  sale_tax = nil
  payment_method = nil

  feature "DST22 - Checkout - Purchase Flow - Credit Card - Registered User - Add Card at checkout - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
    check_status_url_and_print_session atg_home_page

    context 'Create new account and link to all device' do
      create_account_and_link_all_devices(Data::FIRSTNAME_CONST, Data::LASTNAME_CONST, email, password, password)
    end

    context 'Check out product with Credit Card' do
      scenario '1. Go to App Center home page' do
        atg_home_page.load
        pending("***1. Go to App Center home page (URL: #{atg_home_page.current_url})")
      end

      scenario '2. Add app to cart' do
        prod_info = atg_app_center_page.sg_get_random_product_info
        prod_price = (prod_info[:price].nil?) ? prod_info[:sale] : prod_info[:price]
        atg_app_center_page.add_to_cart_from_catalog prod_info[:id]
      end

      scenario '3. Go to Check Out page' do
        atg_checkout_page = atg_app_center_page.sg_go_to_check_out
        pending("***3. Go to Check Out page (URL: #{atg_checkout_page.current_url})")
      end

      scenario '4. Go to Payment page' do
        atg_checkout_payment_page = atg_checkout_page.sg_go_to_payment
        pending("***4. Go to Payment page (URL:#{atg_checkout_payment_page.current_url})")
      end

      scenario '5. Enter credit card and Billing address' do
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

      scenario '6. Place order and go to Confirmation page' do
        sale_tax = atg_review_page.get_sale_tax
        atg_confirmation_page = atg_review_page.place_order
        order_id = atg_confirmation_page.get_order_id
        overview_info = atg_confirmation_page.get_order_overview_info
        atg_confirmation_page.record_order_id email
      end

      scenario 'Order number =' do
        pending("***Order number = #{order_id})")
      end
    end

    context 'Verify information on Confirmation page' do
      scenario '1. Verify complete order message' do
        expect(overview_info[:complete]).to match(ProductInformation::ORDER_COMPLETE_MESSAGE_CONST)
      end

      scenario '2. Verify Order detail info' do
        total_price = atg_confirmation_page.cal_total_price(prod_price)
        order_total_price = atg_confirmation_page.calculate_order_total
        prod_info[:title] = prod_info[:title].delete('...') if prod_info[:title].include? '...'

        if prod_info[:price].nil?
          expect(overview_info[:details]).to include("Order Details Digital Download Items Price #{prod_info[:title]} #{prod_info[:strike]} #{prod_info[:sale]} Order Subtotal: $#{total_price} Sales Tax: $#{sale_tax}")
        else
          expect(overview_info[:details]).to include("Order Details Digital Download Items Price #{prod_info[:title]} #{prod_info[:price]} Order Subtotal: $#{total_price} Sales Tax: $#{sale_tax}")
        end
      end

      scenario '3. Verify Order total' do
        expect(overview_info[:details]).to include("Order Total: $#{order_total_price}")
      end

      scenario '4. Verify Payment method' do
        payment_method = "#{Data::CARD_TEXT_CONST} $#{order_total_price}"
        expect(overview_info[:details]).to include("Payment Method #{payment_method}")
      end

      scenario '5. Verify Order summary info' do
        expect(overview_info[:summary]).to eq(ProductInformation::SG_ORDER_SUMMARY_TEXT_CONST % email)
      end
    end

    context 'Verify order number displays on My Account page' do
      scenario '1. Go to My Account page' do
        atg_my_profile_page = atg_confirmation_page.goto_my_account
        pending("***1. Go to My Account page (URL:#{atg_my_profile_page.current_url})")
      end

      scenario '2. Verify order number displays' do
        expect(atg_my_profile_page.order_number_exist?(order_id)).to eq(true)
      end
    end

    context 'Verify information on Email page' do
      scenario 'Go to Email page' do
        mail_detail_page = mail_home_page.go_to_mail_detail email
      end

      scenario '1. Verify Order number' do
        expect(mail_detail_page.order_number).to eq("ORDER NUMBER: #{order_id}")
      end

      scenario '2. Verify Order Sub total' do
        expect(mail_detail_page.order_sub_total).to eq("Order subtotal: $#{total_price}")
      end

      scenario '3. Verify Payment method info' do
        expect(mail_detail_page.payment_method).to eq(payment_method.gsub(/\s/, ''))
      end

      scenario '4. Verify Bill To info' do
        expect(mail_detail_page.bill_to_info).to eq(ProductInformation::ADDRESS_CONST)
      end
    end
  end
else
  feature 'Disable order purchasing in tests for the Preview and Production environments' do
    scenario 'Disable order purchasing for the <b>Preview</b> and <b>Production</b> environments' do
    end
  end
end
