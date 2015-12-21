require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_page'

=begin
ATG LFC Content: Search and check app information on Catalog + PDP page
=end

describe "LFC - Search SKU and check info on Catalog/PDP page - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?

  titles_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_SEARCH_TITLE)
  titles_count = titles_list.count

  next unless app_available? titles_count

  atg_app_center_page = AppCenterCatalogATG.new
  tc_num = 0
  titles_list.data_seek(0)
  titles_list.each_hash do |title|
    e_product_search = atg_app_center_page.get_expected_product_info_search_page title
    e_product_pdp = atg_app_center_page.get_expected_product_info_pdp_page title

    context "#{tc_num += 1}. SKU = '#{e_product_search[:sku]}' - #{e_product_search[:short_name]}" do
      a_product_search = {}
      status_code = ''
      url = ''
      long_name = Title.get_52_first_chars_of_long_title e_product_search[:long_name]

      context 'Search and check information on Search page' do
        product_info = {}
        url = AppCenterContent::CONST_SEARCH_URL % e_product_search[:prod_number]

        before :each do
          skip ConstMessage::PRE_CONDITION_FAIL unless status_code.empty?
        end

        it "Search by Product Number: #{url}" do
          atg_app_center_page.load(url)
          product_html = atg_app_center_page.generate_product_html
          product_info = atg_app_center_page.get_product_info(product_html, e_product_search[:prod_number])

          next unless product_info.empty?

          status_code = LFCommon.get_http_code url
          fail "Could not reach page #{url}, got status #{status_code}"
        end

        it 'Get product information on Search page' do
          a_product_search = atg_app_center_page.get_actual_product_info_search_page product_info
        end

        it "Verify Content Type is '#{e_product_search[:content_type]}'" do
          expect(a_product_search[:content_type]).to eq(e_product_search[:content_type])
        end

        it "Verify Long name is '#{long_name}'" do
          expect(a_product_search[:long_name]).to eq(long_name)
        end

        it "Verify Age is '#{e_product_search[:age]}'" do
          expect(a_product_search[:age]).to eq(e_product_search[:age])
        end

        it "Verify Price is '#{e_product_search[:price]}'" do
          expect(a_product_search[:price]).to eq(e_product_search[:price])
        end
      end

      context 'Product detail page checking' do
        a_product_pdp = {}
        skip_flag = false
        teaches_and_learning = e_product_pdp[:teaches].empty? ? ' does not display' : 'displays correctly'

        before :each do
          skip ConstMessage::PRE_CONDITION_FAIL if a_product_pdp.empty? && skip_flag
        end

        it 'Go to PDP' do
          skip_flag = true
          fail "Could not reach Search page #{url}, got status #{status_code}" unless status_code.empty?

          atg_app_center_page.go_pdp(e_product_pdp[:prod_number])
          pdp_url = AppCenterContent::CONT_PDP_URL % a_product_search[:href]
          status_code_pdp = LFCommon.get_http_code pdp_url

          fail "Could not reach PDP page #{pdp_url}, got status #{status_code_pdp}" unless status_code_pdp == '200'

          skip_flag = false
          pdp_info = atg_app_center_page.get_pdp_info
          a_product_pdp = atg_app_center_page.get_actual_product_info_pdp_page pdp_info

          pending "***Go to PDP #{pdp_url}"
        end

        it 'Verify LF Long Name displays correctly' do
          expect(a_product_pdp[:long_name]).to eq(e_product_pdp[:long_name])
        end

        it "Verify 'Write a review' box displays" do
          if Data::ENV_CONST == 'PROD'
            expect(a_product_pdp[:write_a_review]).to eq(e_product_pdp[:write_a_review])
          else
            pending '*** Skipped "Verify \'Write a review\' box displays" on non-PROD environments'
          end
        end

        it "Verify Age is '#{e_product_pdp[:age]}'" do
          expect(a_product_pdp[:age]).to eq(e_product_pdp[:age])
        end

        it 'Verify LF Description displays correctly' do
          expect(a_product_pdp[:description]).to eq(e_product_pdp[:description])
        end

        it 'Verify one sentence description displays correctly' do
          if a_product_pdp[:description] == e_product_pdp[:description]
            pending '*** Skipped "Verify one sentence description displays correctly" This PDP displays LF Description already'
          else
            expect(a_product_pdp[:description]).to eq(e_product_pdp[:one_sentence])
          end
        end

        it "Verify Content Type is '#{e_product_pdp[:content_type]}'" do
          expect(a_product_pdp[:content_type]).to eq(e_product_pdp[:content_type])
        end

        it "Verify Curriculum is '#{e_product_pdp[:curriculum]}'" do
          expect(a_product_pdp[:curriculum]).to eq(e_product_pdp[:curriculum])
        end

        it "Verify Notable/Highlights is '#{e_product_pdp[:highlights]}'" do
          expect(a_product_pdp[:highlights]).to eq(e_product_pdp[:highlights])
        end

        it "Verify Compatible Platforms (Work With) is '#{e_product_pdp[:work_with]}'" do
          expect(a_product_pdp[:work_with]).to match_array(e_product_pdp[:work_with])
        end

        it "Verify Publisher is '#{e_product_pdp[:publisher]}'" do
          expect(a_product_pdp[:publisher]).to eq(e_product_pdp[:publisher])
        end

        it "Verify File Size is '#{e_product_pdp[:filesize]}'" do
          expect(a_product_pdp[:filesize]).to eq(e_product_pdp[:filesize])
        end

        it 'Verify Special message displays correctly' do
          expect(a_product_pdp[:special_message]).to eq(e_product_pdp[:special_message])
        end

        it 'Verify More Info label displays correctly' do
          expect(a_product_pdp[:moreinfo_lb]).to eq(e_product_pdp[:moreinfo_lb])
        end

        it 'Verify More Info text displays correctly' do
          expect(a_product_pdp[:moreinfo_txt]).to eq(e_product_pdp[:moreinfo_txt])
        end

        it "Verify Credit (Credits) link exists: '#{e_product_pdp[:has_credits_link]}'" do
          expect(a_product_pdp[:has_credits_link]).to eq(e_product_pdp[:has_credits_link])
        end

        if e_product_pdp[:has_credits_link]
          it "Verify Credit link has content: '#{e_product_pdp[:long_name]}'" do
            if Data::ENV_CONST == 'PREVIEW'
              pending "*** Skipped Verify Credit link has content: '#{e_product_pdp[:long_name]}' on PREVIEW env"
            else
              a_credits_app_title = atg_app_center_page.get_credits_text
              expect(a_credits_app_title.downcase).to include(e_product_pdp[:long_name].downcase)
            end
          end
        end

        it 'Verify Legal top displays correctly' do
          expect(a_product_pdp[:legal_top]).to eq(e_product_pdp[:legal_top])
        end

        it "Verify Price is '#{e_product_pdp[:price]}'" do
          skip 'Know issue: There are 2 prices display on PDP page' if a_product_pdp[:price].nil?
          expect(a_product_pdp[:price]).to eq(e_product_pdp[:price])
        end

        it "Verify value of add to cart button is 'Add to Cart'" do
          expect(a_product_pdp[:add_to_cart_btn]).to eq(e_product_pdp[:add_to_cart_btn])
        end

        it "Verify 'Add to Wishlist' link displays" do
          expect(a_product_pdp[:add_to_wishlist]).to eq(e_product_pdp[:add_to_wishlist])
        end

        it "Verify value of buy now button is 'Buy Now ▼'" do
          expect(a_product_pdp[:buy_now_btn]).to eq(e_product_pdp[:buy_now_btn])
        end

        it "Verify Trailer is exist: '#{e_product_pdp[:has_trailer]}'" do
          expect(a_product_pdp[:has_trailer]).to eq(e_product_pdp[:has_trailer])
        end

        if e_product_pdp[:has_trailer]
          it "Verify Trailer link is '#{e_product_pdp[:trailer_link]}'" do
            expect(a_product_pdp[:trailer_link].include?(e_product_pdp[:trailer_link])).to eq(true)
          end
        end

        e_product_pdp[:details].each_with_index do |e_detail, index|
          it "Verify Details #{index + 1} Title/Text displays correctly" do
            expect(a_product_pdp[:details][index]).to eq(e_detail)
          end
        end

        it "Verify Teaches list #{teaches_and_learning}" do
          expect(a_product_pdp[:teaches]).to match_array(e_product_pdp[:teaches])
        end

        it "Verify Learning Difference #{teaches_and_learning}" do
          expect(a_product_pdp[:learning_difference]).to eq(e_product_pdp[:learning_difference])
        end

        it 'Verify Review box displays' do
          expect(a_product_pdp[:review]).to eq(e_product_pdp[:review])
        end

        it 'Verify More Like This box displays' do
          expect(a_product_pdp[:more_like_this]).to eq(e_product_pdp[:more_like_this])
        end

        it 'Verify Legal bottom displays correctly' do
          expect(a_product_pdp[:legal_bottom]).to eq(e_product_pdp[:legal_bottom])
        end
      end
    end
  end
end
