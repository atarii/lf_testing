require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_page'

=begin
ATG LFC Content: Fill by Price and check app information on Catalog page
=end

describe "LFC - Price catalog checking - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?

  atg_app_center_page = AppCenterCatalogATG.new
  tc_num = 0

  price_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_PRICE_CATALOG_DRIVE)
  price_list.data_seek(0)
  price_list.each_hash do |pr|
    price_href = pr['href']
    price_name = pr['name']

    # Get price range: $0 - $25 => price_from = 0, price_to = 25
    ar_price = Title.get_price_range(price_name, Data::LOCALE_CONST)
    price_from = ar_price[:price_from]
    price_to = ar_price[:price_to]

    # Get all titles that have price in the range: x <= price < y
    titles = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_PRICE_CATALOG_TITLE % [price_from, price_to])
    titles_count = titles.count

    context "TC#{tc_num += 1}: Price = '#{price_name}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Price: from #{price_from} to #{price_to}")

      product_html = {}
      before :all do
        atg_app_center_page.load(AppCenterContent::CONST_FILTER_URL % price_href)
        product_html = atg_app_center_page.generate_product_html
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
            product_info = atg_app_center_page.get_product_info(product_html, e_product[:prod_number])

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
