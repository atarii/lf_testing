require 'pages/atg/atg_common_page'
require 'cgi'

class AtgAppCenterCommon < CommonATG
  # Set url of home page
  set_url URL::ATG_CONST

  # Property
  attr_reader :catalog_div_css, :pdp_div_css

  def initialize
    @catalog_div_css = '.container.no-pad.ng-scope'
    @pdp_div_css = '#product-overview'
  end

  # Elements for PDP page
  element :product_catalog_div, '.container.no-pad.ng-scope'
  element :product_pdp_div, '#product-overview'
  elements :attributes_div, '.list-unstyled>li'

  # Load AppCenter home page
  def load(url)
    visit url
  end

  # Go to PDP page
  def go_pdp(sku)
    page.find(:xpath, ".//*[contains(@id, '#{sku}')]/a", wait: TimeOut::WAIT_MID_CONST).click
    AtgAppCenterCommon.new
  end

  # Get all HTML info on Catalog/Search page
  def generate_product_html
    wait_for_product_catalog_div(TimeOut::WAIT_BIG_CONST)
    return Nokogiri::HTML('') unless page.has_css?(@catalog_div_css, wait: TimeOut::WAIT_MID_CONST)

    str = page.evaluate_script("$(\"#{@catalog_div_css}\").html();")
    Nokogiri::HTML(str.to_s)
  end

  # Get info on Catalog/Search page
  def get_product_info(html_doc, product_id)
    product_el = html_doc.xpath("(.//div[@class='row row-results']//div[@id='#{product_id}'])[1]")
    return {} if product_el.empty?

    id = product_el.css('div>@id').to_s
    longname = product_el.css('.col-xs-12>h2').text
    href = product_el.css('div > a.thumbnail > @href').to_s
    curriculum = product_el.css('.curriculum>strong').text
    age = product_el.css('.age').text

    # Get price
    price = product_el.css('.price.strike').text
    price = product_el.css('.price').text if price.blank?

    # Get content type
    screenshot_url = CGI.parse(product_el.css('.media-item>@src').to_s)
    content_type = screenshot_url['$label'][0]

    { id: id,
      longname: longname,
      href: href,
      curriculum: curriculum,
      age: age,
      price: price,
      content_type: content_type }
  end

  # @return Boolean
  def product_not_exist?(html_doc, product_id)
    html_doc.xpath("(.//div[@id='#{product_id}'])[1]").empty?
  end

  # Get info on PDP page
  def get_pdp_info
    # Wait for loading PDP page
    wait_for_product_pdp_div(TimeOut::WAIT_BIG_CONST)

    # Get all html text script
    return {} unless page.has_css?(@pdp_div_css, wait: TimeOut::WAIT_MID_CONST * 2)
    str = page.evaluate_script("$(\"#{@pdp_div_css}\").html();")

    # Convert string element to html element
    html_doc = Nokogiri::HTML(str)

    # Get all information
    long_name = html_doc.css('.col-xs-12 .row > .col-xs-12 > h1').text
    curriculum_top = (html_doc.css('.col-xs-12 .row > .col-xs-12 > h2').to_a)[0].text # Get the curriculum that displays under longname
    age = RspecEncode.remove_nbsp(html_doc.css('.age').to_a[0].text.strip.delete("\n"))
    price = html_doc.at_css('.price.vcenter').nil? ? html_doc.css('.price.old.vcenter').text.delete("\n") : html_doc.css('.price.vcenter').text.delete("\n")
    add_to_cart_btn = !html_doc.at_css('.btn.btn-primary.ng-isolate-scope').nil? # If 'Add to Cart' button exists => return 'true', else => return 'false'
    add_to_wishlist = !html_doc.at_css('.btn.btn-link.addToWishlistLogin').nil?
    description = RspecEncode.process_long_desc(html_doc.css('.description').text)
    special_message = get_special_msg(html_doc)
    learning_difference = html_doc.css('#teachingInfo>p').text
    has_credit_link = credit_link_exist?

    # Get attributes info: content type, notable, curriculum, work with, publisher, size
    content_type = ''
    notable = ''
    curriculum_bottom = ''
    work_with = ''
    publisher = ''
    size = ''

    attributes_div = html_doc.css('.list-unstyled>li').to_a
    attributes_div.each do |a|
      attr = a.text.split(':')
      content_type = attr[1].strip if attr[0].include?('Type')
      notable = attr[1].strip if attr[0].include?('Notable')
      curriculum_bottom = attr[1].strip if attr[0].include?('Curriculum') || attr[0].include?('Programme')
      work_with = attr[1].gsub(', ', ',').strip if attr[0].include?('Works With') || attr[0].include?('Fonctionne avec')
      publisher = attr[1].strip if attr[0].include?('Publisher') || attr[0].include?('Éditeur')
      size = attr[1].strip if attr[0].include?('Size') || attr[0].include?('Taille')
    end

    # Get legal top/bottom
    legals = get_legal_text
    legal_top = legals[:legal_top]
    legal_bottom = legals[:legal_bottom]

    # Get trailer link
    has_trailer = trailer_exist?
    trailer_link = []
    trailer_arr = (html_doc.css('#productMediaCarousel .owl-stage .ui-carousel__item>.video').to_a)
    trailer_arr.each do |trailer|
      url = trailer.css('@ng-click').to_s.gsub('"', '\"')
      trailer_link.push(url)
    end

    # Get screen shot link
    screenshots = []
    screenshot_arr = html_doc.css('#productMediaCarousel .owl-stage .ui-carousel__item>.media-item').to_a
    screenshot_arr.each do |sc|
      url = sc.css('@src').to_s
      alt = sc.css('@alt').to_s
      screenshots.push(url: url, alt: alt)
    end

    # Get product detail: => {:title, :text}
    details = []
    details_arr = html_doc.css('#details-container div.details-item').to_a
    details_arr.each do |detail|
      title = RspecEncode.encode_title detail.css('h3').text
      text = RspecEncode.process_long_desc detail.css('p').to_s
      details.push(title: title, text: text)
    end

    # Get more info label/text
    more_info = get_more_info
    more_info_label = more_info[:more_info_label]
    more_info_text = more_info[:more_info_text]

    # Get all teaches
    teaches = []
    teaches_arr = html_doc.css('#teachingInfo>ul>li>span').to_a
    teaches_arr.each do |teach|
      teaches.push(teach.text)
    end

    # Get More like this: if exist => 'True', else => 'False'
    more_like_this_arr = (html_doc.css('.thumbnail').to_a)[1]
    more_like_this = !more_like_this_arr.nil?

    # Put all info into array
    { long_name: long_name,
      curriculum_top: curriculum_top,
      age: age,
      price: price,
      has_trailer: has_trailer,
      trailer_link: trailer_link,
      screenshots: screenshots,
      legal_top: legal_top,
      add_to_wishlist: add_to_wishlist,
      add_to_cart_btn: add_to_cart_btn,
      description: description,
      content_type: content_type,
      notable: notable,
      curriculum_bottom: curriculum_bottom,
      work_with: work_with,
      publisher: publisher,
      size: size,
      special_message: special_message,
      more_info_label: more_info_label,
      more_info_text: more_info_text,
      details: details,
      teaches: teaches,
      learning_difference: learning_difference,
      has_credit_link: has_credit_link,
      more_like_this: more_like_this,
      legal_bottom: legal_bottom }
  end

  # Get special message
  def get_special_msg(html_doc)
    row = html_doc.css('div >.row>.container>.row').to_a
    next_el = nil
    row.each_with_index do |r, index|
      if r.text.include?('Works With') || r.text.include?('Programme')
        next_el = row[index + 1]
        break
      end
    end

    msg = next_el.nil? ? '' : next_el.text
    return '' if ['Details', 'Teaches', 'Overall Rating:', 'Reviews', 'More Like This', 'Détails', 'Apports éducatifs', 'Apps similaires'].any? { |w| msg =~ /#{w}/ }
    msg.delete("\n")
  end

  # Get legal top/bottom text
  def get_legal_text
    str = page.evaluate_script("$('.container-fluid').parent().html();")
    html_doc = Nokogiri::HTML(str.gsub('<br>', "\n"))

    # Get legal top/bottom text
    legal_top = html_doc.css('#product-overview > .col-xs-12 .container .row .col-xs-12 .disclaimer').text.gsub(/[ ]+/, ' ')
    legal_bottom = html_doc.css('#product-overview > .container .row .col-xs-12 .disclaimer').text.gsub(/[ ]+/, ' ')

    { legal_top: legal_top, legal_bottom: legal_bottom }
  end

  # Get more info label/text
  def get_more_info
    div_css = '#product-overview'
    str = page.evaluate_script("$(\"#{div_css}\").parent().html();")
    html_doc = Nokogiri::HTML(str.gsub('<br>', ' '))

    # Get more info label/text
    more_info_text = ''
    more_info_label = html_doc.css('#product-overview > .col-xs-12 .container > .row > .col-xs-12 > .btn.btn-link').text.gsub(/\s+/, ' ') # text.gsub(/\s+/,' ') => Replace double spaces with one spaces
    if more_info_label == 'Credits' || more_info_label == 'Crédits'
      more_info_label = ''
    else
      page.execute_script("$('#product-overview > .col-xs-12 .container > .row > .col-xs-12 > .btn.btn-link > .fa.fa-info-circle.fa-lg').click();")
      more_info_text = page.evaluate_script("$('.slidein .col-xs-12>p').text();").gsub(/\s+/, ' ')
    end

    # Close pop-up
    page.execute_script("$('.fa.fa-times.fa-2x.light-grey').click();")

    { more_info_label: more_info_label, more_info_text: more_info_text }
  end

  # Check if Trailer link exist or not exist
  def trailer_exist?
    !page.evaluate_script("$('#productMediaCarousel .owl-stage .ui-carousel__item>.video').attr('ng-click');").nil?
  end

  # Check if Credit link exist
  def credit_link_exist?
    credit_link_text = page.evaluate_script("$('#product-overview .col-xs-12>.btn.btn-link').text();")
    credit_link_text == 'Credits' || credit_link_text == 'Crédits'
  end

  # get Credit text
  def get_credits_text
    # Click on Credit link
    page.execute_script("$('#product-overview .col-xs-12>.btn.btn-link').click();")
    sleep(TimeOut::WAIT_MID_CONST)

    # Get credit text
    credits_text = page.evaluate_script("$('.slidein-content .richtext.section>p:nth-of-type(-n + 2)').text();")

    # Close pop-up
    page.execute_script("$('.fa.fa-times.fa-2x.light-grey').click();")

    RspecEncode.encode_title credits_text
  end

  # Get YMAL information on PDP page
  def get_ymal_info_on_pdp
    ymal_arr = []

    # Get YMAL HTML elements
    page.has_css?('.row .row-results', wait: TimeOut::WAIT_MID_CONST)
    str = page.evaluate_script("$('.row .row-results').html();")
    html_doc = Nokogiri::HTML(str)

    # get all information of product
    html_doc.css('.owl-stage .owl-item').each do |el|
      prod_number = el.css('div> @id').to_s
      title = el.css('div>a>div.caption>div.row>div.col-xs-12>h2').text.strip
      link = el.css('div>a> @href').to_s

      # Put all info into array
      ymal_arr.push(prod_number: prod_number, title: title, link: link)
    end

    ymal_arr.uniq
  end
end
