require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_cabo_french_page'

=begin
French ATG Cabo Content: Verify all apps that is not belong to Category or Locale or LPAD3 shouldn't displayed
=end

describe "French/CABO - Category negative checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?
  fr_cabo_atg_app_center_page = FrCaboAppCenterCatalogATG.new
  tc_num = 0

  category_list = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_QUERY_CATEGORY_CATALOG_DRIVE)
  category_list.data_seek(0)
  category_list.each_hash do |category|
    category_name = Title.map_french_to_english(category['name'], 'contenttype')
    category_href = category['href']

    # Get all titles that do not belong to the current Locale or Category
    titles = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_FRENCH_QUERY_CATEGORY_CATALOG_NEGATIVE_TITLE % category_name)
    titles_count = titles.count

    context "TC#{tc_num += 1}: Category = '#{category['name']}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Category: #{category_name}")

      product_html = nil
      before :all do
        fr_cabo_atg_app_center_page.load(CaboAppCenterContent::CONST_CABO_FILTER_URL % category_href)
        product_html = fr_cabo_atg_app_center_page.generate_product_html
      end

      count = 0
      titles.data_seek(0)
      titles.each_hash do |title|
        e_product = fr_cabo_atg_app_center_page.get_expected_product_info_search_page title

        it "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
          a_product = fr_cabo_atg_app_center_page.product_not_exist?(product_html, e_product[:prod_number]) ? 'Not display' : 'Display'
          expect(a_product).to eq('Not display')
        end
      end
    end
  end
end
