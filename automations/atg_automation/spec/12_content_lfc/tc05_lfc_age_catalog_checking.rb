require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_page'

=begin
ATG LFC Content: Fill by Age and check app information on Catalog page
=end

describe "LFC Age catalog checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?

  atg_app_center_page = AppCenterCatalogATG.new
  tc_num = 0

  age_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_AGE_CATALOG_DRIVE)
  age_list.data_seek(0)
  age_list.each_hash do |ag|
    age_name = ag['name']
    age_number = age_name.gsub('years', '').strip
    age_href = ag['href']
    titles = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_AGE_CATALOG_TITLE % [age_number, age_number])
    titles_count = titles.count

    context "TC#{tc_num += 1}: Age = '#{age_name}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Age: #{age_number}")

      product_html1 = product_html2 = {}
      before :all do
        atg_app_center_page.load(AppCenterContent::CONST_FILTER_URL % age_href)
        product_html1 = atg_app_center_page.generate_product_html

        atg_app_center_page.load(AppCenterContent::CONST_FILTER_URL2 % age_href)
        product_html2 = atg_app_center_page.generate_product_html
      end

      count = 0
      titles.data_seek(0)
      titles.each_hash do |title|
        e_product = atg_app_center_page.get_expected_product_info_search_page title
        a_product = product_info = {}

        context "#{count += 1}. SKU = #{e_product[:sku]} - #{e_product[:short_name]}" do
          skip_flag = false
          long_name = Title.get_52_first_chars_of_long_title e_product[:long_name]

          before :each do
            skip ConstMessage::PRE_CONDITION_FAIL if product_info.empty? && skip_flag
          end

          it 'Find and get title information' do
            skip_flag = true
            product_info = atg_app_center_page.get_product_info(product_html1, e_product[:prod_number])
            product_info = atg_app_center_page.get_product_info(product_html2, e_product[:prod_number]) if product_info.empty?

            fail "Title #{e_product[:sku]} is missing" if product_info.empty?

            skip_flag = false
            a_product = atg_app_center_page.get_actual_product_info_search_page product_info
          end

          it "Verify Long name is '#{long_name}'" do
            expect(a_product[:long_name]).to eq(long_name)
          end

          it "Verify Content type is '#{e_product[:content_type]}'" do
            expect(a_product[:content_type]).to eq(e_product[:content_type])
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
