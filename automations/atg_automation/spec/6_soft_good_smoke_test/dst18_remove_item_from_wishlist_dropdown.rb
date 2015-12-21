require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_app_center_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'
require 'atg_product_detail_page'
require 'atg_wishlist_page'

=begin
  Verify user can remove an item from Wishlist Dropdown
=end

HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_app_center_page = AppCenterCatalogATG.new
atg_product_pdp_page = ProductDetailATG.new
atg_wishlist_page = nil
cookie_session_id = nil

# Product info
prod_info = nil
item_num1 = item_num2 = item_num3 = 0

# Account information
email = Data::EMAIL_EXIST_EMPTY_CONST
password = Data::PASSWORD_CONST

feature "DST18 - Wishlist - Remove Item from Wishlist DropDown - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  before :all do
    # Login to LF Account
    cookie_session_id = atg_home_page.load
    atg_login_page = atg_home_page.goto_login
    atg_my_profile_page = atg_login_page.login(email, password)

    # Delete all Wishlist items
    atg_wishlist_page = atg_my_profile_page.goto_my_wishlist
    atg_wishlist_page.delete_all_wishlist_items
  end

  context 'Print Session ID' do
    scenario '' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end

  context 'Add item to Wishlist from PDP' do
    scenario '1. Go to AppCenter page' do
      atg_home_page.load
      pending "***1. Go to AppCenter page (URL: #{atg_home_page.current_url})"
    end

    scenario 'Get the number of added items in Wishlist' do
      item_num1 = atg_home_page.wishlist_item_number
      pending "***Number of added items in Wishlist: #{item_num1}"
    end

    scenario '2. Open the product PDP page' do
      prod_info = atg_app_center_page.sg_get_random_product_info
      pdp_page = atg_app_center_page.go_pdp prod_info[:id]
      pending "***2. Open the product PDP page (URL: #{pdp_page.current_url})"
    end

    scenario '3. Verify PDP page displays' do
      expect(atg_product_pdp_page.product_pdp_page_displays?(prod_info[:id])).to eq(true)
    end

    scenario "4. Click on 'Add to Wishlist' link from PDP page" do
      atg_product_pdp_page.sg_add_to_wishlist
    end
  end

  context 'Verify items is added to Wishlist' do
    scenario '1. Get the number of added item in Wishlist page' do
      item_num2 = atg_home_page.wishlist_item_number
      pending "***Number of added item in Wishlist: #{item_num2}"
    end

    scenario '2. Verify the number of Wishlist items next to \'My Wishlist\' link' do
      expect(item_num2).to eq(item_num1 + 1)
    end
  end

  context 'Remove items from Wishlist Dropdown' do
    scenario '1. Hover over the menu item \'My Wishlist ()\' and click on the \'x\' to remove' do
      atg_home_page.remove_item_from_wishlist_dropdown prod_info[:id]
    end

    scenario 'Get the number of added item in Wishlist page after removing' do
      item_num3 = atg_home_page.wishlist_item_number
      pending "***Number of added item in Wishlist: #{item_num3}"
    end

    scenario '2. Verify the number of Wishlist items next to \'My Wishlist\' link' do
      expect(item_num3).to eq(item_num1)
    end

    scenario '3. Verify the Dropdown from Wishlist header link says your wishlist is empty.' do
      expect(atg_home_page.wishlish_header_text).to eq('Your LeapFrog Wishlist is empty.')
    end
  end

  after :all do
    atg_home_page.goto_my_wishlist
    atg_wishlist_page.delete_all_wishlist_items
  end
end
