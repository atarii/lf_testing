require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_ultra_english_page'

=begin
ATG LeapPad Ultra Content: Verify apps that are not supported for current locale or LPAD3 platform shouldn't displayed
=end

describe "LeapPad Ultra - Shop All App negative checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  context 'Verify titles that are not supported for current locale or LPAD3 device will be not displayed' do
    next unless app_exist?

    titles_list = Connection.my_sql_connection(UltraAppCenterContent::CONST_ULTRA_QUERY_SEARCH_NEGATIVE_TITLE)
    titles_count = titles_list.count

    next unless app_available? titles_count

    ultra_atg_app_center_page = UltraAppCenterCatalogATG.new
    product_html1 = product_html2 = nil
    before :all do
      ultra_atg_app_center_page.load(UltraAppCenterContent::CONST_ULTRA_SHOP_ALL_APP_URL1)
      product_html1 = ultra_atg_app_center_page.generate_product_html

      ultra_atg_app_center_page.load(UltraAppCenterContent::CONST_ULTRA_SHOP_ALL_APP_URL2)
      product_html2 = ultra_atg_app_center_page.generate_product_html
    end

    count = 0
    titles_list.data_seek(0)
    titles_list.each_hash do |title|
      e_product = ultra_atg_app_center_page.get_expected_product_info_search_page title

      it "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
        a_product = ultra_atg_app_center_page.product_not_exist?(product_html1, e_product[:prod_number])
        a_product = ultra_atg_app_center_page.product_not_exist?(product_html2, e_product[:prod_number]) if a_product
        a_product = a_product ? 'Not display' : 'Display'

        expect(a_product).to eq('Not display')
      end
    end
  end
end
