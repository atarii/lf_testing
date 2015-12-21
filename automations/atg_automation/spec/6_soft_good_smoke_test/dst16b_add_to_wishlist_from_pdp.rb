require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_app_center_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'
require 'atg_product_detail_page'
require 'atg_wishlist_page'

=begin
  Verify user can add product to cart successfully from Wishlist page
=end

HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_app_center_page = AppCenterCatalogATG.new
atg_product_pdp_page = ProductDetailATG.new
atg_wishlist_page = nil
cookie_session_id = nil

# Product info
prod_info = nil
wishlist_info = wishlist_dropdown_info = []
item_num1 = item_num2 = 0

# Account information
email = Data::EMAIL_EXIST_EMPTY_CONST
password = Data::PASSWORD_CONST

feature "DST16B - Catalog - Add to Wishlist from PDP - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  before :all do
    cookie_session_id = atg_home_page.load
    atg_login_register_page = atg_home_page.goto_login
    atg_my_profile_page = atg_login_register_page.login(email, password)
    atg_wishlist_page = atg_my_profile_page.goto_my_wishlist
    atg_wishlist_page.delete_all_wishlist_items
  end

  context 'Print Session ID' do
    scenario '' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end

  context 'Add to Wishlist from PDP' do
    scenario '1. Go to AppCenter page' do
      atg_home_page.load
      pending "***1. Go to AppCenter page (URL: #{atg_home_page.current_url})"
    end

    scenario 'Get the number of added item in Wishlist page' do
      item_num1 = atg_home_page.wishlist_item_number
      pending "***Number of added item in Wishlist: #{item_num1}"
    end

    scenario '2. View the PDP page' do
      prod_info = atg_app_center_page.sg_get_random_product_info
      atg_app_center_page.go_pdp prod_info[:id]
    end

    scenario '3. Verify PDP page displays' do
      expect(atg_product_pdp_page.product_pdp_page_displays?(prod_info[:id])).to eq(true)
    end

    scenario "4. Click on 'Add to Wishlist' link from PDP page" do
      atg_product_pdp_page.sg_add_to_wishlist
    end

    scenario '5. Go to Wishlist page' do
      atg_wishlist_page = atg_home_page.goto_my_wishlist
      pending "***5. Go to Wishlist page (URL: #{atg_wishlist_page.current_url})"
    end

    scenario '6. Verify Wishlist page displays' do
      expect(atg_wishlist_page.wishlist_page_existed?).to eq(true)
    end
  end

  context 'Verify product info on WishList page' do
    scenario '1. Get Quick List information' do
      info = atg_wishlist_page.get_product_info_in_wishlist
      wishlist_info = info.find { |e| e[:prod_id].include?(prod_info[:id]) }
    end

    scenario '2. Verify app is added to Wishlist correct PROD ID' do
      expect(wishlist_info[:prod_id]).to eq(prod_info[:id])
    end

    scenario '3. Verify app is added to Wishlist correct PROD Title' do
      if prod_info[:title].include? '...'
        prod_info[:title] = prod_info[:title].delete('...')
        expect(wishlist_info[:title]).to include(prod_info[:title])
      else
        expect(wishlist_info[:title]).to eq("#{prod_info[:title]}")
      end
    end

    scenario '4. Verify price of item on Wishlist page is correct' do
      if prod_info[:price].nil?
        expect(wishlist_info[:strike]).to eq(prod_info[:strike])
        expect(wishlist_info[:sale]).to eq(prod_info[:sale])
      else
        expect(wishlist_info[:price]).to eq(prod_info[:price])
      end
    end
  end

  context 'Verify product information under Wishlist Dropdown' do
    scenario 'Get the number of added item in Wishlist page' do
      item_num2 = atg_home_page.wishlist_item_number
      pending "***Number of added item in Wishlist: #{item_num2}"
    end

    scenario '1. Verify the number of item in Wishlist next to \'My Wishlist\' link' do
      expect(item_num2).to eq(item_num1 + 1)
    end

    scenario '2. Get product info under Wishlist dropdown' do
      info = atg_home_page.get_item_info_in_wishlist_dropdown
      wishlist_dropdown_info = info.find { |e| e[:prod_id].include?(prod_info[:id]) }
    end

    scenario 'Reporting item information' do
      pending "***Title = #{prod_info[:title]}"
    end

    scenario '3. Verify app displays on Wishlist Dropdown with correct product ID' do
      expect(wishlist_dropdown_info[:prod_id]).to eq(prod_info[:id])
    end

    scenario '4. Verify app displays on Wishlist Drop down with correct Title' do
      if prod_info[:title].include? '...'
        prod_info[:title] = prod_info[:title].delete('...')
        expect(wishlist_dropdown_info[:title]).to include(prod_info[:title])
      else
        expect(wishlist_dropdown_info[:title]).to eq("#{prod_info[:title]}")
      end
    end

    scenario '5. Verify app displays on Wishlist Drop down with correct Price' do
      if prod_info[:price].blank?
        expect(wishlist_dropdown_info[:strike]).to eq(prod_info[:strike])
        expect(wishlist_dropdown_info[:sale]).to eq(prod_info[:sale])
      else
        expect(wishlist_dropdown_info[:price]).to eq(prod_info[:price])
      end
    end
  end

  after :all do
    atg_wishlist_page.delete_all_wishlist_items
  end
end
