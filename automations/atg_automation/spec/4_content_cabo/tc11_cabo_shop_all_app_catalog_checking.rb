require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_cabo_english_page'

=begin
ATG Cabo Content: Fill by Shopp All App and check app information on Catalog page
=end

describe "CABO - Shop All App checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?

  titles_list = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_QUERY_SEARCH_TITLE)
  titles_count = titles_list.count

  next unless app_available? titles_count

  count = 0
  cabo_atg_app_center_page = CaboAppCenterCatalogATG.new
  product_html1 = product_html2 = {}
  before :all do
    cabo_atg_app_center_page.load(CaboAppCenterContent::CONST_CABO_SHOP_ALL_APP_URL1)
    product_html1 = cabo_atg_app_center_page.generate_product_html

    cabo_atg_app_center_page.load(CaboAppCenterContent::CONST_CABO_SHOP_ALL_APP_URL2)
    product_html2 = cabo_atg_app_center_page.generate_product_html
  end

  titles_list.data_seek(0)
  titles_list.each_hash do |title|
    e_product = cabo_atg_app_center_page.get_expected_product_info_search_page title
    a_product = product_info = {}

    context "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
      skip_flag = false

      before :each do
        skip ConstMessage::PRE_CONDITION_FAIL if product_info.empty? && skip_flag
      end

      it 'Find and get title information' do
        skip_flag = true
        product_info = cabo_atg_app_center_page.get_product_info(product_html1, e_product[:prod_number])
        product_info = cabo_atg_app_center_page.get_product_info(product_html2, e_product[:prod_number]) if product_info.empty?

        fail "Title #{e_product[:sku]} is missing" if product_info.empty?

        skip_flag = false
        a_product = cabo_atg_app_center_page.get_actual_product_info_search_page product_info
      end

      it "Verify Content/Type is '#{e_product[:content_type]}'" do
        expect(a_product[:content_type]).to eq(e_product[:content_type])
      end

      it "Verify Long name is '#{e_product[:long_name]}'" do
        expect(a_product[:long_name]).to eq(e_product[:long_name])
      end

      it "Verify Curriculum is '#{e_product[:curriculum]}'" do
        expect(a_product[:curriculum]).to eq(e_product[:curriculum])
      end

      it "Verify Age is '#{e_product[:age]}'" do
        expect(a_product[:age]).to eq(e_product[:age])
      end

      it "Verify Price is '#{e_product[:price]}'" do
        expect(a_product[:price]).to eq(e_product[:price])
      end
    end
  end
end
