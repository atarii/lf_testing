require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_app_center_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'
require 'atg_checkout_page'

=begin
  Verify user can remove an item from Dropdown Cart
=end

HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_app_center_page = AppCenterCatalogATG.new
atg_checkout_page = CheckOutATG.new
cookie_session_id = nil
item_num1 = item_num2 = 0

# Account information
email = Data::EMAIL_EXIST_EMPTY_CONST
password = Data::PASSWORD_CONST

feature "DST27 - Cart - Remove Item from Drop down cart - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  before :all do
    # Login to LF Account
    cookie_session_id = atg_home_page.load
    atg_login_page = atg_home_page.goto_login
    atg_login_page.login(email, password)

    # Delete all items in Cart page
    atg_app_center_page.sg_go_to_check_out
    atg_checkout_page.delete_all_items_in_cart_page
  end

  context 'Print Session ID' do
    scenario '' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end

  context 'Add an item to the cart from the App Center Catalog Page' do
    scenario '1. Get the number of added items in cart' do
      item_num1 = atg_home_page.cart_item_number
      pending "***Number of added items in Cart: #{item_num1}"
    end

    scenario '2. Go to App Center home page' do
      atg_home_page.load
      pending("***2. Go to App Center home page (URL: #{atg_home_page.current_url})")
    end

    scenario '3. Add an item to the cart from the App Center Catalog Page' do
      prod_info = atg_app_center_page.sg_get_random_product_info
      atg_app_center_page.add_to_cart_from_catalog prod_info[:id]
    end
  end

  context 'Verify item is added to Cart' do
    scenario '1. Get the number of added item in Cart page' do
      item_num2 = atg_home_page.cart_item_number
      pending "***Number of added item in Cart: #{item_num2}"
    end

    scenario '2. Verify the number of Cart items next to \'My Cart\' link' do
      expect(item_num2).to eq(item_num1 + 1)
    end
  end

  context 'Hover over the App Center Cart and click Remove Item from the pop-up menu' do
    scenario '1. Hover over the App Center Cart' do
      atg_home_page.hover_app_center_cart
    end

    scenario '2. Verify the remove from cart pop-up displays' do
      expect(atg_home_page.app_center_cart_dropdown_displays?).to eq(true)
    end

    scenario "3. Hover over the 'x' in the menu" do
      atg_home_page.hover_the_x_in_the_menu
    end

    scenario '4. Click Remove Item from the pop-up menu' do
      atg_home_page.remove_item_app_center_dropdown_cart
    end
  end

  context 'Verify the item removed no longer be found in the cart' do
    scenario '1. Hover over the App Center Cart' do
      atg_home_page.hover_app_center_cart
    end

    scenario '2. Verify the item removed no longer be found in the cart' do
      expect(atg_home_page.app_center_cart_dropdown_displays?).to eq(false)
    end
  end
end
