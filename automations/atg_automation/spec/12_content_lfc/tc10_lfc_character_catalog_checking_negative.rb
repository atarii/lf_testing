require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_page'

=begin
ATG LFC - Verify all apps that do not belong to the current Locale or Character shouldn't displayed
=end

describe "LFC - Character Catalog Negative - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?
  atg_app_center_page = AppCenterCatalogATG.new
  tc_num = 0

  character_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_CHARACTER_CATALOG_DRIVE)
  character_list.data_seek(0)
  character_list.each_hash do |ch|
    character_name = ch['name']
    character_href = ch['href']
    titles = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_CHARACTER_CATALOG_NEGATIVE_TITLE % character_name)
    titles_count = titles.count

    context "TC#{tc_num += 1}: Character = '#{character_name}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Character: #{character_name}")

      product_html = nil
      before :all do
        atg_app_center_page.load(AppCenterContent::CONST_FILTER_URL % character_href)
        product_html = atg_app_center_page.generate_product_html
      end

      count = 0
      titles.data_seek(0)
      titles.each_hash do |title|
        e_product = atg_app_center_page.get_expected_product_info_search_page title

        it "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
          a_product = atg_app_center_page.product_not_exist?(product_html, e_product[:prod_number]) ? 'Not display' : 'Display'
          expect(a_product).to eq('Not display')
        end
      end
    end
  end
end
