require File.expand_path('../../spec_helper', __FILE__)

=begin
  Verify user can not checkout successfully with an empty existing account
=end

env = Data::ENV_CONST.upcase
if env != 'PREVIEW' && env != 'PROD'
  require 'atg_home_page'
  require 'atg_app_center_page'
  require 'atg_login_register_page'
  require 'atg_app_center_checkout_page'
  require 'atg_checkout_page'

  HomeATG.set_url URL::ATG_APP_CENTER_URL
  atg_home_page = HomeATG.new
  atg_app_center_page = AppCenterCatalogATG.new
  atg_checkout_page = CheckOutATG.new

  # Account information
  email = Data::EMAIL_EXIST_EMPTY_CONST
  password = Data::PASSWORD_CONST

  feature "DT32: Check out with an empty existing account - ENV = '#{Data::ENV_CONST}' - Locale = '#{Data::LOCALE_CONST}'", js: true do
    check_status_url_and_print_session atg_home_page

    context 'Pre-condition: Delete all items in Cart page' do
      scenario '1. Login to an existing account that has Credit Card' do
        atg_login_page = atg_home_page.goto_login
        atg_login_page.login(email, password)
      end

      scenario '2. Delete all items in Cart page' do
        atg_app_center_page.sg_go_to_check_out
        atg_checkout_page.delete_all_items_in_cart_page
      end

      scenario '3. Log out' do
        atg_checkout_page.logout
      end
    end

    context 'Check out product' do
      scenario '1. Go to App Center home page' do
        atg_home_page.load
        pending("***1. Go to App Center home page #{atg_home_page.current_url}")
      end

      scenario '2. Add a product to cart' do
        prod_info = atg_app_center_page.sg_get_random_product_info
        atg_app_center_page.add_to_cart_from_catalog prod_info[:id]
      end

      scenario '3. Go to App Center check out page' do
        atg_checkout_page = atg_app_center_page.sg_go_to_check_out
        pending("***3. Go to App Center check out page #{atg_checkout_page.current_url}")
      end

      scenario '4. Login to an existing account' do
        atg_checkout_page.sg_login_account_in_checkout_page(email, password)
      end
    end

    context 'Verify user can not check out' do
      scenario "Verify 'No products linked to your account' error displays" do
        expect(atg_checkout_page.checkout_error_txt.text).to include('Whoops! No products linked to your account work with this item. This app works with')
      end

      scenario 'Click on \'Check out\' button' do
        atg_checkout_page.checkout_btn.click
      end

      scenario "Verify 'Checkout Error' pop-up displays" do
        expect(atg_checkout_page.has_check_out_error_popup?).to eq(true)
      end

      scenario 'Go back to Cart page' do
        atg_checkout_page.back_to_cart_lnk.click
      end
    end

    after :all do
      atg_checkout_page.delete_all_items_in_cart_page
    end
  end
else
  feature 'Disable order purchasing in tests for the Preview and Production environments' do
    scenario 'Disable order purchasing for the <b>Preview</b> and <b>Production</b> environments' do
    end
  end
end
