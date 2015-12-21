require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_page'

=begin
ATG LFC Content: Open Quick View overlay and check app information
=end

describe "LFC - Check information on Quick View page - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?

  atg_app_center_page = AppCenterCatalogATG.new
  titles_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_SEARCH_TITLE)
  titles_count = titles_list.count

  next unless app_available? titles_count

  count = 0
  titles_list.data_seek(0)
  titles_list.each_hash do |title|
    e_product = atg_app_center_page.get_expected_product_info_quick_view title
    a_product = product_info = {}

    context "#{count += 1}. SKU = '#{e_product[:sku]}' - #{e_product[:short_name]}" do
      skip_flag = false
      url = AppCenterContent::CONST_QUICK_VIEW_SEARCH_URL % e_product[:prod_number]

      before :each do
        skip ConstMessage::PRE_CONDITION_FAIL if product_info.empty? && skip_flag
      end

      it "Search by Product Number: #{url}" do
        skip_flag = true
        atg_app_center_page.load(url)
        product_html = atg_app_center_page.generate_product_html
        product_info = atg_app_center_page.get_product_info(product_html, e_product[:prod_number])

        fail "Title #{e_product[:sku]} is missing" if product_info.empty?
        skip_flag = false
      end

      it "Open Quick View dialog and get information if '#{e_product[:sku]}' is existed" do
        a_quick_view_info = atg_app_center_page.get_quick_view_info(e_product[:prod_number])
        a_product = atg_app_center_page.get_actual_product_info_quick_view a_quick_view_info
      end

      it "Verify 'Long Name' is '#{e_product[:long_name]}'" do
        expect(a_product[:long_name]).to eq(e_product[:long_name])
      end

      it "Verify 'Ages' is '#{e_product[:age]}'" do
        expect(a_product[:age]).to eq(e_product[:age])
      end

      it "Verify Description is '#{e_product[:description]}'" do
        expect(a_product[:description]).to eq(e_product[:description])
      end

      it "Verify One Sentence description is '#{e_product[:one_sentence]}'" do
        if a_product[:description] == e_product[:description]
          pending '*** Skipped "Verify one sentence description displays correctly" This PDP displays LF Description already'
        else
          expect(a_product[:description]).to eq(e_product[:one_sentence])
        end
      end

      it "Verify 'Teaches' is '#{e_product[:teaches]}'" do
        expect(a_product[:teaches]).to eq(e_product[:teaches])
      end

      it "Verify 'Works With' is '#{e_product[:workswith]}'" do
        expect(a_product[:workswith]).to match_array(e_product[:workswith])
      end

      it "Verify 'See Details' link is '#{e_product[:see_detail_link]}'" do
        expect(a_product[:see_detail_link]).to eq(e_product[:see_detail_link])
      end

      it "Verify 'Price' is '#{e_product[:price]}'" do
        expect(a_product[:price]).to eq(e_product[:price])
      end

      it "Verify value of 'Add to cart' button is '#{e_product[:add_to_cart]}'" do
        expect(a_product[:add_to_cart]).to eq(e_product[:add_to_cart])
      end

      it "Verify value of 'Add to wishlist' is '#{e_product[:add_to_wishlist]}'" do
        expect(a_product[:add_to_wishlist]).to eq(e_product[:add_to_wishlist])
      end

      it "Verify size of small icon is '#{e_product[:small_icon_size]}'" do
        expect(a_product[:small_icon_size]).to eq(e_product[:small_icon_size])
      end

      it "Verify size of large icon is '#{e_product[:large_icon_size]}'" do
        expect(a_product[:large_icon_size]).to eq(e_product[:large_icon_size])
      end
    end
  end
end
