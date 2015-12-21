require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_cabo_english_page'

=begin
ATG Cabo Content: Search and check app information on Catalog + PDP page
=end

describe "CABO - Search SKU and check info on Catalog/PDP page - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?

  titles_list = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_QUERY_SEARCH_TITLE)
  titles_count = titles_list.count

  next unless app_available? titles_count

  cabo_atg_app_center_page = CaboAppCenterCatalogATG.new
  tc_num = 0

  titles_list.data_seek(0)
  titles_list.each_hash do |title|
    e_product_search = cabo_atg_app_center_page.get_expected_product_info_search_page title
    e_product_pdp = cabo_atg_app_center_page.get_expected_product_info_pdp_page title

    context "#{tc_num += 1}. SKU = '#{e_product_search[:sku]}' - #{e_product_search[:short_name]}" do
      a_product_search = {}
      status_code = ''
      url = ''

      context 'Search and check information on Search page' do
        product_info = nil
        url = CaboAppCenterContent::CONST_CABO_SEARCH_URL % e_product_search[:prod_number]

        before :each do
          skip ConstMessage::PRE_CONDITION_FAIL unless status_code.empty?
        end

        it "Search by Product Number: #{url}" do
          cabo_atg_app_center_page.load(url)
          product_html = cabo_atg_app_center_page.generate_product_html
          product_info = cabo_atg_app_center_page.get_product_info(product_html, e_product_search[:prod_number])

          next unless product_info.empty?

          status_code = LFCommon.get_http_code url
          fail "Could not reach page #{url}, got status #{status_code}"
        end

        it 'Verify Product info displayed successfully' do
          a_product_search = cabo_atg_app_center_page.get_actual_product_info_search_page product_info
        end

        it "Verify Content/Type is '#{e_product_search[:content_type]}'" do
          expect(a_product_search[:content_type]).to eq(e_product_search[:content_type])
        end

        it "Verify Long name is '#{e_product_search[:long_name]}'" do
          expect(a_product_search[:long_name]).to eq(e_product_search[:long_name])
        end

        it "Verify Curriculum is '#{e_product_search[:curriculum]}'" do
          expect(a_product_search[:curriculum]).to eq(e_product_search[:curriculum])
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

          cabo_atg_app_center_page.go_pdp(e_product_pdp[:prod_number])
          pdp_url = AppCenterContent::CONT_PDP_URL % a_product_search[:href]
          status_code_pdp = LFCommon.get_http_code pdp_url

          fail "Could not reach PDP page #{pdp_url}, got status #{status_code_pdp}" unless status_code_pdp == '200'

          skip_flag = false
          pdp_info = cabo_atg_app_center_page.get_pdp_info
          a_product_pdp = cabo_atg_app_center_page.get_actual_product_info_pdp_page pdp_info

          pending "***Go to PDP #{pdp_url}"
        end

        it "Verify LF Long Name is '#{e_product_pdp[:long_name]}'" do
          expect(a_product_pdp[:long_name_pdp]).to eq(e_product_pdp[:long_name])
        end

        it "Verify Curriculum (top) is '#{e_product_pdp[:curriculum]}'" do
          expect(a_product_pdp[:curriculum_top]).to eq(e_product_pdp[:curriculum])
        end

        it "Verify Age is '#{e_product_pdp[:age]}'" do
          expect(a_product_pdp[:age]).to eq(e_product_pdp[:age])
        end

        it "Verify Trailer exists: '#{e_product_pdp[:has_trailer]}'" do
          expect(a_product_pdp[:has_trailer]).to eq(e_product_pdp[:has_trailer])
        end

        if e_product_pdp[:has_trailer]
          it "Verify Trailer link is: '#{e_product_pdp[:trailer_link]}'" do
            expect(a_product_pdp[:trailer_link]).to include(e_product_pdp[:trailer_link])
          end
        end

        it "Verify Legal top text is '#{e_product_pdp[:legal_top]}'" do
          expect(a_product_pdp[:legal_top]).to eq(e_product_pdp[:legal_top])
        end

        it "Verify Price is '#{e_product_pdp[:price]}'" do
          expect(a_product_pdp[:price]).to eq(e_product_pdp[:price])
        end

        it "Verify 'Add to Cart' button displays" do
          expect(a_product_pdp[:add_to_cart_btn]).to eq(e_product_pdp[:add_to_cart_btn])
        end

        it "Verify 'Add to Wishlist' link displays" do
          expect(a_product_pdp[:add_to_wishlist]).to eq(e_product_pdp[:add_to_wishlist])
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

        it "Verify Notable/Highlights is '#{e_product_pdp[:notable]}'" do
          expect(a_product_pdp[:notable]).to eq(e_product_pdp[:notable])
        end

        it "Verify Curriculum bottom is '#{e_product_pdp[:curriculum]}'" do
          expect(a_product_pdp[:curriculum_bottom]).to eq(e_product_pdp[:curriculum])
        end

        it "Verify Compatible Platforms (Work With) is '#{e_product_pdp[:work_with]}'" do
          expect(a_product_pdp[:work_with]).to match_array(e_product_pdp[:work_with])
        end

        it "Verify Publisher is '#{e_product_pdp[:publisher]}'" do
          expect(a_product_pdp[:publisher]).to eq(e_product_pdp[:publisher])
        end

        it "Verify File Size is '#{e_product_pdp[:size]}'" do
          expect(a_product_pdp[:size]).to eq(e_product_pdp[:size])
        end

        it 'Verify Special message displays correctly' do
          expect(a_product_pdp[:special_message]).to eq(e_product_pdp[:special_message])
        end

        it "Verify 'More info' label displays correctly" do
          expect(a_product_pdp[:more_info_label]).to eq(e_product_pdp[:more_info_label])
        end

        it "Verify 'More info' text displays correctly" do
          expect(a_product_pdp[:more_info_text]).to eq(e_product_pdp[:more_info_text])
        end

        e_product_pdp[:details].each_with_index do |e_detail, index|
          it "Verify Details #{index + 1} Title/Text displays correctly" do
            expect(a_product_pdp[:details][index]).to eq(e_detail)
          end
        end

        it "Verify 'Credits' link exists: '#{e_product_pdp[:has_credit_link]}'" do
          expect(a_product_pdp[:has_credit_link]).to eq(e_product_pdp[:has_credit_link])
        end

        if e_product_pdp[:has_credit_link]
          it "Verify Credit link has content: '#{e_product_pdp[:long_name]}'" do
            if Data::ENV_CONST == 'PREVIEW'
              pending "*** Skipped Verify Credit link has content: '#{e_product_pdp[:long_name]}' on PREVIEW env"
            else
              a_credits_app_title = cabo_atg_app_center_page.get_credits_text
              expect(a_credits_app_title.downcase).to include(e_product_pdp[:long_name].downcase)
            end
          end
        end

        it "Verify Teaches list #{teaches_and_learning}" do
          expect(a_product_pdp[:teaches]).to match_array(e_product_pdp[:teaches])
        end

        it "Verify Learning Difference #{teaches_and_learning}" do
          expect(a_product_pdp[:learning_difference]).to eq(e_product_pdp[:learning_difference])
        end

        it "Verify 'More Like This' box displays" do
          expect(a_product_pdp[:more_like_this]).to eq(e_product_pdp[:more_like_this])
        end

        it "Verify Legal bottom text is '#{e_product_pdp[:legal_bottom]}'" do
          expect(a_product_pdp[:legal_bottom]).to eq(e_product_pdp[:legal_bottom])
        end
      end
    end
  end
end
