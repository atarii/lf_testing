require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_page'

=begin
ATG LFC Content: Verify all apps that are not supported for current locale shouldn't displayed
=end

describe "LFC - SKU Searching negative - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  context "Verify SKUs that do not support for current locale will not display: #{AppCenterContent::CONST_SEARCH_URL}" do
    next unless app_exist?

    titles_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_SEARCH_NEGATIVE_TITLE)
    titles_count = titles_list.count

    next unless app_available? titles_count

    atg_app_center_page = AppCenterCatalogATG.new
    count = 0
    titles_list.data_seek(0)
    titles_list.each_hash do |title|
      e_product = atg_app_center_page.get_expected_product_info_search_page title
      a_product = nil

      before :all do
        atg_app_center_page.load(AppCenterContent::CONST_SEARCH_URL % e_product[:prod_number])
        product_html = atg_app_center_page.generate_product_html
        a_product = atg_app_center_page.product_not_exist?(product_html, e_product[:prod_number]) ? 'Not display' : 'Display'
      end

      it "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
        expect(a_product).to eq('Not display')
      end
    end
  end
end
