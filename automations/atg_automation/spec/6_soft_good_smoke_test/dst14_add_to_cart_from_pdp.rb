require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_app_center_page'
require 'atg_login_register_page'
require 'atg_product_detail_page'
require 'atg_checkout_page'
require 'atg_wishlist_page'

=begin
  Verify user can add product to cart successfully from PDP page
=end

HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_app_center_page = AppCenterCatalogATG.new
atg_product_pdp_page = ProductDetailATG.new
atg_checkout_page = CheckOutATG.new
cookie_session_id = nil

# product info
prod_info = nil
cart_info = cart_dropdown_info = []
item_num1 = item_num2 = 0

# Account information
email = Data::EMAIL_EXIST_FULL_CONST
password = Data::PASSWORD_CONST

feature "DST14 - Catalog - Add to Cart from PDP - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  before :all do
    # Login to LF account
    cookie_session_id = atg_home_page.load
    atg_login_register_page = atg_home_page.goto_login
    atg_login_register_page.login(email, password)

    # Delete all items in Cart page
    atg_app_center_page.sg_go_to_check_out
    atg_checkout_page.delete_all_items_in_cart_page
  end

  context 'Print Session ID' do
    scenario '' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end

  context 'Open PDP page and add product to Cart' do
    scenario '1. Go to AppCenter page' do
      atg_home_page.load
      pending "***1. Go to AppCenter page (URL: #{atg_home_page.current_url})"
    end

    scenario 'Get the number of added item in cart page' do
      item_num1 = atg_home_page.cart_item_number
      pending "***The number of added items in Cart: #{item_num1}"
    end

    scenario '2. Search for product from Catalog page' do
      atg_home_page.search_chosen_product_by
    end

    scenario '3. Open the PDP' do
      obj_temp = atg_home_page.click_chosen_product('link')
      prod_info = obj_temp[1]
      pending "***3. Open the PDP (URL: #{atg_product_pdp_page.current_url})"
    end

    scenario '4. Verify PDP page is displayed' do
      expect(atg_product_pdp_page.product_pdp_page_displays?(prod_info[:id])).to eq(true)
    end

    scenario "5. Click on 'Add to Cart' button from PDP page" do
      atg_product_pdp_page.sg_add_to_cart_from_pdp
    end
  end

  context 'Verify product info in Cart page' do
    scenario '1. Go to Cart page' do
      cart_page = atg_app_center_page.sg_go_to_check_out
      pending "***1. Go to Cart page (URL: #{cart_page.current_url})"
    end

    scenario '2. Get items information in Cart' do
      info = atg_checkout_page.get_items_info_in_cart
      cart_info = info.find { |e| e[:prod_id].include?(prod_info[:id]) }
    end

    scenario 'Reporting item information' do
      pending "*** Title = #{prod_info[:title]}"
    end

    scenario '3. Verify app is added to Cart page with correct product ID' do
      expect(cart_info[:prod_id]).to eq(prod_info[:id])
    end

    scenario '4. Verify app is added to Cart page with correct Title' do
      expect(cart_info[:title]).to eq("#{prod_info[:cart_title]}")
    end

    scenario '5. Verify app is added to Cart page with correct Price' do
      if prod_info[:price].blank?
        expect(cart_info[:strike]).to eq(prod_info[:strike])
        expect(cart_info[:sale]).to eq(prod_info[:sale])
      else
        expect(cart_info[:price]).to eq(prod_info[:price])
      end
    end
  end

  context 'Verify product information under App Center Dropdown' do
    scenario 'Get the number of added item in cart page' do
      item_num2 = atg_home_page.cart_item_number
      pending "***The number of added items in Cart: #{item_num2}"
    end

    scenario '1. Verify the number of added items in Cart (next to \'App Center\' link)' do
      expect(item_num2).to eq(item_num1 + 1)
    end

    scenario '2. Get product info under Cart dropdown' do
      info = atg_home_page.get_item_info_in_cart_dropdown
      cart_dropdown_info = info.find { |e| e[:prod_id].include?(prod_info[:id]) }
    end

    scenario 'Reporting item information' do
      pending "***Title = #{prod_info[:title]}"
    end

    scenario '3. Verify app displays on Cart Drop down with correct product ID' do
      expect(cart_dropdown_info[:prod_id]).to eq(prod_info[:id])
    end

    scenario '4. Verify app displays on Cart Drop down with correct Title' do
      expect(cart_dropdown_info[:title]).to eq("#{prod_info[:cart_title]}")
    end

    scenario '5. Verify app displays on Cart Drop down with correct Price' do
      if prod_info[:price].blank?
        expect(cart_dropdown_info[:strike]).to eq(prod_info[:strike])
        expect(cart_dropdown_info[:sale]).to eq(prod_info[:sale])
      else
        expect(cart_dropdown_info[:price]).to eq(prod_info[:price])
      end
    end
  end

  after :all do
    atg_checkout_page.delete_all_items_in_cart_page
  end
end
