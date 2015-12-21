require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_cabo_english_page'

=begin
ATG Cabo Content: Verify all apps that is not belong to Category or Locale or LPAD3 shouldn't displayed
=end

describe "CABO - Category negative checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?
  cabo_atg_app_center_page = CaboAppCenterCatalogATG.new
  tc_num = 0

  category_list = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_QUERY_CATEGORY_CATALOG_DRIVE)
  category_list.data_seek(0)
  category_list.each_hash do |category|
    category_name = category['name']
    category_href = category['href']

    # Get all titles that do not belong to the current Locale or Category
    titles = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_QUERY_CATEGORY_CATALOG_NEGATIVE_TITLE % [category_name, Title.map_content_type(category_name, 's2m')])
    titles_count = titles.count

    context "TC#{tc_num += 1}: Category = '#{category_name}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Category: #{category_name}")

      product_html = nil
      before :all do
        cabo_atg_app_center_page.load(CaboAppCenterContent::CONST_CABO_FILTER_URL % category_href)
        product_html = cabo_atg_app_center_page.generate_product_html
      end

      count = 0
      titles.data_seek(0)
      titles.each_hash do |title|
        e_product = cabo_atg_app_center_page.get_expected_product_info_search_page title

        it "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
          a_product = cabo_atg_app_center_page.product_not_exist?(product_html, e_product[:prod_number]) ? 'Not display' : 'Display'
          expect(a_product).to eq('Not display')
        end
      end
    end
  end
end
