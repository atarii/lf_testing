require 'site_prism'

class QuickViewOverlayATG < SitePrism::Page
  element :quick_view_overlay, :xpath, "//*[@id='productQuickview']/a[text()='Close']"
  element :title_of_item_text, :xpath, "//div[@id='productQuickview']//h2"
  elements :price_of_item_text, :xpath, ".//div[@id='productQuickview']//p[@class='price']"
  element :image_of_item_lnk, :xpath, ".//div[@id='productQuickview']//div[@class='span4 qv-media-image']//img"
  element :add_to_cart_btn, :xpath, "//div[@id='productQuickview']//input[contains(@value, 'Add to Cart')]"
  element :add_to_wish_list_lnk, '#addToWishlist'
  element :quantity_label, :xpath, "//div[@id='productQuickview']//label[contains(text(),'Quantity:')]"
  element :close_btn, '#productQuickview .close'
  elements :color_chk, '.qv-avail-check.colorSwatchName'
  element :out_of_stock_btn, :xpath, ".//*[@id='productQuickview']//input[contains(@value,'Out of Stock')]"
  element :quantity_opt, :xpath, "//div[@id='productQuickview']//select[contains(@id,'sel')]"
  element :please_select_text, :xpath, "//p[text()='Please select a product.']"

  def get_title_of_item
    title_of_item_text.text
  end

  def get_item_price
    price_str = ''
    price_of_item_text.each do |price|
      price_str += price.text
    end
    price_str
  end

  def get_image_src
    image_of_item_lnk['src']
  end

  def add_to_cart_button_existed?
    has_add_to_cart_btn?
  end

  def add_to_wish_list_link_existed?
    has_add_to_wish_list_lnk?
  end

  def quantity_label_existed?
    has_quantity_label?
  end

  def close_button_existed?
    has_close_btn?
  end

  def click_close_button
    close_btn.click
  end

  def quick_view_overlay_displayed?
    has_quick_view_overlay?(wait: TimeOut::WAIT_MID_CONST)
  end

  def quick_view_overlay_not_displayed?
    has_no_quick_view_overlay?(wait: TimeOut::WAIT_MID_CONST)
  end

  # Use for Soft Good
  def sg_add_to_cart_from_quickview
    add_to_cart_btn.click
    sleep TimeOut::WAIT_MID_CONST
  end

  def sg_add_to_wishlist
    add_to_wish_list_lnk.click
    sleep TimeOut::WAIT_SMALL_CONST
  end
end
