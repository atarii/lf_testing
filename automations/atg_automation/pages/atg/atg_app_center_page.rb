require 'pages/atg/atg_common_page'
require 'pages/atg/atg_app_center_checkout_page'

class NavAccountMenu < SitePrism::Section
  element :login_register_link, '#headerLogin'
  element :appcenter_cart_link, '.nav-account__mini-cart-softgoods-link'
  element :logout_link, '#atg_logoutBtn'
  element :login_link, '#atg_loginBtn'
  element :checkout_btn, '#miniCartCheckoutBtn'
  element :app_center_item_number, :xpath, ".//*[@id='navAccount']//a[@class='nav-account__mini-cart-softgoods-link']/span"
end

class AppCenterCatalogATG < CommonATG
  set_url URL::ATG_CONST
  attr_reader :catalog_div_css

  def initialize
    @catalog_div_css = '.resultList .product-row'
  end

  section :nav_account_menu, NavAccountMenu, '.navbar-inner'
  elements :product_list_div, :xpath, "//div[@class='resultList']//div[@class='catalog-product blk blk-l' or @class='catalog-product']/div"
  element :product_detail_div, '#productDetails'
  elements :attributes_div, 'div.attributes>p'
  element :add_to_cart_btn, :xpath, "(//*[contains(@value,'Add to Cart') or contains(text(), 'Add to Cart')])[1]"
  element :add_to_cart_on_search_btn, :xpath, "(.//button[@class='btn btn-add-to-cart btn-block ng-isolate-scope'])[1]"
  element :show_more_lnk, '#showBtn a'
  elements :details_txt, 'div.detail-2col-dflt'
  elements :teaches_txt, '.span3.skills-container>ul>li'
  element :credits_lnk, '.details-credits>div>a'
  element :credits_app_title_txt, '.richtext.section>p:first-of-type'
  element :quick_view_overlay, '#productQuickview'

  def close_welcome_popup
    close_btn_css = '.btn.btn-primary.btn-primary_red.center-block.text-center'
    find(close_btn_css).click if page.has_css? close_btn_css, wait: 0
  end

  def load(url)
    visit url
    wait_for_ajax

    # Close Email capture pop-up
    page.execute_script("$('#monetate_lightbox').css('display','none')") if page.has_css? '#email_capture', wait: 0

    close_welcome_popup
  end

  def go_pdp(sku)
    page.find(:xpath, "(.//*[contains(@id, '#{sku}')]/div/p/a)[1]", wait: TimeOut::WAIT_MID_CONST).click
    wait_for_ajax

    # Make sure pdp page is loaded successfully
    page.has_css? '#productOverview', wait: TimeOut::WAIT_MID_CONST

    close_welcome_popup

    AppCenterCatalogATG.new
  end

  # Get HTML value in Catalog/Search pages
  def generate_product_html
    wait_for_ajax
    str = page.evaluate_script("$(\"#{@catalog_div_css}\").parent().html();")
    Nokogiri::HTML(str.to_s)
  end

  # Get product info on Search/Catalog page
  def get_product_info(html_doc, product_id)
    product_el = html_doc.xpath("(.//div[@id='#{product_id}'])[1]")
    return {} if product_el.empty?

    id = product_el.css('div > @id').to_s
    longname = product_el.css('div > div.product-inner > p > a').text
    href = product_el.css('div > div.product-inner > p > a > @href').to_s
    content_type = product_el.css('div > div.product-inner > div.product-thumb.has-content > @data-content').to_s
    format = product_el.css('div > div.product-inner p.format-type').text
    age = product_el.css('div > div.product-inner p.ageDisplay').text

    # Get Price
    price = product_el.css('div > div.product-inner p.prices > span.single.price.strike').text
    price = product_el.css('div > div.product-inner p.prices > span.single.price').text if price.blank?

    { id: id,
      longname: longname,
      href: href,
      price: price,
      content_type: content_type,
      format: format,
      age: age }
  end

  # @return Boolean
  def product_not_exist?(html_doc, product_id)
    html_doc.xpath("(.//div[@id='#{product_id}'])[1]").empty?
  end

  def details_title
    details = [title: '', text: '']
    detail_title = ''
    detail_text = ''

    # Click on Show more link
    if has_show_more_lnk?
      page.execute_script("$('#showBtn a').click();")
      sleep 2
    end

    if has_details_txt?
      details_txt.each do |detail|
        within detail do
          detail_title = RspecEncode.encode_title find('h4').text
          detail_text = RspecEncode.process_long_desc find('p').text
        end

        details.push(title: detail_title, text: detail_text)
      end
    elsif has_css? '.detail-content', wait: 0
      details.push(
        title: RspecEncode.encode_title(page.find('.detail-content > h4').text),
        text: RspecEncode.process_long_desc(page.find('.detail-content > p').text)
      )
    end

    details
  end

  def get_more_info
    div_css = '#productDetails'
    str = page.evaluate_script("$(\"#{div_css}\").parent().html();")
    html_doc = Nokogiri::HTML(str.gsub('<br>', ' '))

    moreinfo_lb = html_doc.css('.credits-link>.text').text.delete("\n").gsub(/\s+/, ' ')
    moreinfo_txt = html_doc.css('#credits').text.delete("\n").gsub(/\s+/, ' ')

    { moreinfo_lb: moreinfo_lb, moreinfo_txt: moreinfo_txt }
  end

  def get_credits_text
    credits_lnk.click
    wait_for_credits_app_title_txt
    credits_app_title = has_credits_app_title_txt? ? credits_app_title_txt.text : 'Not display'
    find('[data-popup-name="Credits"]>div>a').click

    RspecEncode.encode_title credits_app_title
  end

  def get_pdp_info
    wait_for_product_detail_div(TimeOut::WAIT_BIG_CONST * 2)

    # Get all html text script
    return {} unless page.has_css?('.atg-wrapper', wait: TimeOut::WAIT_MID_CONST)
    str = page.evaluate_script("$('.atg-wrapper').parent().html();")

    html_doc = Nokogiri::HTML(str)

    long_name = html_doc.css('h1.product-name').text
    age = RspecEncode.remove_nbsp(html_doc.css('span.pdp-age-mo').text.strip).delete("\n")
    description = html_doc.css('.description').text
    special_message = html_doc.css('.special-message').text
    legal_top = html_doc.css('.legal-top').text
    legal_bottom = html_doc.css('.legal-bottom.section .container').text
    learning_difference = html_doc.css('.span9.teaches-media>p').text
    review = !html_doc.at_css('#Reviews').nil?
    more_like_this = !html_doc.at_css('#MoreLikeThis').nil?
    write_a_review = !html_doc.at_css('.BVRRRatingSummary.BVRRPrimarySummary.BVRRPrimaryRatingSummary').nil?
    add_to_wish_list = !html_doc.at_css('#productDetails .wishlist-link>a').nil?
    has_credits_link = !html_doc.at_css('.details-credits>div>a').nil?
    buy_now_element = html_doc.css('#sub-nav-grnbar-btn')
    buy_now_btn = buy_now_element.empty? ? 'Not exist' : buy_now_element.attr('value').to_s
    details = details_title

    more_info = get_more_info
    moreinfo_lb = more_info[:moreinfo_lb]
    moreinfo_text = more_info[:moreinfo_txt]

    if html_doc.at_css('#productDetails .single.price.strike')
      price = html_doc.css('#productDetails .single.price.strike').text.delete("\n")
    elsif html_doc.at_css('#productDetails .single.price')
      price = html_doc.css('#productDetails .single.price').text.delete("\n")
    else
      price = ''
    end

    content_type = ''
    curriculum = ''
    notable = ''
    work_with = ''
    publisher = ''
    size = ''
    attributes_div.each do |a|
      attr = a.text.split(':')
      content_type = attr[1].strip if attr[0].include?('Type')
      curriculum = attr[1].strip if attr[0].include?('Curriculum')
      notable = attr[1..-1].join(':').strip if attr[0].include?('Notable')
      work_with = attr[1].gsub(', ', ',').strip if attr[0].include?('Works With')
      publisher = attr[1].strip if attr[0].include?('Publisher')
      size = attr[1].strip if attr[0].include?('Size')
    end

    # Get trailer
    if html_doc.at_css('.video').nil?
      has_trailer = false
      trailer_link = ''
    else
      has_trailer = true
      trailer_link = find('.video')['data-largeimage'].to_s.gsub('"', '\"')
    end

    # Get teaches (Skills list)
    teaches = []
    teaches_txt.each do |teach|
      teaches.push(teach.text)
    end

    if has_add_to_cart_btn?(wait: 0)
      add_to_cart_val = 'Add to Cart'
    else
      add_to_cart_val = 'Not Available'
    end

    { long_name: long_name,
      age: age,
      description: description,
      content_type: content_type,
      curriculum: curriculum,
      notable: notable,
      work_with: work_with,
      publisher: publisher,
      size: size,
      moreinfo_lb: moreinfo_lb,
      moreinfo_txt: moreinfo_text,
      special_message: special_message,
      legal_top: legal_top,
      price: price,
      details: details,
      learning_difference: learning_difference,
      legal_bottom: legal_bottom,
      teaches: teaches,
      has_trailer: has_trailer,
      trailer_link: trailer_link,
      has_credits_link: has_credits_link,
      review: review,
      more_like_this: more_like_this,
      write_a_review: write_a_review,
      add_to_wishlist: add_to_wish_list,
      add_to_cart_btn: add_to_cart_val,
      buy_now_btn: buy_now_btn }
  end

  def quick_view_product_by_prodnumber(prod_number)
    wait_for_ajax
    quick_link_css = ".catalog-product \##{prod_number} .quick-view.btn.btn-green.btn-small"

    # Visible Quick link by make style 'display' = 'block'
    page.execute_script("$('#{quick_link_css}').css('display', 'block');")

    find(quick_link_css).click
    wait_for_quick_view_overlay(TimeOut::WAIT_BIG_CONST)
    sleep TimeOut::WAIT_SMALL_CONST
  end

  def get_quick_view_info(prod_number)
    quick_view_product_by_prodnumber prod_number

    # Get all html text script
    return {} unless page.has_css?('#productQuickview', wait: TimeOut::WAIT_MID_CONST)
    str = page.evaluate_script("$('#productQuickview').html();")

    html_doc = Nokogiri::HTML(str)

    long_name = html_doc.css('h2>a').text
    ages = html_doc.css('.span6.description.qv-description-block .ageDisplay').text.gsub(/\n+/, ' ').strip
    see_detail_link = html_doc.css('.span6.description.qv-description-block a').text
    add_to_wish_list = html_doc.css('.wishlist-link>a').text
    add_to_cart = html_doc.at_css('.btn.btn-yellow.add-to-cart.atc-submit.btn-add-to-cart-softgoods').nil? ? 'Not Available' : 'Add to Cart'
    description_header = html_doc.css('.span6.description.qv-description-block>h3:nth-of-type(1)').text.delete("\n").strip
    description = html_doc.css('.span6.description.qv-description-block>p:nth-of-type(2)').text

    quick_view_info = html_doc.css('.span6.description.qv-description-block').text.gsub(/\n+/, ' ').strip
    teaches_header = html_doc.css('.span6.description.qv-description-block>h3:nth-of-type(2)').text.delete("\n").strip
    works_with_header = html_doc.css('.span6.description.qv-description-block>h3:nth-of-type(3)').text.delete("\n").strip

    if teaches_header == 'Teaches:'
      sec1 = quick_view_info.split('Teaches:')[1].split('Works With:')
      teaches = sec1[0]
      works_with = sec1[1].gsub('See Details >', '').strip
    else
      sec1 = quick_view_info.split('Works With:')
      teaches = ''
      works_with = sec1[1].gsub('See Details >', '').strip
    end

    if html_doc.at_css('.single.price.strike')
      price = html_doc.css('.single.price.strike').text.delete("\n")
    elsif html_doc.at_css('.single.price')
      price = html_doc.css('.single.price').text.delete("\n")
    else
      price = ''
    end

    # get size of small icon [height, width]
    if html_doc.at_css('.softgood-sku>img')
      s_height = page.evaluate_script("$('.softgood-sku>img')[0].naturalHeight")
      s_width = page.evaluate_script("$('.softgood-sku>img')[0].naturalWidth")
    else # Mini bundle apps
      s_height = page.evaluate_script("$('.digital-virtual-bundle>img')[0].naturalHeight")
      s_width = page.evaluate_script("$('.digital-virtual-bundle>img')[0].naturalWidth")
    end
    small_icon_size = %W(#{s_height} #{s_width})

    # get size of large icon [height, width]
    # large_icon_size = [quick_view_info.large_icon_img[:naturalHeight], quick_view_info.large_icon_img[:naturalWidth]]
    if html_doc.at_css('.video-container>img')
      l_height = page.evaluate_script("$('.video-container>img')[0].naturalHeight")
      l_width = page.evaluate_script("$('.video-container>img')[0].naturalWidth")
    else # Mini bundle apps
      l_height = page.evaluate_script("$('.row.rollover-top>img')[0].naturalHeight")
      l_width = page.evaluate_script("$('.row.rollover-top>img')[0].naturalWidth")
    end
    large_icon_size = %W(#{l_height} #{l_width})

    { long_name: long_name,
      ages: ages,
      description_header: description_header,
      description: description,
      teaches_header: teaches_header,
      teaches: teaches,
      workswith_header: works_with_header,
      workswith: works_with,
      see_detail_link: see_detail_link,
      price: price,
      add_to_cart: add_to_cart,
      add_to_wishlist: add_to_wish_list,
      small_icon_size: small_icon_size,
      large_icon_size: large_icon_size }
  end

  # Get YMAL information on PDP page
  def get_ymal_info_on_pdp
    ymal_arr = []

    return ymal_arr unless page.has_css?('.reccommended', wait: 30)
    str = page.evaluate_script("$('.reccommended').html();")

    # convert string element to html element
    html_doc = Nokogiri::HTML(str)

    # get all information of product
    html_doc.css('.catalog-product').each do |el|
      ymal_arr.push(
        prod_number: el.css('div > @id').to_s,
        title: el.css('div>div.product-inner>p>a> @title').to_s.strip,
        link: el.css('div>div.product-inner>p>a> @href').to_s
      )
    end

    ymal_arr
  end

  # Return true if e_arr and a_arr there is at least one same element
  def two_platforms_compare?(e_platform, a_platform)
    e_arr = e_platform.split(',')
    a_arr = a_platform.split(',')
    !(e_arr & a_arr).empty?
  end

  def add_sku_to_cart(go_to_cart = true)
    add_to_cart_on_search_btn.click
    wait_for_ajax

    return unless go_to_cart
    nav_account_menu.appcenter_cart_link.click
    wait_for_ajax

    AppCenterCheckOutATG.new
  end

  # Use for Soft Good Smoke Test
  # Get random a product id from Catalog page
  def sg_get_random_product_id(duplicate_item = nil)
    arr_id = []

    # get all id of product on catalog page
    product_list_div.each do |product|
      arr_id.push(product['id'])
    end

    # Remove duplicate items
    arr_id.delete(duplicate_item) unless duplicate_item.nil?

    # return random product id
    arr_id[rand(arr_id.count - 1)]
  end

  def get_random_pro_greater_acc_balance(account_balance)
    return [] unless page.has_css?('.resultList .row.raised')

    str = page.evaluate_script("$('.resultList .row.raised').html();")
    html_doc = Nokogiri::HTML(str)

    product_arr = []
    html_doc.css('.catalog-product').each do |el|
      strike = price = nil
      prod_id = el.css('div > @id').text
      title = el.css('p.heading > a').text
      sale = el.css('.single.price.sale').text.strip
      if sale.empty?
        price = el.css('.single.price').text.strip
        product_arr.push(prod_id: prod_id, title: title, price: price, strike: strike, sale: sale) if price.delete('$').to_f > account_balance
      else
        strike = el.css('.single.price.strike').text.strip
        product_arr.push(prod_id: prod_id, title: title, price: price, strike: strike, sale: sale) if sale.delete('$').to_f > account_balance
      end
    end

    product_arr[rand(product_arr.count - 1)]
  end

  def sg_get_sku(prod_id)
    product = find(:xpath, "(//div[@class='catalog-product']/div[@id='#{prod_id}'])[1]")
    skus_arr = product['data-ga-prod-childskus'].split(',')

    skus_arr.each do |sku|
      return sku if sku.length == 11
    end

    ''
  end

  # Use for Soft Good
  # Get random a product info
  def sg_get_random_product_info(duplicate_item = nil)
    product_id = sg_get_random_product_id duplicate_item
    sku = sg_get_sku product_id
    title = find(:xpath, "(//div[@class='resultList']//*[@id='#{product_id}']/div/p/a)[1]").text

    price, sale, strike = nil
    if has_xpath?("(//*[@id='#{product_id}']//span[@class='single price'])[1]", wait: 1)
      price = find(:xpath, "(//*[@id='#{product_id}']//span[@class='single price'])[1]").text
    else
      strike = find(:xpath, "(//*[@id='#{product_id}']//span[@class='single price strike'])[1]").text
      sale = find(:xpath, "(//*[@id='#{product_id}']//span[@class='single price sale'])[1]").text
    end

    { id: product_id,
      sku: sku,
      title: title,
      price: price,
      strike: strike,
      sale: sale }
  end

  # Use for Soft Good
  # Go to App Center check out page
  def sg_go_to_check_out
    nav_account_menu.appcenter_cart_link.click
    wait_for_ajax
    nav_account_menu.appcenter_cart_link.click if nav_account_menu.app_center_item_number.text.to_i == 0
    AppCenterCheckOutATG.new
  end

  # Add a product to Cart from catalog page by clicking on 'Add to Cart' button
  def add_to_cart_from_catalog(prod_id)
    item_num1 = nav_account_menu.app_center_item_number.text.to_i
    item_num2 = nil

    # Workaround to make script stable by trying to click on Add to Cart button
    btn_add_to_card = find(:xpath, "(.//*[@id='#{prod_id}']//button[@class='btn btn-add-to-cart btn-block ng-isolate-scope'])[1]")
    (1..5).each do
      btn_add_to_card.click
      sleep 1
      item_num2 = nav_account_menu.app_center_item_number.text.to_i
      break if item_num1 < item_num2
    end

    item_num1 < item_num2
  end

  def get_expected_product_info_search_page(title)
    { sku: title['sku'],
      prod_number: title['prodnumber'],
      short_name: RspecEncode.encode_title(title['shortname']),
      long_name: RspecEncode.encode_title(title['longname']),
      price: Title.calculate_price(title['prices_total'], AppCenterContent::CONST_PRICE_TIER),
      content_type: Title.map_content_type(title['contenttype']),
      format: title['format'],
      age: Title.calculate_age_web(title['agefrommonths'], title['agetomonths']) }
  end

  def get_expected_product_info_pdp_page(title)
    details = Title.get_details(title['details']).drop(1)

    { sku: title['sku'],
      prod_number: title['prodnumber'],
      short_name: RspecEncode.encode_title(title['shortname']),
      long_name: RspecEncode.encode_title(title['longname']),
      description: RspecEncode.process_long_desc(title['lfdesc']),
      one_sentence: RspecEncode.process_long_desc(title['onesentence']),
      age: Title.calculate_age_web(title['agefrommonths'], title['agetomonths'], 'pdp'),
      content_type: Title.map_content_type(title['contenttype']),
      format: title['format'],
      price: Title.calculate_price(title['prices_total'], AppCenterContent::CONST_PRICE_TIER),
      curriculum: title['curriculum'],
      work_with: Title.replace_epic_platform(title['platformcompatibility'].split(',')),
      publisher: title['publisher'],
      filesize: Title.calculate_filesize(title['filesizes_total']),
      special_message: RspecEncode.process_long_desc(title['specialmsg']),
      moreinfo_lb: title['moreinfolb'],
      moreinfo_txt: title['moreinfotxt'],
      legal_top: RspecEncode.process_long_desc(title['legaltop']),
      has_trailer: title['trailer'] == 'Yes',
      trailer_link: title['trailerlink'],
      details: details,
      learning_difference: (title['teaches'] == 'Just for Fun') ? '' : RspecEncode.process_long_desc(title['learningdifference']),
      legal_bottom: RspecEncode.process_long_desc(title['legalbottom']),
      review: true,
      more_like_this: true,
      write_a_review: true,
      add_to_wishlist: true,
      add_to_cart_btn: 'Add to Cart',
      buy_now_btn: 'Buy Now ▼',
      highlights: title['highlights'],

      # If content_type = 'Music' => Credit link is exist => 'True', else => 'False'
      has_credits_link: Title.map_content_type(title['contenttype']) == 'Music',

      # Get teaches
      teaches: (title['skills'] == 'Just for Fun') ? [] : Title.teach_info(title['teaches']) }
  end

  def get_actual_product_info_search_page(product_info)
    { long_name: RspecEncode.encode_title(product_info[:longname]),
      price: product_info[:price].strip,
      content_type: product_info[:content_type],
      format: product_info[:format],
      href: product_info[:href],
      age: RspecEncode.remove_nbsp(product_info[:age]) }
  end

  def get_actual_product_info_pdp_page(pdp_info)
    { long_name: RspecEncode.encode_title(pdp_info[:long_name]),
      write_a_review: pdp_info[:write_a_review],
      description: RspecEncode.process_long_desc(pdp_info[:description]),
      age: pdp_info[:age],
      curriculum: pdp_info[:curriculum],
      content_type: pdp_info[:content_type],
      notable: pdp_info[:notable],
      work_with: pdp_info[:work_with].split(','),
      publisher: pdp_info[:publisher],
      filesize: pdp_info[:size],
      special_message: RspecEncode.process_long_desc(pdp_info[:special_message]),
      moreinfo_lb: pdp_info[:moreinfo_lb],
      moreinfo_txt: pdp_info[:moreinfo_txt],
      legal_top: RspecEncode.process_long_desc(pdp_info[:legal_top]),
      price: pdp_info[:price],
      add_to_wishlist: pdp_info[:add_to_wishlist],
      add_to_cart_btn: pdp_info[:add_to_cart_btn],
      buy_now_btn: pdp_info[:buy_now_btn],
      details: pdp_info[:details].drop(1),
      teaches: pdp_info[:teaches],
      learning_difference: RspecEncode.process_long_desc(pdp_info[:learning_difference]),
      legal_bottom: RspecEncode.process_long_desc(pdp_info[:legal_bottom]),
      review: pdp_info[:review],
      more_like_this: pdp_info[:more_like_this],
      highlights: pdp_info[:notable],

      # Get Credit link and Credit text
      has_credits_link: pdp_info[:has_credits_link],

      # Get and check trailer link
      has_trailer: pdp_info[:has_trailer],
      trailer_link: pdp_info[:trailer_link] }
  end

  def get_expected_product_info_quick_view(title)
    teaches_header = ''
    teaches = []
    unless title['teaches'] == 'Just for Fun' || title['teaches'] == ''
      teaches_header = 'Teaches:'
      teaches = title['teaches'].split(',').compact.map(&:strip).sort # split teaches into array and sort
    end

    { sku: title['sku'],
      prod_number: title['prodnumber'],
      short_name: title['shortname'],
      long_name: RspecEncode.encode_title(title['longname']),
      age: Title.calculate_age_web(title['agefrommonths'], title['agetomonths']),
      description_header: 'Description:',
      description: RspecEncode.process_long_desc(title['lfdesc']),
      teaches_header: teaches_header,
      teaches: teaches,
      workswith_header: 'Works With:',
      workswith: Title.replace_epic_platform(title['platformcompatibility'].gsub(/,\s+/, ',').split(',')),
      see_detail_link: 'See Details >',
      price: Title.calculate_price(title['prices_total'], AppCenterContent::CONST_PRICE_TIER),
      add_to_cart: 'Add to Cart',
      add_to_wishlist: 'Add to Wishlist',
      small_icon_size: %w(80 143),
      large_icon_size: %w(135 240),
      one_sentence: RspecEncode.process_long_desc(title['onesentence'])
    }
  end

  def get_actual_product_info_quick_view(quick_view_info)
    { long_name: RspecEncode.encode_title(quick_view_info[:long_name]),
      age: RspecEncode.remove_nbsp(quick_view_info[:ages]),
      description_header: quick_view_info[:description_header],
      description: RspecEncode.process_long_desc(quick_view_info[:description]),
      teaches_header: quick_view_info[:teaches_header],
      teaches: quick_view_info[:teaches].split(',').compact.map(&:strip).sort,
      workswith_header: quick_view_info[:workswith_header],
      workswith: quick_view_info[:workswith].gsub(/,\s+/, ',').split(','),
      see_detail_link: quick_view_info[:see_detail_link],
      price: quick_view_info[:price],
      add_to_cart: quick_view_info[:add_to_cart],
      add_to_wishlist: quick_view_info[:add_to_wishlist],
      small_icon_size: quick_view_info[:small_icon_size],
      large_icon_size: quick_view_info[:large_icon_size] }
  end
end
