require 'pages/atg/atg_app_center_common_page'

class CaboAppCenterCatalogATG < AtgAppCenterCommon
  def get_expected_product_info_search_page(title)
    { sku: title['sku'],
      prod_number: title['prodnumber'],
      short_name: RspecEncode.encode_title(title['shortname']),
      long_name: RspecEncode.encode_title(title['longname']),
      content_type: Title.map_content_type(title['contenttype']),
      curriculum: RspecEncode.normalizes_unexpected_characters(title['curriculum']),
      age: Title.calculate_age_device(title['agefrommonths'], title['agetomonths'], 'Search'),
      price: Title.calculate_price(title['prices_total'], AppCenterContent::CONST_PRICE_TIER) }
  end

  def get_expected_product_info_pdp_page(title)
    { sku: title['sku'],
      prod_number: title['prodnumber'],
      short_name: title['shortname'],
      long_name: RspecEncode.encode_title(title['longname']),
      age: Title.calculate_age_device(title['agefrommonths'], title['agetomonths']),
      price: Title.calculate_price(title['prices_total'], AppCenterContent::CONST_PRICE_TIER),
      legal_top: RspecEncode.process_long_desc(title['legaltop']),
      skill: title['skills'],
      has_trailer: title['trailer'] == 'Yes',
      trailer_link: title['trailerlink'],
      add_to_wishlist: true,
      add_to_cart_btn: true,
      description: RspecEncode.process_long_desc(title['lfdesc']),
      one_sentence: RspecEncode.process_long_desc(title['onesentence']),
      content_type: Title.map_content_type(title['contenttype']),
      notable: title['highlights'],
      curriculum: RspecEncode.normalizes_unexpected_characters(title['curriculum']),
      work_with: Title.replace_epic_platform(title['platformcompatibility'].split(',')),
      publisher: title['publisher'],
      size: Title.calculate_filesize(title['filesizes_total']),
      special_message: RspecEncode.process_long_desc(title['specialmsg']),
      more_info_label: title['moreinfolb'],
      more_info_text: title['moreinfotxt'],
      details: Title.get_details(title['details']).drop(1),
      learning_difference: (title['teaches'] == 'Just for Fun') ? '' : RspecEncode.process_long_desc(title['learningdifference']),
      more_like_this: true,
      legal_bottom: RspecEncode.process_long_desc(title['legalbottom']),
      has_credit_link: Title.map_content_type(title['contenttype']) == 'Music',

      # Only check longname include Credit text
      credit_text: RspecEncode.encode_title(title['longname']),

      # Get teaches list
      teaches: (title['skills'] == 'Just for Fun') ? [] : Title.teach_info(title['teaches']) }
  end

  def get_actual_product_info_search_page(product_info)
    { long_name: RspecEncode.encode_title(product_info[:longname]),
      curriculum: RspecEncode.normalizes_unexpected_characters(product_info[:curriculum]),
      href: product_info[:href],
      price: product_info[:price].gsub('\n', '').strip,
      age: RspecEncode.remove_nbsp(product_info[:age].delete("\n")),
      content_type: product_info[:content_type] }
  end

  def get_actual_product_info_pdp_page(pdp_info)
    { long_name_pdp: RspecEncode.encode_title(pdp_info[:long_name]),
      curriculum_top: RspecEncode.normalizes_unexpected_characters(pdp_info[:curriculum_top]),
      age: pdp_info[:age],
      price: pdp_info[:price],
      legal_top: RspecEncode.process_long_desc(pdp_info[:legal_top]),
      legal_bottom: RspecEncode.process_long_desc(pdp_info[:legal_bottom]),
      add_to_wishlist: pdp_info[:add_to_wishlist],
      add_to_cart_btn: pdp_info[:add_to_cart_btn],
      description: RspecEncode.process_long_desc(pdp_info[:description]),
      content_type: pdp_info[:content_type],
      notable: pdp_info[:notable],
      curriculum_bottom: RspecEncode.normalizes_unexpected_characters(pdp_info[:curriculum_bottom]),
      work_with: pdp_info[:work_with].split(','),
      publisher: pdp_info[:publisher],
      size: pdp_info[:size],
      special_message: RspecEncode.process_long_desc(pdp_info[:special_message]),
      more_info_label: pdp_info[:more_info_label],
      more_info_text: pdp_info[:more_info_text],
      details: pdp_info[:details],
      teaches: pdp_info[:teaches],
      learning_difference: RspecEncode.process_long_desc(pdp_info[:learning_difference]),
      more_like_this: pdp_info[:more_like_this],

      # Get Credit link and Credit text
      has_credit_link: pdp_info[:has_credit_link],

      # Get Trailer link
      has_trailer: pdp_info[:has_trailer],
      trailer_link: pdp_info[:trailer_link][0] }
  end
end
