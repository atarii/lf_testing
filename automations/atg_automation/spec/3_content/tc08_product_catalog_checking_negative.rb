require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_page'

=begin
ATG Content: Verify all apps that do not belong to current locale or current Product shouldn't displayed
=end

describe "Product Catalog Negative - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?
  atg_app_center_page = AppCenterCatalogATG.new
  tc_num = 0

  product_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_PRODUCT_CATALOG_DRIVE)
  product_list.data_seek(0)
  product_list.each_hash do |pr|
    product_name = pr['name']
    product_title = product_name.gsub('LeapFrog Epic', 'Epic')
    product_href = pr['href']
    titles = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_PRODUCT_CATALOG_NEGATIVE_TITLE % product_title)
    titles_count = titles.count

    context "TC#{tc_num += 1}: Product = '#{product_name}' - Total SKUs = #{titles_count}" do
      next unless app_available?(titles_count, "There are no apps available for Product: #{product_name}")

      product_html1 = product_html2 = nil
      before :all do
        atg_app_center_page.load(AppCenterContent::CONST_FILTER_URL % product_href)
        product_html1 = atg_app_center_page.generate_product_html

        atg_app_center_page.load(AppCenterContent::CONST_FILTER_URL2 % product_href)
        product_html2 = atg_app_center_page.generate_product_html
      end

      count = 0
      titles.data_seek(0)
      titles.each_hash do |title|
        e_product = atg_app_center_page.get_expected_product_info_search_page title

        it "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
          a_product = atg_app_center_page.product_not_exist?(product_html1, e_product[:prod_number])
          a_product = atg_app_center_page.product_not_exist?(product_html2, e_product[:prod_number]) if a_product
          a_product = a_product ? 'Not display' : 'Display'

          expect(a_product).to eq('Not display')
        end
      end
    end
  end
end
