require File.expand_path('../../spec_helper', __FILE__)
require 'atg_app_center_page'

=begin
ATG content: check YMAL information of app on PDP page: title, number of apps in YMAL section
=end

describe "Search SKU and check YMAL information on PDP page - Env: #{Data::ENV_CONST} - Locale: #{Data::LOCALE_CONST.upcase}" do
  next unless app_exist?

  titles_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_SEARCH_TITLE)
  titles_count = titles_list.count

  next unless app_available? titles_count

  tc_num = 0
  atg_app_center_page = AppCenterCatalogATG.new

  titles_list.data_seek(0)
  titles_list.each_hash do |title|
    # Expected value variable
    title_info = nil
    title_sku = title['sku']
    title_prod_number = title['prodnumber']
    title_short_name = title['shortname']
    title_platform = title['platformcompatibility']
    title_ymal = title['ymal']

    # get information of all ymal items
    e_ymal_info = atg_app_center_page.get_ymal_in_database(title_ymal, Data::LOCALE_CONST)
    e_ymal = nil

    # Actual value variable
    a_ymal_info = nil
    a_ymal = nil

    context "#{tc_num += 1}. SKU = '#{title_sku}' - #{title_short_name}" do
      # Checking info on Catalog page
      context 'Search SKU and go to PDP page' do
        it 'Search by SKU' do
          # Loading to search SKU
          atg_app_center_page.load(AppCenterContent::CONST_SEARCH_URL % title_sku)

          # Get product info
          product_html = atg_app_center_page.generate_product_html
          title_info = atg_app_center_page.get_product_info(product_html, title_prod_number)
        end

        # Get actual information
        it 'Go to PDP page' do
          if title_info.nil?
            skip "Title: SKU = '#{title_sku}' is missing"
          else
            atg_app_center_page.go_pdp(title_prod_number)
          end
        end

        it 'Get YMAL information on PDP page' do
          a_ymal_info = atg_app_center_page.get_ymal_info_on_pdp
        end

        it "Verify the number of app in YMAL section = #{e_ymal_info.count}" do
          expect(a_ymal_info.count).to eq(e_ymal_info.count)
        end
      end

      context 'Check YMAL information on PDP page' do
        # Check SKU, title, link, locale,... for all YMAL
        e_ymal_info.each_with_index do |e, index|
          context "#{index + 1} - SKU = '#{e[:sku]}' - Title = '#{e[:title]}'" do
            before :all do
              e_ymal = e_ymal_info.find { |y| y[:prod_number].include?(e[:prod_number]) }
              a_ymal = a_ymal_info.find { |y| y[:prod_number].include?(e[:prod_number]) }
            end

            it 'Verify app displays in YMAL section' do
              skip 'Missing item' if a_ymal.nil?
            end

            it 'Verify app title displays correctly' do
              if a_ymal.nil?
                skip 'Missing item'
              else
                expect(RspecEncode.encode_title(a_ymal[:title])).to eq(RspecEncode.encode_title(e_ymal[:title]))
              end
            end

            it 'Verify link shows correctly' do
              if a_ymal.nil?
                skip 'Missing item'
              else
                expect(a_ymal[:link]).to include(e_ymal[:prod_number])
              end
            end

            it 'Verify app is available for device' do
              if a_ymal.nil?
                skip 'Missing item'
              else
                expect(atg_app_center_page.two_platforms_compare?(title_platform, e_ymal[:platform])).to eq(true)
              end
            end

            it 'Verify app is available in locale' do
              if a_ymal.nil?
                skip 'Missing item'
              else
                expect(atg_app_center_page.support_locale?(e_ymal, Data::LOCALE_CONST)).to eq(true)
              end
            end
          end
        end
      end
    end
  end
end
