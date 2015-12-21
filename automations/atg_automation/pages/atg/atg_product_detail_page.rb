require 'pages/atg/atg_common_page'
require 'pages/atg/atg_login_register_page'

class ProductOverview < SitePrism::Section
  element :breadcrumbs_div, '#breadcrumbs'
  element :image_view_img, :xpath, "//div[@id='image-view-slot']/img"
  elements :price_txt, :xpath, "//*[@id='productOverview']//*[@id='addItemToCartForm']//p[@class='price']"
  element :strike_price_txt, :xpath, "(.//span[@class='single price strike'])[1]"
  element :sale_price_txt, :xpath, "(.//span[@class='single price sale'])[1]"
  element :add_to_cart_pdp_btn, :xpath, "//*[@id='productOverview']//*[contains(@class,'btn-yellow') and contains(@class, 'add-to-cart')]"
  element :add_to_wish_list_without_login_link, :xpath, "//div[@id='productOverview']//a[@class='addToWishlistlogin']"
  element :add_to_wish_list, :xpath, "(//div[@id='productOverview']//a[@class='addToWishlist'])[1]"
  element :sg_add_to_cart_btn, :xpath, "//*[@id='productOverview']//*[@id='addItemToCartForm']//input[@class='btn btn-yellow add-to-cart atc-submit btn-add-to-cart-softgoods']"
end

class NavAccountMenu < SitePrism::Section
  element :app_center_item_number, :xpath, ".//*[@id='navAccount']//a[@class='nav-account__mini-cart-softgoods-link']/span"
end

class ProductDetailATG < CommonATG
  section :product_overview_div, ProductOverview, '#productOverview'
  section :nav_account_menu, NavAccountMenu, '.navbar-inner'
  element :sub_navigation_bar, :xpath, "//*[@id='productInformation']/div[@class='sub-navigation-pdp']/div[@class='container']"
  element :footer_div, '#footer'
  element :buy_now_btn, '#sub-nav-grnbar-btn'
  element :title_txt, :xpath, "//*[@id='productDetails']/h1"
  elements :titles_in_cart_txt, '.title'
  elements :color_chb, :xpath, ".//*[@id='addItemToCartForm']/div[3]/div[1]/div/div/div[2]/p"
  element :mini_cart_check_out_btn, '#miniCartCheckoutBtn'

  # Add to cart from product detail page
  def add_to_cart_from_pdp
    wait_for_ajax

    # process if there are multi skus
    color = get_product_in_stock('')

    5.times do
      if add_to_cart_button_existed?
        5.times do
          product_overview_div.add_to_cart_pdp_btn.click
          return color if cart_count_span.text.to_i > 0
          sleep TimeOut::WAIT_SMALL_CONST
        end
      else # means add to cart did not work, so wait and try again (up to 5 times)
        sleep TimeOut::WAIT_CONTROL_CONST # Wait for adding app to Cart
      end
    end

    color
  end

  # Click on Add to Cart button
  def sg_add_to_cart_from_pdp
    item_num1 = nav_account_menu.app_center_item_number.text.to_i
    item_num2 = nil

    # Workaround to make script stable by trying to click on Add to Cart button
    5.times do
      product_overview_div.sg_add_to_cart_btn.click
      sleep TimeOut::WAIT_SMALL_CONST
      item_num2 = nav_account_menu.app_center_item_number.text.to_i
      break if item_num1 < item_num2
    end

    item_num1 < item_num2
  end

  def get_title_in_cart
    page.execute_script("$('#atg_miniCartContainer').css('display','block')")
    title = ''
    titles_in_cart_txt.each { |title_in_cart| title << title_in_cart.text }
    title
  end

  def product_pdp_page_displays?(product_id)
    product_overview_div.has_breadcrumbs_div?
    current_url.include?(product_id)
  end

  def get_breadcrumbs_text
    product_overview_div.breadcrumbs_div.text
  end

  def get_image_link
    product_overview_div.image_view_img['src']
  end

  def get_product_price
    # get same price if has
    if product_overview_div.has_sale_price_txt?
      sale = product_overview_div.sale_price_txt.text
      strike = product_overview_div.strike_price_txt.text
      return "#{strike} #{sale}"
    end

    # get price
    product_overview_div.price_txt.each do |price_string|
      return price_string.text
    end
  end

  def add_to_cart_button_existed?
    product_overview_div.has_add_to_cart_pdp_btn?(wait: TimeOut::WAIT_CONTROL_CONST)
  end

  def wish_list_link_existed?
    product_overview_div.has_add_to_wish_list_without_login_link?
  end

  def sub_navigation_bar_existed?
    has_sub_navigation_bar?
  end

  def buy_now_button_displays_on_sub_navigation?
    footer_div.click
    has_buy_now_btn?
  end

  #
  # Add an item to wish list from pdp page
  # Return Login page if user doesn't login before
  #
  def add_to_wishlist
    color = get_product_in_stock('')

    if product_overview_div.has_add_to_wish_list?(wait: TimeOut::WAIT_MID_CONST)
      product_overview_div.add_to_wish_list.click
    else
      product_overview_div.add_to_wish_list_without_login_link.click
    end

    color
  end

  def sg_add_to_wishlist
    if product_overview_div.has_add_to_wish_list?(wait: TimeOut::WAIT_MID_CONST)
      product_overview_div.add_to_wish_list.click
    else
      product_overview_div.add_to_wish_list_without_login_link.click
    end

    sleep TimeOut::WAIT_MID_CONST
  end
end
