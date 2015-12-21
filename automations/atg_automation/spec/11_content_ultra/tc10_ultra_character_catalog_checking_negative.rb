require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_ultra_english_page'

=begin
ATG LeapPad Ultra Content: Verify all apps that do not belong to the Character or Locale or LPAD3 shouldn't displayed
=end

describe "LeapPad Ultra - Character negative checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?
  ultra_atg_app_center_page = UltraAppCenterCatalogATG.new
  tc_num = 0

  characters_list = Connection.my_sql_connection(UltraAppCenterContent::CONST_ULTRA_QUERY_CHARACTER_CATALOG_DRIVE)
  characters_list.data_seek(0)
  characters_list.each_hash do |ch|
    character_name = ch['name']
    character_href = ch['href']

    # Get all titles that do not belong to the Character or Locale
    titles = Connection.my_sql_connection(UltraAppCenterContent::CONST_ULTRA_QUERY_CHARACTER_CATALOG_NEGATIVE_TITLE % character_name)
    titles_count = titles.count

    context "TC#{tc_num += 1}: Character = '#{character_name}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Character: #{character_name}")

      product_html = nil
      before :all do
        ultra_atg_app_center_page.load(UltraAppCenterContent::CONST_ULTRA_FILTER_URL % character_href)
        product_html = ultra_atg_app_center_page.generate_product_html
      end

      count = 0
      titles.data_seek(0)
      titles.each_hash do |title|
        e_product = ultra_atg_app_center_page.get_expected_product_info_search_page title

        it "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
          a_product = ultra_atg_app_center_page.product_not_exist?(product_html, e_product[:prod_number]) ? 'Not display' : 'Display'
          expect(a_product).to eq('Not display')
        end
      end
    end
  end
end
