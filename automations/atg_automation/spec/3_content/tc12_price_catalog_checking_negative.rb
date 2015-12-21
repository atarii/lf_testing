require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_page'

=begin
ATG Content: Verify all apps that have difference price or not belong to current Locale shouldn't displayed
=end

describe "Price Catalog Negative - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?
  atg_app_center_page = AppCenterCatalogATG.new
  tc_num = 0

  price_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_PRICE_CATALOG_DRIVE)
  price_list.data_seek(0)
  price_list.each_hash do |pr|
    price_name = pr['name']
    price_href = pr['href']

    # Get price range: $0 - $25 => price_from = 0, price_to = 25
    ar_price = Title.get_price_range(price_name, Data::LOCALE_CONST)
    price_from = ar_price[:price_from]
    price_to = ar_price[:price_to]

    titles = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_PRICE_CATALOG_NEGATIVE_TITLE % [price_from, price_to])
    titles_count = titles.count

    context "TC#{tc_num += 1}: Price = '#{price_name}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Price: from #{price_from} to #{price_to}")

      product_html, product_html2 = nil, nil
      before :all do
        atg_app_center_page.load(AppCenterContent::CONST_FILTER_URL % price_href)
        product_html = atg_app_center_page.generate_product_html

        atg_app_center_page.load(AppCenterContent::CONST_FILTER_URL2 % price_href)
        product_html2 = atg_app_center_page.generate_product_html
      end

      count = 0
      titles.data_seek(0)
      titles.each_hash do |title|
        e_product = atg_app_center_page.get_expected_product_info_search_page title

        it "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
          a_product = atg_app_center_page.product_not_exist?(product_html, e_product[:prod_number])
          a_product = atg_app_center_page.product_not_exist?(product_html2, e_product[:prod_number]) if a_product
          a_product = a_product ? 'Not display' : 'Display'
          expect(a_product).to eq('Not display')
        end
      end
    end
  end
end
