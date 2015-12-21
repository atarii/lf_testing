require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_app_center_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'
require 'atg_product_detail_page'
require 'atg_wishlist_page'
require 'atg_checkout_page'

=begin
  Verify user can move Item from Drop Down Cart to Wishlist
=end

HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_app_center_page = AppCenterCatalogATG.new
atg_checkout_page = CheckOutATG.new
atg_my_profile_page = nil
atg_wishlist_page = nil
cookie_session_id = nil

# Product info
item_num1 = item_num2 = item_num3 = wishlist_number1 = wishlist_number2 = 0

# Account information
email = Data::EMAIL_EXIST_EMPTY_CONST
password = Data::PASSWORD_CONST

feature "DST29 - Cart - Move Item from Drop Down Cart to Wishlist - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  before :all do
    # Login to LF Account
    cookie_session_id = atg_home_page.load
    atg_login_page = atg_home_page.goto_login
    atg_my_profile_page = atg_login_page.login(email, password)

    # Delete all items in Wishlist page
    atg_wishlist_page = atg_my_profile_page.goto_my_wishlist
    atg_wishlist_page.delete_all_wishlist_items

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
      wishlist_number1 = atg_home_page.wishlist_item_number
      item_num2 = atg_home_page.cart_item_number
      pending "***Number of added item in Cart: #{item_num2}"
    end

    scenario '2. Verify the number of Cart items next to \'My Cart\' link' do
      expect(item_num2).to eq(item_num1 + 1)
    end
  end

  context 'Hover over the App Center Cart and click \'Add to Wishlist\' from the pop-up menu' do
    scenario '1. Hover over the App Center Cart' do
      atg_home_page.hover_app_center_cart
    end

    scenario '2. Verify the remove from cart pop-up displays' do
      expect(atg_home_page.app_center_cart_dropdown_displays?).to eq(true)
    end

    scenario "3. Hover over the 'x' in the menu" do
      atg_home_page.hover_the_x_in_the_menu
    end

    scenario "4. Click 'Add to Wishlist' from the pop-up menu" do
      atg_home_page.add_to_wishlist_from_app_center_dropdown_cart
    end
  end

  context 'Verify the app is removed from Cart page' do
    scenario '1. Verify Item Moved to Wishlist should not be found on the App Center Cart page' do
      expect(atg_checkout_page.added_items_box?).to eq(false)
    end

    scenario '2. Hover over the \'App Center Cart\' menu' do
      atg_home_page.hover_app_center_cart
    end

    scenario '3. Verify Item Moved to Wishlist should not be found in the App Center Cart dropdown' do
      expect(atg_home_page.app_center_cart_dropdown_displays?).to eq(false)
    end
  end

  context 'Verify information display correctly on Wishlist page' do
    scenario '1. Verify The My Wishlist menu item in the header should increment by one' do
      wishlist_number2 = atg_home_page.wishlist_item_number
      expect(wishlist_number2).to eq(wishlist_number1 + 1)
    end

    scenario '2. Verify The App Center cart menu item in the header should decrement by one' do
      item_num3 = atg_home_page.cart_item_number
      expect(item_num3).to eq(item_num2 - 1)
    end

    scenario '3. Verify The item that was in the cart should now be in the Wishlist dropdown' do
      atg_home_page.hover_my_wishlist
      expect(atg_home_page.has_css?('.product-title.ng-binding')).to eq(true)
    end

    scenario '4. Go to My Wishlist page' do
      atg_wishlist_page = atg_home_page.goto_my_wishlist
    end

    scenario '5. Verify The item that was in the cart should now be found on the Wishlist page' do
      expect(atg_wishlist_page.wishlist_items_box?).to eq(true)
    end
  end
end
