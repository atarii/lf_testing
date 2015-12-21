require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_app_center_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'
require 'atg_wishlist_page'
require 'atg_quick_view_overlay_page'
require 'mail_home_page'
require 'mail_detail_page'

=begin
  Verify Email Wishlist feature works correctly
=end

HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_app_center_page = AppCenterCatalogATG.new
atg_quick_view_overlay_page = QuickViewOverlayATG.new
atg_wishlist_page = nil
mail_home_page = HomePageMail.new
mail_detail_page = nil
cookie_session_id = nil

# Product info
prod_info_1 = prod_info_2 = nil
item_num1 = item_num2 = 0
wishlist_info = []
wishlist1 = wishlist2 = nil

# Account information
email = Data::EMAIL_EXIST_EMPTY_CONST
password = Data::PASSWORD_CONST
receive_email = Generate.email('atg', Data::ENV_CONST.downcase, Data::LOCALE_CONST.downcase)
note = 'LF Automation: Share this Wishlist'

feature "DST21 - Wishlist - Share item from Wishlist - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
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

  context 'Add 2 items into Wishlist' do
    scenario '1. Go to AppCenter page' do
      atg_home_page.load
      pending "***1. Go to AppCenter page (URL: #{atg_home_page.current_url})"
    end

    scenario 'Get the number of added item in Wishlist page' do
      item_num1 = atg_home_page.wishlist_item_number
      pending "***Number of added item in Wishlist: #{item_num1}"
    end

    scenario '1. Add 1st item into Wishlist' do
      prod_info_1 = atg_app_center_page.sg_get_random_product_info
      atg_home_page.quick_view_product_by_prodnumber prod_info_1[:id]
      atg_quick_view_overlay_page.sg_add_to_wishlist

      pending "***1. Add the 1st item into Wishlist: PROD_ID = '#{prod_info_1[:id]}'"
    end

    scenario '2. Add 2nd item into Wishlist' do
      prod_info_2 = atg_app_center_page.sg_get_random_product_info prod_info_1[:id]
      atg_home_page.quick_view_product_by_prodnumber prod_info_2[:id]
      atg_quick_view_overlay_page.sg_add_to_wishlist

      pending "***2. Add the 2nd item into Wishlist: PROD_ID = '#{prod_info_2[:id]}'"
    end

    scenario 'Get the number of added item in Wishlist page' do
      item_num2 = atg_home_page.wishlist_item_number
      pending "***Number of added item in Wishlist: #{item_num2}"
    end

    scenario '3. Verify the number of item in Wishlist next to \'My Wishlist\' link is 2' do
      expect(item_num2).to eq(item_num1 + 2)
    end
  end

  context 'Go to Wishlist page and Share all wishlist items' do
    scenario '1. Go to Wishlist page' do
      atg_wishlist_page = atg_home_page.goto_my_wishlist
      pending "***1. Go to Wishlist page (URL: #{atg_wishlist_page.current_url})"
    end

    scenario '2. Verify Wishlist page displays' do
      expect(atg_wishlist_page.wishlist_page_existed?).to eq(true)
    end

    scenario '3. Click the the \'Email Link\' link next to the 1st item' do
      atg_wishlist_page.click_email_wishlist_link
    end

    scenario '4. Verify \'Email Your Wishlist\' pop-up displays' do
      expect(atg_wishlist_page.email_your_wishlist_popup_displays?).to eq(true)
    end

    scenario '5. Enter Email/Note and click on \'Share this Wishlist\' button' do
      atg_wishlist_page.share_wishlist(receive_email, note)
    end
  end

  context 'Check Share this Wishlish Email' do
    scenario "1. Go to \'Guerrillamail\' mail box - Email = '#{receive_email}'" do
      mail_detail_page = mail_home_page.go_to_mail_detail(receive_email, 3)
    end

    scenario '2. Get all shared Wishlist item from Email' do
      wishlist_info = mail_detail_page.get_shared_wishlist_info
      wishlist1 = wishlist_info.find { |e| e[:prod_id].include?(prod_info_1[:id]) }
      wishlist2 = wishlist_info.find { |e| e[:prod_id].include?(prod_info_2[:id]) }
    end

    scenario '3. Verify 1st item displays in Email with correct Product ID' do
      expect(wishlist1[:prod_id]).to eq(prod_info_1[:id])
    end

    scenario '4. Verify 1st item displays in Email with correct Title' do
      if prod_info_1[:title].include? '...'
        prod_info_1[:title] = prod_info_1[:title].delete('...')
        expect(wishlist1[:title]).to include(prod_info_1[:title])
      else
        expect(wishlist1[:title]).to eq(prod_info_1[:title])
      end
    end

    scenario '5. Verify 2nd item doesn\'t display in Email' do
      expect(wishlist2.nil?).to eq(true)
    end
  end

  after :all do
    # Login to LF Account
    atg_home_page.load
    atg_home_page.goto_my_wishlist
    atg_wishlist_page.delete_all_wishlist_items
  end
end
