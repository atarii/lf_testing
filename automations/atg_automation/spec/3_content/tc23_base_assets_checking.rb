require File.expand_path('../../spec_helper', __FILE__)

=begin
ATG content: Base asset name checking
=end

describe 'Base Asset name checking' do
  next unless app_exist?
  titles = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_SEARCH_TITLE)
  next unless app_available? titles.count

  tc_num = 0
  titles.data_seek 0
  titles.each_hash do |title|
    context "#{tc_num += 1}. SKU = '#{title['sku']}' - #{title['shortname']}" do
      asset_endpoints = LFCommon.generate_asset_endpoints title
      asset_endpoints.each do |name, url|
        context "Check #{name} link #{url}" do
          if name.to_s == 'video' || name.to_s.start_with?('carousel_image')
            skip 'BLOCKED: Verify manully - cannot be verified by script'
          else
            code = nil
            content_length = nil
            content_type = nil

            before :all do
              code = LFCommon.get_http_code(url)
              content_length = LFCommon.get_content_length(url)
              content_type = LFCommon.get_content_type(url)
            end

            it 'Has valid URL' do
              expect(code).to eq('200')
            end

            it 'File size is not empty' do
              expect(content_length).to be > 0
            end

            it 'File size is not the 404 placeholder image file size' do
              expect(content_length).to_not eq(7632)
            end

            if (content_length == 7632) && (content_type.include? 'image')
              it 'Verify image is not friendly 404 image (size: 7632 Bytes, type image)' do
                skip 'Pending by this image not available'
              end
            end
          end
        end
      end
    end
  end
end
