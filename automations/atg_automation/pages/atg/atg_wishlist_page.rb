require 'pages/atg/atg_common_page'

class ShareThisWishlistSection < SitePrism::Section
  element :email_your_wishlist_title, '.row.section.ng-scope>h2'
  element :mail_to_txt, :xpath, ".//input[@name='mailTo']"
  element :note_txt, '#note'
  element :send_email_btn, :xpath, ".//input[@value='Send Email']"
end

class WishListATG < CommonATG
  set_url_matcher(%r{.*\/profile\/wishlist})

  section :share_this_wishlist, ShareThisWishlistSection, '.ui-popup__modal.modal.attention'

  element :wishlist_header, '.row.section>h1'
  element :number_of_item_txt, :xpath, "//*[@id='wishlist']//span[@class='wishlist-total-qty']"
  element :product_div, '.span12.raised'
  elements :titles_in_wishlist_txt, '#wishlist .media .span6>h3'
  elements :wishlist_image, :xpath, ".//*[@class='media']/a[@class='pull-left']"
  element :add_to_cart_btn, '.btn.btn-yellow.addItemToCart.ng-scope.ng-isolate-scope'
  elements :all_delete_link, :xpath, ".//*[@id='wishlist']//a[contains(text(),'Remove Item')]"
  element :delete_link, :xpath, "//*[@id='wishlist']/div[2]//a[contains(text(),'Remove Item')]"
  element :share_this_wishlist_btn, :xpath, "//*[@id='wishlist']//a[contains(text(),'Share this wishlist')]"
  element :wishlist_form, '#wishlist'
  elements :wishlist_items, :xpath, ".//li[@class='row atg-product ng-scope']"
  element :wishlist_title, '#wishlist .span12.text-center>h1'
  element :shop_now_btn, :xpath, ".//*[@id='wishlist']//a[contains(text(),'Shop Now')]"
  element :email_wishlist_lnk, :xpath, ".//li[1]//a[contains(text(),'Email Link')]"

  def wishlist_page_existed?
    displayed?
  end

  def get_product_info_in_wishlist
    return [] unless page.has_css?('#wishlist')

    str = page.evaluate_script("$('#wishlist').html();")
    html_doc = Nokogiri::HTML(str)

    wishlist_arr = []
    html_doc.css('.row .atg-product').each do |el|
      prod_id = el.css('div.media >a.pull-left> @href').to_s.split('/')[-1].gsub('A-', '')
      title = el.css('div.media>div>div.row>div.span6>h3>a.ng-binding').text
      price = el.css('div.media>div>div.row>div.span3>span.ng-binding.price').text
      strike = el.css('div.media>div>div.row>div.span3>span.strike.ng-binding.ng-scope').text
      sale = el.css('div.media>div>div.row>div.span3>span.ng-binding.sale').text

      wishlist_arr.push(prod_id: prod_id, title: title, price: price, strike: strike, sale: sale)
    end

    wishlist_arr
  end

  def add_to_card_button_existed?
    has_add_to_cart_btn?
  end

  def wishlist_header_text
    wishlist_title.text
  end

  def shop_now_btn?
    has_shop_now_btn?
  end

  def share_this_wishlist_button_existed?
    has_share_this_wishlist_btn?
  end

  def delete_all_wishlist_items
    wait_for_ajax
    return unless has_all_delete_link?(wait: TimeOut::WAIT_MID_CONST)

    num = all_delete_link.count
    num.times do
      find(:xpath, "(.//*[@id='wishlist']//a[contains(text(),'Remove Item')])[1]").click
      sleep TimeOut::WAIT_MID_CONST
    end
  end

  def add_to_cart
    add_to_cart_btn.click
    sleep TimeOut::WAIT_CONTROL_CONST
  end

  def share_wishlist(email, note)
    share_this_wishlist.mail_to_txt.set email
    share_this_wishlist.note_txt.set note
    share_this_wishlist.send_email_btn.click
    sleep TimeOut::WAIT_SMALL_CONST
  end

  def click_share_this_wishlist_btn
    share_this_wishlist_btn.click
  end

  def click_email_wishlist_link
    email_wishlist_lnk.click
  end

  def email_your_wishlist_popup_displays?
    share_this_wishlist.has_email_your_wishlist_title? wait: TimeOut::WAIT_CONTROL_CONST
  end
end
