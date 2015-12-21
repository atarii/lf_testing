require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'

class NavAccountSection < SitePrism::Section
  element :login_register_link, '#headerLogin'
  element :appcenter_cart_link, '.nav-account__mini-cart-softgoods-link'
  element :logout_link, '#atg_logoutBtn'
  element :login_link, '#atg_loginBtn'
  element :checkout_btn, '#miniCartCheckoutBtn'
  element :my_wishlist_lnk, '.nav-account__my-wishlist-list-item .nav-account__my-account-link'
  element :add_item_to_card_lnk, :xpath, "//*[@id='atg_miniWishlistItems']//*[contains(text(),'Add to Cart')][1]"
  element :wishlist_item_number_txt, '.nav-account__my-account-link .ng-binding'
  element :products_link, :xpath, "//*[@id='header']//a[@title='Products']"
end

class MyAccountMenuSection < SitePrism::Section
  element :my_profile_link, :xpath, ".//ul/li/a[contains(text(),'My Profile')]", visible: false
  element :my_orders_link, :xpath, ".//ul/li/a[contains(text(),'My Orders')]", visible: false
  element :welcome_link, :xpath, './/p/strong/span', visible: false
  element :account_balance, :xpath, ".//div/p/span[@ng-bind='shop.accountBalance.fmt']", visible: false
  element :redeem_code_lnk, :xpath, ".//li/a[contains(text(),'Redeem Code')]"
end

class AppCenterDropDownSection < SitePrism::Section
  element :check_out_btn, '.btn.btn-yellow.pull-right.ng-scope'
  elements :cart_items, '.cart-item.mini-cart__item.ng-scope'
  element :remove_item, '.mini-cart__item-action-remove.ng-isolate-scope'
  element :add_to_wishlist, '.mini-cart__item-action-add-to-wishlist.ng-isolate-scope'
  element :cart_dropdown_text, '.text-center .mini-cart-empty.fontsize18'
end

class MyWishlistDropDownSection < SitePrism::Section
  element :wishlist_header, 'div.center h3.no-margin'
end

class CommonATG < SitePrism::Page
  section :nav_account_menu, NavAccountSection, '#navAccount'
  section :my_account_menu, MyAccountMenuSection, '.ui-popover__modal-my-account'
  section :my_wishlist_menu, MyWishlistDropDownSection, '.ui-popover__modal.ui-popover__modal-mini-wishlist'
  section :app_center_cart_menu, AppCenterDropDownSection, '.ui-popover__modal.ui-popover__modal-mini-cart-softgoods'

  element :search_input, '#search'
  element :search_btn, :xpath, "//button[@class='btn']"
  element :search_1result_div, '#MainContent'
  element :add_to_cart_btn, :xpath, "(//*[@cart-button='add' or contains(text(),'Add to Cart')])[1]"
  element :logout_link, :xpath, ".//*[@class='logged-in ng-scope']/p[2]//a"
  elements :color_chk, '.qv-avail-check.colorSwatchName'
  element :out_of_stock_btn, :xpath, ".//*[@id='productQuickview']//input[@value='Out of Stock']"
  element :add_to_cart_popup_btn, :xpath, "(//*[@id='popUpAddToCartButton' and @class='quickview-addtocart']/input[contains(@value,'Add to Cart')])[1]"
  element :multi_skus_class, '.multiple-skus'
  element :leapfrog_logo, '.brand>img'
  element :added_cart_item_number, :xpath, ".//*[@id='navAccount']//a[@class='nav-account__mini-cart-softgoods-link']/span"
  element :added_wishlist_item_number, :xpath, ".//*[@id='navAccount']//a[@class='nav-account__my-account-link']/span"

  # refresh current page
  def refresh
    visit current_url
  end

  #
  # Navigate to login page
  # Return Login/Register page
  #
  def goto_login
    # Go to "Log in/Register" page
    nav_account_menu.login_register_link.click

    atg_login_register = LoginRegisterATG.new

    unless atg_login_register.has_login_form?(wait: TimeOut::WAIT_CONTROL_CONST)
      visit current_url
      nav_account_menu.login_register_link.click
    end

    atg_login_register
  end

  def login_register_text
    nav_account_menu.login_register_link.text.strip
  end

  def mouse_hover_my_account_link
    page.execute_script("$('#headerLogin').trigger('mouseenter')")
  end

  def mouse_hover_wishlist_link
    page.execute_script("$('.nav-account__my-wishlist-list-item .nav-account__my-account-link').trigger('mouseenter')")
  end

  def mouse_hover_app_center_link
    page.execute_script("$('.nav-account__mini-cart-softgoods-link').trigger('mouseenter')")
  end

  def welcome_text
    'Welcome ' + my_account_menu.welcome_link.text.strip
  end

  def click_redeem_code_link
    my_account_menu.redeem_code_lnk.click
  end

  def account_balance
    my_account_menu.account_balance.text.strip
  end

  def cart_item_number
    added_cart_item_number.text.to_i
  end

  def wishlist_item_number
    added_wishlist_item_number.text.to_i
  end

  def wishlish_header_text
    mouse_hover_wishlist_link
    my_wishlist_menu.wishlist_header.text
  end

  def wishlist_items_box?
    page.has_css?('.row.atg-product.ng-scope .media', wait: TimeOut::WAIT_MID_CONST)
  end

  def get_item_info_in_cart_dropdown
    mouse_hover_app_center_link
    return [] unless page.has_css?('.ui-popover__modal.ui-popover__modal-mini-cart-softgoods')

    # convert string element to html element
    str = page.evaluate_script("$('.ui-popover__modal.ui-popover__modal-mini-cart-softgoods').html();")
    html_doc = Nokogiri::HTML(str)

    items_arr = []
    html_doc.css('.cart-item.mini-cart__item.ng-scope').each do |el|
      prod_id = el.css('.mini-cart__item-title a.ng-binding > @href').to_s.split('/')[-1].gsub('A-', '')
      title = el.css('.mini-cart__item-title a.ng-binding').text
      sale = el.css('.mini-cart__item-price > .ng-binding').text.gsub("\n", '')
      strike = el.css('.mini-cart__item-price > .single.price.mini').text.gsub("\n", '')
      price = el.css('.mini-cart__item-price > .ng-binding').text.gsub("\n", '')

      items_arr.push(prod_id: prod_id, title: title, price: price, strike: strike, sale: sale)
    end

    items_arr
  end

  def get_item_info_in_wishlist_dropdown
    mouse_hover_wishlist_link
    return [] unless page.has_css?('.ui-popover__modal.ui-popover__modal-mini-wishlist')

    # convert string element to html element
    str = page.evaluate_script("$('.ui-popover__modal.ui-popover__modal-mini-wishlist').html();")
    html_doc = Nokogiri::HTML(str)

    wish_list_arr = []
    html_doc.css('.cart-item').each do |el|
      prod_id = el.css('@data-productid').to_s
      title = el.css('.product-title').text
      strike = el.css('.strike.ng-binding.ng-scope').text.gsub("\n", '')
      sale = el.css('.price.ng-binding.sale').text.gsub("\n", '')
      price = strike.blank? ? el.css('.price.ng-binding').text.gsub("\n", '') : ''

      wish_list_arr.push(prod_id: prod_id, title: title, price: price, strike: strike, sale: sale)
    end

    wish_list_arr
  end

  def remove_item_from_wishlist_dropdown product_id
    item_num1 = wishlist_item_number
    return if item_num1 == 0

    # Mouse hover on Wishlist menu items
    mouse_hover_wishlist_link

    find(:xpath, ".//li[@data-productid='#{product_id}']//i[@class='icon-close icon']", wait: TimeOut::WAIT_MID_CONST).click
    sleep TimeOut::WAIT_SMALL_CONST

    item_num2 = wishlist_item_number
    return if item_num2 == item_num1 - 1

    find(:xpath, ".//li[@data-productid='#{product_id}']//i[@class='icon-close icon']", wait: TimeOut::WAIT_MID_CONST).click
    sleep TimeOut::WAIT_SMALL_CONST
  end

  def app_center_cart_dropdown_displays?
    app_center_cart_menu.has_check_out_btn?
  end

  def app_center_dropdown_text
    app_center_cart_menu.cart_dropdown_text.text.to_s.strip
  end

  def hover_app_center_cart
    nav_account_menu.execute_script('$(".nav-account__mini-cart-softgoods-link").trigger("mouseenter")')
  end

  def hover_my_wishlist
    nav_account_menu.execute_script('$(".nav-account__my-wishlist-list-item .nav-account__my-account-link").trigger("mouseenter")')
  end

  def hover_the_x_in_the_menu
    page.execute_script("$('.mini-cart__item-actions-dropdown').attr('style', 'opacity: 1; display: block;')")
  end

  def remove_item_app_center_dropdown_cart
    app_center_cart_menu.remove_item.click
    sleep TimeOut::WAIT_SMALL_CONST
  end

  def add_to_wishlist_from_app_center_dropdown_cart
    app_center_cart_menu.add_to_wishlist.click
  end

  #
  # Navigate to My Account page (after login)
  # Return My Profile page
  #
  def goto_my_account
    nav_account_menu.login_register_link.click

    atg_my_profile_page = MyProfileATG.new

    5.times do
      break if atg_my_profile_page.has_account_information_link?(wait: TimeOut::WAIT_BIG_CONST)

      refresh
      nav_account_menu.login_register_link.click

      next
    end

    atg_my_profile_page
  end

  #
  # Search item by enter value into search field and click on search icon
  #
  def search_item(item) # item can be name or id
    wait_for_ajax
    fill_in 'search', with: item
    wait_for_ajax
    search_btn.click
    wait_for_ajax
  end

  #
  # Get product in stock
  # Make sure quickview or pdp page are displayed
  # Product radio button will be chosen
  # Return title of product
  # Add to cart if want_to_add == true
  #
  def get_product_in_stock(title, want_to_add = false)
    return title if !has_multi_skus_class?(wait: TimeOut::WAIT_MID_CONST)

    # Select color
    color_chk.each do |color|
      color.click
      if has_add_to_cart_popup_btn?(wait: TimeOut::WAIT_MID_CONST)
        add_to_cart_popup_btn.click if want_to_add
        return "#{title} - #{color.text}"
      end
    end
  end

  #
  # Add to cart after search item (from search page)
  #
  def add_to_cart(id)
    # Search SKU
    search_item id

    # Click on the Add to Cart button
    add_to_cart_btn.click
    sleep TimeOut::WAIT_MID_CONST

    # process if item has multi colors
    get_product_in_stock(id, true) if has_add_to_cart_popup_btn?(wait: TimeOut::WAIT_MID_CONST)
  end

  #
  # Navige to check out page
  # Return check out page instance
  #
  def goto_checkout
    nav_account_menu.shop_cart_link.click

    # handle: if not on check out page
    checkout_page = CheckOutATG.new
    nav_account_menu.shop_cart_link.click unless checkout_page.has_checkout_btn?(wait: TimeOut::WAIT_MID_CONST)
    wait_for_ajax
    checkout_page
  end

  #
  # Navigate to wishlist page
  # Return my wishlist page instance
  #
  def goto_my_wishlist
    nav_account_menu.my_wishlist_lnk.click
    wait_for_ajax

    wishlist_page = WishListATG.new
    return wishlist_page if wishlist_page.has_wishlist_header?(wait: TimeOut::WAIT_CONTROL_CONST)
  end

  #
  # Logout
  # Return Home page instance
  #
  def logout
    5.times do
      mouse_hover_my_account_link

      if has_logout_link?(wait: TimeOut::WAIT_MID_CONST)
        logout_link.click
        wait_for_ajax
        break
      end

      next
    end

    HomeATG.new
  end

  #
  # Return true if logout successfully
  #
  def logout_successful?
    current_url.include?('/home?DPSLogout=true')
  end

  #
  # Remove all shop cart items
  #
  def remove_all_items_in_shop_cart
    item_number = nav_account_menu.shop_cart_item_number_txt.text.to_i

    return if item_number < 1

    nav_account_menu.shop_cart_link.click
    checkout_page = CheckOutATG.new

    item_number.times do
      checkout_page.delete_link.click
      sleep 1
    end
  end

  def add_to_cart_from_wishlist_link
    page.execute_script("$('#atg_WishlistContainer').css('display','block')")
    nav_account_menu.add_item_to_card_lnk.click
  end

  #
  # click on products link
  #
  def go_to_home_page
    nav_account_menu.products_link.click
    HomeATG.new
  end

  # TBD
  def wait_for_ajax
    Timeout.timeout TimeOut::READTIMEOUT_CONST do
      # handle exception: execution expired. The network is sometimes slow, default_wait_time is not enough
      begin
        active = evaluate_script 'jQuery.active'
        active = evaluate_script 'jQuery.active' until active == 0
      rescue
        puts 'The network is slow. Should optimize the network or increase the time wait'
      end
    end
  end

  #
  # Get SKU, title, platformcompatibility, supported locales of a SKU from database
  #
  def get_ymal_in_database(title_ymal, locale, is_cabo = false)
    ymal_info = []
    ymal_sku_arr = title_ymal.nil? ? [] : title_ymal.downcase.split(',')

    ymal_sku_arr.each do |sku|
      titles_list = Connection.my_sql_connection(AppCenterContent::CONST_QUERY_GET_YMAL_INFO % [sku, locale])
      titles_list = Connection.my_sql_connection(CaboAppCenterContent::CONST_CABO_QUERY_GET_YMAL_INFO % [sku, locale]) if is_cabo # If run for CABO platform
      titles_list.each_hash do |title|
        ymal_info.push(
          sku: sku,
          prod_number: title['prodnumber'],
          title: title['longname'],
          platform: title['platformcompatibility'],
          us: title['us'],
          ca: title['ca'],
          uk: title['uk'],
          ie: title['ie'],
          au: title['au'],
          row: title['row']
        )
      end
    end

    ymal_info
  end

  def support_locale?(ymal_title_hash, locale)
    support =
      case locale.upcase
      when 'US' then
        ymal_title_hash[:us]
      when 'CA' then
        ymal_title_hash[:ca]
      when 'UK' then
        ymal_title_hash[:uk]
      when 'IE' then
        ymal_title_hash[:ie]
      when 'AU' then
        ymal_title_hash[:au]
      else
        ymal_title_hash[:row]
      end

    support.to_s.downcase == 'x'
  end
end
