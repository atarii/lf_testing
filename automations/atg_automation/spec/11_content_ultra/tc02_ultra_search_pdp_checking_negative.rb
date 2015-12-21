require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_ultra_english_page'

=begin
ATG LeapPad Ultra Content: Verify apps that are not supported for current locale or LPAD3 platform shouldn't displayed
=end

describe "LeapPad Ultra - Searching negative checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  context "Verify SKUs that are not supported for current locale or LeapPad Ultra platform will be not displayed: #{UltraAppCenterContent::CONST_ULTRA_SEARCH_URL}" do
    next unless app_exist?

    titles_list = Connection.my_sql_connection(UltraAppCenterContent::CONST_ULTRA_QUERY_SEARCH_NEGATIVE_TITLE)
    titles_count = titles_list.count

    next unless app_available? titles_count

    ultra_atg_app_center_page = UltraAppCenterCatalogATG.new
    count = 0

    titles_list.data_seek(0)
    titles_list.each_hash do |title|
      e_product = ultra_atg_app_center_page.get_expected_product_info_search_page title
      a_product = nil

      before :all do
        ultra_atg_app_center_page.load(UltraAppCenterContent::CONST_ULTRA_SEARCH_URL % e_product[:prod_number])
        product_html = ultra_atg_app_center_page.generate_product_html
        a_product = ultra_atg_app_center_page.product_not_exist?(product_html, e_product[:prod_number]) ? 'Not display' : 'Display'
      end

      it "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
        expect(a_product).to eq('Not display')
      end
    end
  end
end
