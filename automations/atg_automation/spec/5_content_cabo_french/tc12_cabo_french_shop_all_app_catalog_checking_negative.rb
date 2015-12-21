require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_cabo_french_page'

=begin
French ATG Cabo Content: Verify SKUs that are not supported for current locale or LPAD3 platform shouldn't displayed
=end

describe "French/CABO - Shop All App negative checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  context 'Verify titles that are not supported for current locale or LPAD3 device will be not displayed' do
    next unless app_exist?

    titles_list = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_QUERY_SEARCH_NEGATIVE_TITLE)
    titles_count = titles_list.count

    next unless app_available? titles_count

    count = 0
    fr_cabo_atg_app_center_page = FrCaboAppCenterCatalogATG.new
    product_html1 = product_html2 = nil

    before :all do
      fr_cabo_atg_app_center_page.load(CaboAppCenterContent::CONST_CABO_SHOP_ALL_APP_URL1)
      product_html1 = fr_cabo_atg_app_center_page.generate_product_html

      fr_cabo_atg_app_center_page.load(CaboAppCenterContent::CONST_CABO_SHOP_ALL_APP_URL2)
      product_html2 = fr_cabo_atg_app_center_page.generate_product_html
    end

    titles_list.data_seek(0)
    titles_list.each_hash do |title|
      e_product = fr_cabo_atg_app_center_page.get_expected_product_info_search_page title

      it "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
        a_product = fr_cabo_atg_app_center_page.product_not_exist?(product_html1, e_product[:prod_number])
        a_product = fr_cabo_atg_app_center_page.product_not_exist?(product_html2, e_product[:prod_number]) if a_product
        a_product = a_product ? 'Not display' : 'Display'

        expect(a_product).to eq('Not display')
      end
    end
  end
end
