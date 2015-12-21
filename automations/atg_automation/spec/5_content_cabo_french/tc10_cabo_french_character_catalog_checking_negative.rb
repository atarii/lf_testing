require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_cabo_french_page'

=begin
French ATG Cabo Content: Verify all titles that do not belong to the Character or Locale or LPAD3 shouldn't displayed
=end

describe "French/CABO - Character negative checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?
  fr_cabo_atg_app_center_page = FrCaboAppCenterCatalogATG.new
  tc_num = 0

  characters_list = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_QUERY_CHARACTER_CATALOG_DRIVE)
  characters_list.data_seek(0)
  characters_list.each_hash do |ch|
    character_name = ch['name']
    character_href = ch['href']

    # Get all titles that do not belong to the Character or Locale
    titles = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_FRENCH_QUERY_CHARACTER_CATALOG_NEGATIVE_TITLE % character_name)
    titles_count = titles.count

    context "TC#{tc_num += 1}: Character = '#{character_name}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Character: #{character_name}")

      product_html = nil
      before :all do
        fr_cabo_atg_app_center_page.load(CaboAppCenterContent::CONST_CABO_FILTER_URL % character_href)
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
