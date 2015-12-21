require 'pages/atg/atg_product_detail_page'
require 'pages/atg/atg_common_page'

class SearchResultATG < CommonATG
  set_url_matcher(/.*store\/search/)

  element :result_for_txt, :xpath, ".//*[@id='MainContent']/div[@class='searchAdjustments']/p"

  #
  # Return true if current url contains "search" string, else return false
  #
  def search_result_page_existed?
    displayed?
  end

  #
  # Return hash table {id, title, price}
  #
  def get_item_infor(item_id)
    title = all(:xpath, "//*[@id='MainContent']//*[@id='#{item_id}']//div/p/a").last.text

    if has_xpath?("//div[@class='resultList']//*[@id='#{item_id}']//span[@class='single price']", wait: 2)
      price = all(:xpath, "//div[@class='resultList']//*[@id='#{item_id}']//span[@class='single price']").last.text
    else
      price = all(:xpath, "//div[@class='resultList']//*[@id='#{item_id}']//span[@class='single price sale']").last.text
    end

    { id: item_id, title: title, price: price }
  end

  #
  # Return true if "Add to Cart" button of searched item exists
  #
  def add_to_cart_button_existed?(item_id)
    sleep TimeOut::WAIT_MID_CONST
    return true if has_xpath?("//div[@id='#{item_id}']//input[@value='Add to Cart']") || has_xpath?("//*[@id='#{item_id}']//a[contains(text(),'Add to Cart')]")
    false
  end

  #
  # Return text Research for <searched item> exists
  #
  def result_for_title
    result_for_txt.text
  end

  #
  # Return link of image if image link of searched item in result page contains product id
  #
  def item_image_existed(item_id)
    image_link = all(:xpath, "//*[@id='MainContent']//div[@id='#{item_id}']//a/img").last
    image_link['src']
  end
end
