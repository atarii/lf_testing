require File.expand_path('../../spec_helper', __FILE__)

=begin
ATG content: Verify user can search and check out app by using Credit Card
=end

env = Data::ENV_CONST.upcase
if env != 'PREVIEW' && env != 'PROD'
  require 'atg_app_center_page'
  require 'atg_login_register_page'
  require 'pages/atg/atg_app_center_checkout_page'

  atg_app_center_page = AppCenterCatalogATG.new
  atg_checkout_page = AppCenterCheckOutATG.new
  atg_login_page = LoginRegisterATG.new

  describe "Search SKU and Purchase App using credit card checking - Env: #{env} - Locale: #{Data::LOCALE_CONST}" do
    next unless app_exist?

    titles_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_SEARCH_TITLE)
    titles_count = titles_list.count

    next unless app_available? titles_count

    before :all do
      CustomerManagement.clear_account_licenses AppCenterAccount::CREDIT_ACC[0], AppCenterAccount::CREDIT_ACC[1]

      atg_app_center_page.load AppCenterContent::CONST_LOGIN_URL
      atg_login_page.login AppCenterAccount::CREDIT_ACC[0], AppCenterAccount::CREDIT_ACC[1]

      atg_checkout_page.load
      atg_checkout_page.delete_all_checkout
    end

    count = 0
    titles_list.data_seek(0)
    titles_list.each_hash do |title|
      e_product = atg_app_center_page.get_expected_product_info_search_page title
      e_successful_msg = 'Thank you. Your order has been completed.'
      a_product = product_info = {}
      a_successful_msg = ''

      context "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
        context 'Search and check data on Search page' do
          skip_flag = false
          long_name = Title.get_52_first_chars_of_long_title e_product[:long_name]
          url = AppCenterContent::CONST_SEARCH_URL % e_product[:prod_number]

          before :each do
            skip ConstMessage::PRE_CONDITION_FAIL if product_info.empty? && skip_flag
          end

          it "Search by Product Number: #{url}" do
            skip_flag = true
            atg_app_center_page.load(url)
            product_html = atg_app_center_page.generate_product_html
            product_info = atg_app_center_page.get_product_info(product_html, e_product[:prod_number])

            fail "Title #{e_product[:sku]} is missing" if product_info.empty?
            skip_flag = false
          end

          it "Get Product info SKU = '#{e_product[:sku]}' on Search page" do
            a_product = atg_app_center_page.get_actual_product_info_search_page product_info
          end

          it "Verify Content Type is '#{e_product[:content_type]}'" do
            expect(a_product[:content_type]).to eq(e_product[:content_type])
          end

          it "Verify Long name is '#{long_name}'" do
            expect(a_product[:long_name]).to eq(long_name)
          end

          it "Verify Type/Format is '#{e_product[:format]}'" do
            expect(a_product[:format]).to eq(e_product[:format])
          end

          it "Verify Price is '#{e_product[:price]}'" do
            expect(a_product[:price]).to eq(e_product[:price])
          end

          it 'Add Product to Cart' do
            atg_checkout_page = atg_app_center_page.add_sku_to_cart
          end

          it 'Verify Product is added to Cart successfully' do
            expect(atg_checkout_page.sku_added_to_cart?(e_product[:sku])).to eq(true)
          end
        end

        context "Purchase using credit card to user '#{AppCenterAccount::CREDIT_ACC[0]}'" do
          it 'Check out process' do
            skip ConstMessage::PRE_CONDITION_FAIL if product_info.empty?
            a_successful_msg = atg_checkout_page.checkout_with_credit_card
          end

          it 'Verify sku has been purchased successfully' do
            skip ConstMessage::PRE_CONDITION_FAIL if product_info.empty?
            expect(a_successful_msg).to eq(e_successful_msg)
          end
        end

        after :all do
          atg_checkout_page.load
          atg_checkout_page.delete_all_checkout
        end
      end
    end
  end
else
  feature 'Disable order purchasing in tests for the Preview and Production environments' do
    scenario 'Disable order purchasing for the <b>Preview</b> and <b>Production</b> environments' do
    end
  end
end
