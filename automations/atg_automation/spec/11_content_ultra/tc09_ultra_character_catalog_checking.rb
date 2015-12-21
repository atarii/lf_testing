require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_ultra_english_page'

=begin
ATG LeapPad Ultra Content: Fill by Character and check app information on Catalog page
=end

describe "LeapPad Ultra - Character catalog checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?

  ultra_atg_app_center_page = UltraAppCenterCatalogATG.new
  tc_num = 0

  characters_list = Connection.my_sql_connection(UltraAppCenterContent::CONST_ULTRA_QUERY_CHARACTER_CATALOG_DRIVE)
  characters_list.data_seek(0)
  characters_list.each_hash do |character|
    character_name = character['name']
    character_href = character['href']

    # Get all titles that belong to current locale and include character_name
    titles = Connection.my_sql_connection(UltraAppCenterContent::CONST_ULTRA_QUERY_CHARACTER_CATALOG_TITLE % character_name)
    titles_count = titles.count

    context "TC#{tc_num += 1}: Character = '#{character_name}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Character: #{character_name}")

      product_html = {}
      before :all do
        ultra_atg_app_center_page.load(UltraAppCenterContent::CONST_ULTRA_FILTER_URL % character_href)
        product_html = ultra_atg_app_center_page.generate_product_html
      end

      count = 0
      titles.data_seek(0)
      titles.each_hash do |title|
        e_product = ultra_atg_app_center_page.get_expected_product_info_search_page title
        a_product = product_info = {}

        context "#{count += 1}. SKU = #{e_product[:sku]} - #{e_product[:short_name]}" do
          skip_flag = false

          before :each do
            skip ConstMessage::PRE_CONDITION_FAIL if product_info.empty? && skip_flag
          end

          it 'Find and get title information' do
            skip_flag = true
            product_info = ultra_atg_app_center_page.get_product_info(product_html, e_product[:prod_number])

            fail "Title #{e_product[:sku]} is missing" if product_info.empty?

            skip_flag = false
            a_product = ultra_atg_app_center_page.get_actual_product_info_search_page product_info
          end

          it "Verify Content/Type is '#{e_product[:content_type]}'" do
            expect(a_product[:content_type]).to eq(e_product[:content_type])
          end

          it "Verify Long name is '#{e_product[:long_name]}'" do
            expect(a_product[:long_name]).to eq(e_product[:long_name])
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
  end
end
