require File.expand_path('../../spec_helper', __FILE__)

=begin
  Verify user can check out multiple apps successfully
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
  atg_app_center_checkout_page = AppCenterCheckOutATG.new
  atg_checkout_page = nil
  atg_review_page = nil
  atg_confirmation_page = nil
  mail_home_page = HomePageMail.new
  mail_detail_page = nil

  # Account information
  email = Data::EMAIL_EXIST_FULL_CONST
  password = Data::PASSWORD_CONST

  # Product checkout info
  order_id = nil
  prod_info1 = nil
  prod_info2 = nil
  prod_price1 = nil
  prod_price2 = nil
  overview_info = nil
  total_price = nil
  sale_tax = nil
  order_total_price = nil
  payment_method = nil

  feature "DT34: Check out with multi apps by using Credit card - ENV = '#{env}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
    check_status_url_and_print_session atg_home_page

    context 'Pre-condition: Delete all items in Cart page' do
      scenario '1. Login to an existing account that has Credit Card' do
        atg_login_page = atg_home_page.goto_login
        atg_login_page.login(email, password)
      end

      scenario '2. Delete all items in Cart page' do
        atg_checkout_page = atg_app_center_page.sg_go_to_check_out
        atg_checkout_page.delete_all_checkout
      end
    end

    context 'Check out multi products' do
      scenario '1. Go to App Center home page' do
        atg_home_page.load
        pending("***1. Go to App Center home page #{atg_home_page.current_url}")
      end

      scenario '2. Add more than one app to cart' do
        prod_info1 = atg_app_center_page.sg_get_random_product_info
        prod_info2 = atg_app_center_page.sg_get_random_product_info(prod_info1[:id])
        (prod_info1[:price].nil?) ? prod_price1 = prod_info1[:sale] : prod_price1 = prod_info1[:price]
        (prod_info2[:price].nil?) ? prod_price2 = prod_info2[:sale] : prod_price2 = prod_info2[:price]
        atg_app_center_page.add_to_cart_from_catalog prod_info1[:id]
        atg_app_center_page.add_to_cart_from_catalog prod_info2[:id]
      end

      scenario '3. Go to App Center check out page' do
        atg_checkout_page = atg_app_center_page.sg_go_to_check_out
        pending("***3. Go to App Center check out page #{atg_checkout_page.current_url}")
      end

      scenario '4. Go to Payment page' do
        atg_checkout_page.sg_go_to_payment
        pending("***4. Go to Payment page #{atg_checkout_page.current_url}")
      end

      scenario '5. Select an existing Credit card' do
        atg_review_page = atg_app_center_checkout_page.sg_select_credit_card
      end

      scenario '6. Place order and go to Confirmation page' do
        sale_tax = atg_review_page.get_sale_tax
        atg_confirmation_page = atg_review_page.place_order
        order_id = atg_confirmation_page.get_order_id
        overview_info = atg_confirmation_page.get_order_overview_info
        atg_confirmation_page.record_order_id email
      end
    end

    context 'Verify information on Confirmation page' do
      scenario '1. Verify complete order message' do
        expect(overview_info[:complete]).to match(ProductInformation::ORDER_COMPLETE_MESSAGE_CONST)
      end

      scenario '2. Verify Order detail info' do
        prod_info1[:title] = prod_info1[:title].delete('...') if prod_info1[:title].include? '...'
        prod_info2[:title] = prod_info2[:title].delete('...') if prod_info2[:title].include? '...'

        total_price = '%.2f' % (atg_confirmation_page.cal_total_price(prod_price1).to_f + atg_confirmation_page.cal_total_price(prod_price2).to_f)
        (prod_info1[:price].nil?) ? order_price1 = "#{prod_info1[:strike]} #{prod_info1[:sale]}" : order_price1 = prod_info1[:price]
        (prod_info2[:price].nil?) ? order_price2 = "#{prod_info2[:strike]} #{prod_info2[:sale]}" : order_price2 = prod_info2[:price]
        expect(overview_info[:details]).to include("Order Details Digital Download Items Price #{prod_info1[:title]} #{order_price1} #{prod_info2[:title]} #{order_price2} Order Subtotal: $#{total_price} Sales Tax: $#{sale_tax}")
      end

      scenario '3. Verify Order total' do
        order_total_price = atg_confirmation_page.calculate_order_total
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

    context 'Verify information on Email page' do
      scenario 'Go to Email page' do
        mail_detail_page = mail_home_page.go_to_mail_detail email
      end

      scenario '1. Verify order number' do
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
