require 'pages/atg/atg_app_center_common_page'

# ATG App Center page French
class FrCaboAppCenterCatalogATG < AtgAppCenterCommon
  def get_expected_product_info_search_page(title)
    # Map content type from EN to FR
    content_type_str = Title.map_english_to_french(title['contenttype'], 'contenttype')
    # If ContentType = 'Vidéo éducatif (Vidéo éducatives)' -> Verify content type is one of 'Vidéo éducatif' or 'Vidéo éducative'
    content_type = (content_type_str == 'Vidéo éducatif (Vidéo éducatives)') ? ['Vidéo éducatif', 'Vidéo éducative'] : content_type_str.split(',')

    { sku: title['sku'],
      prod_number: title['prodnumber'],
      short_name: RspecEncode.encode_title(title['shortname']),
      long_name: RspecEncode.encode_title(title['longname']),
      content_type: content_type,
      curriculum: RspecEncode.normalizes_unexpected_characters(Title.map_english_to_french(title['curriculum'], 'curriculum')),
      age: Title.calculate_age_device(title['agefrommonths'], title['agetomonths'], 'Search', 'fr'),
      price: Title.calculate_price(title['prices_total'], AppCenterContent::CONST_PRICE_TIER) }
  end

  def get_expected_product_info_pdp_page(title)
    # Map content type from EN to FR
    content_type_str = Title.map_english_to_french(title['contenttype'], 'contenttype')
    # If ContentType = 'Vidéo éducatif (Vidéo éducatives)' -> Verify content type is one of 'Vidéo éducatif' or 'Vidéo éducative'
    content_type = (content_type_str == 'Vidéo éducatif (Vidéo éducatives)') ? ['Vidéo éducatif', 'Vidéo éducative'] : content_type_str.split(',')

    { sku: title['sku'],
      prod_number: title['prodnumber'].downcase,
      short_name: title['shortname'],
      long_name: RspecEncode.encode_title(title['longname']),
      curriculum: RspecEncode.normalizes_unexpected_characters(Title.map_english_to_french(title['curriculum'], 'curriculum')),
      age: Title.calculate_age_device(title['agefrommonths'], title['agetomonths'], 'PDP', 'fr'),
      price: Title.calculate_price(title['prices_total'], AppCenterContent::CONST_PRICE_TIER),
      legal_top: RspecEncode.process_long_desc(title['legaltop']),
      skill: Title.map_english_to_french(title['skills'], 'skill'),
      has_trailer: title['trailer'] == 'Yes',
      trailer_link: title['trailerlink'],
      add_to_wishlist: true,
      add_to_cart_btn: true,
      description: RspecEncode.process_long_desc(title['lfdesc'].gsub('<br>', '').gsub('<b>', '').gsub('</b>', '')),
      content_type: content_type,
      notable: title['highlights'],
      publisher: Title.convert_french_moas_data(title['publisher']),
      size: Title.calculate_filesize(title['filesizes_total']),
      special_message: RspecEncode.process_long_desc(title['specialmsg']),
      more_info_label: title['moreinfolb'],
      more_info_text: title['moreinfotxt'],
      details: Title.get_details(title['details']).drop(1),
      learning_difference: (title['teaches'] == 'Just for Fun') ? '' : RspecEncode.process_long_desc(title['learningdifference']),
      more_like_this: true,
      legal_bottom: RspecEncode.process_long_desc(title['legalbottom']),

      # If content_type = 'Music' => Credit link is exist => 'True', else => 'False'
      has_credit_link: Title.map_english_to_french(title['contenttype'], 'contenttype') == 'Musique',

      # Only check longname include Credit text
      credits_text: RspecEncode.encode_title(title['longname']),

      # Get teaches list
      # If Skill = 'Just for Fun' (Pour s'amuser) -> Teaches = []
      teaches: (Title.map_english_to_french(title['skills'], 'skill') == "Pour s'amuser") ? [] : Title.map_english_to_french(title['teaches'], 'teaches').split(',') }
  end

  def get_actual_product_info_search_page(product_info)
    { long_name: RspecEncode.encode_title(product_info[:longname]),
      content_type: product_info[:content_type],
      curriculum: RspecEncode.normalizes_unexpected_characters(product_info[:curriculum]),
      href: product_info[:href],
      age: RspecEncode.remove_nbsp(product_info[:age].delete("\n")),
      price: product_info[:price].gsub('\n', '').strip }
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
