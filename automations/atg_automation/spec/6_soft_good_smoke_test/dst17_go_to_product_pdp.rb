require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_app_center_page'
require 'atg_login_register_page'
require 'atg_product_detail_page'

=begin
  Verify user can add product to cart successfully from Wishlist page
=end

HomeATG.set_url URL::ATG_APP_CENTER_URL
atg_home_page = HomeATG.new
atg_app_center_page = AppCenterCatalogATG.new
atg_product_pdp_page = ProductDetailATG.new
cookie_session_id = nil

# Product info
prod_info = nil

# Account information
email = Data::EMAIL_EXIST_EMPTY_CONST
password = Data::PASSWORD_CONST

feature "DST17 - Catalog - Go to product PDP - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
  before :all do
    cookie_session_id = atg_home_page.load
    atg_login_register_page = atg_home_page.goto_login
    atg_login_register_page.login(email, password)
  end

  context 'Print Session ID' do
    scenario '' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end

  context 'Open product PDP' do
    scenario '1. Go to AppCenter page' do
      atg_home_page.load
      pending "***1. Go to AppCenter page (URL: #{atg_home_page.current_url})"
    end

    scenario '2. Get random product info' do
      prod_info = atg_app_center_page.sg_get_random_product_info
    end

    scenario '3. Open the product PDP page' do
      pdp_page = atg_app_center_page.go_pdp prod_info[:id]
      pending "***3. Open the product PDP page (URL: #{pdp_page.current_url})"
    end

    scenario '4. Verify PDP page displays' do
      expect(atg_product_pdp_page.product_pdp_page_displays?(prod_info[:id])).to eq(true)
    end
  end
end
