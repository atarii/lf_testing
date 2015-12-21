require 'pages/atg/atg_common_page'
require 'pages/atg/atg_checkout_shipping_page'

class CheckOutAsGuest < SitePrism::Section
  element :guest_email_input, '#guestEmail'
  element :guest_checkout_btn, '#verifyUser'
end

class CheckOutAsExistingUser < SitePrism::Section
  element :user_email_input, '#accountEmail'
  element :user_password_input, '#accountPassword'
  element :user_checkout_btn, '#checkoutUserLogin'
end

class CheckOutATG < CommonATG
  set_url_matcher(/.*\/checkout.*/)

  # properties
  section :checkout_asguest_form, CheckOutAsGuest, '#cartLogin'
  section :checkout_as_existing_user_form, CheckOutAsExistingUser, '#loginAccount'

  # Elements
  element :cart_content_div, :xpath, ".//*[@data-ga-location='Cart']"
  element :checkout_btn, :xpath, ".//*[@id='moveToPurchase']/button"
  element :edit_shipping_address_btn, :xpath, "//a[@class='editShippingInfo btn btn-yellow btn-raised right ']"
  element :continue_btn, '#calculateShippingMethod'
  elements :title_items_txt, :xpath, "//*[@id='moveToPurchase']//*[@id='cartContent']/div[@class='cart-item row section']//div[@class='product-title']/a"
  elements :cart_content_txt, :xpath, "//*[@id='cartContent']/div"
  element :remove_link_of_item_1_in_cart_content, :xpath, "(.//a[@class='primary blk ng-isolate-scope'])[1]"
  elements :all_delete_link, :xpath, ".//i[@class='fa fa-lg fa-times-circle']"
  element :delete_link, :xpath, "(.//i[@class='fa fa-lg fa-times-circle'])[1]"
  elements :checkout_items_scr, '.media .pull-left'
  elements :checkout_items_title, '.media h3'
  elements :remove_items_in_cart_page, '.fa.fa-lg.fa-times-circle'
  element :remove_item_lnk, :xpath, "(.//i[@class='fa fa-lg fa-times-circle'])[1]"

  # methods
  def checkout_asguest(email)
    checkout_asguest_form.guest_email_input.set email
    checkout_asguest_form.guest_checkout_btn.click
    ShippingATG.new
  end

  # check out as logged in account
  def check_out_as_logged_in_account
    checkout_btn.click
    ShippingATG.new
  end

  #
  # Check out using account with full information (credit card, billing address, shipping address)
  #
  def checkout_as_existing_user(email, password)
    checkout_as_existing_user_form.user_email_input.set email
    checkout_as_existing_user_form.user_password_input.set password
    checkout_as_existing_user_form.user_checkout_btn.click
  end

  #
  # Delete all wish list are existing on check out page
  #
  def delete_all_checkout
    return unless has_all_delete_link?(wait: TimeOut::WAIT_MID_CONST)

    num_of_link = all_delete_link.count
    num_of_link.times do
      delete_link.click
    end
  end

  def get_product_id_of_checkout_items
    scr_link = ''
    checkout_items_scr.each { |item| scr_link << item['href'] << '|' }
    scr_link
  end

  #
  # Get prod_id, title, price of all items on wish list page
  #
  def get_items_info_in_cart
    return [] unless page.has_css?('.no-style.cart__list', wait: TimeOut::WAIT_BIG_CONST)

    items_arr = []
    str = page.evaluate_script("$('.no-style.cart__list').html();")
    html_doc = Nokogiri::HTML(str)

    # get all information of product
    html_doc.css('.cart__item.ng-scope').each do |el|
      prod_id = el.css('div.media >a.pull-left> @href').to_s.split('/')[-1].gsub('A-', '')
      title = el.css('div.media>div>div.row>div>h3.title>a.ng-binding').text
      strike = el.css('div.media>div>div.row>div.span3>div.qty-price>span.single.price.strike.ng-binding').text
      sale = el.css('div.media>div>div.row>div.span3>div.qty-price>span.single.price.ng-binding.sale').text
      price = el.css('div.media>div>div.row>div.span3>div.qty-price>span.single.price').text if strike == ''

      # Put all info into array
      items_arr.push(prod_id: prod_id, title: title, price: price, strike: strike, sale: sale)
    end

    items_arr
  end

  def delete_all_items_in_cart_page
    return unless has_remove_items_in_cart_page?(wait: TimeOut::WAIT_MID_CONST)

    num_of_link = remove_items_in_cart_page.count
    num_of_link.times do
      remove_item_lnk.click
      sleep TimeOut::WAIT_MID_CONST
    end
  end

  def added_items_box?
    page.has_css?('.media.softgoods-cart-item__body', wait: TimeOut::WAIT_MID_CONST)
  end
end
