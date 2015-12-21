require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_cabo_english_page'

=begin
ATG Cabo Content: Verify all apps that do not belong to current locale or Age range or LPAD3 shouldn't displayed
=end

describe "CABO - Age negative checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?
  cabo_atg_app_center_page = CaboAppCenterCatalogATG.new
  tc_num = 0

  age_list = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_QUERY_AGE_CATALOG_DRIVE)
  age_list.data_seek(0)
  age_list.each_hash do |age|
    age_name = age['name']
    age_href = age['href']

    age_number = age_name.gsub('years', '').strip
    age_number = age_name.gsub('+ years', '').strip if (age_name == '7+ years')

    # Get all products that do not belong to current locale or current Age
    titles = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_QUERY_AGE_CATALOG_NEGATIVE_TITLE % [age_number, age_number])
    titles_count = titles.count

    context "TC#{tc_num += 1}: Age = '#{age_name}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Age: #{age_name}")

      product_html = nil
      before :all do
        cabo_atg_app_center_page.load(CaboAppCenterContent::CONST_CABO_FILTER_URL % age_href)
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
