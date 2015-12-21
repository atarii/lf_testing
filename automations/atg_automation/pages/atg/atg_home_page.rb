require 'pages/atg/atg_product_detail_page'
require 'pages/atg/atg_search_result_page'
require 'pages/atg/atg_common_page'

class HomeATG < CommonATG
  set_url URL::ATG_CONST

  elements :catalog_product_all_results_div, :xpath, "//div[@class='resultList']//div[@class='catalog-product']/div"
  element :test_element, :xpath, "//*[@id='prod60066-00013']/div/div[1]/a[1]"
  element :overview_div, '#productQuickview'
  element :out_of_stock_btn, :xpath, ".//*[@id='productQuickview']//button[@value='Out of Stock' or contains(text(),'Out of Stock')]"
  element :add_to_cart_popup_btn, :xpath, ".//*[@id='popUpAddToCartButton']/input[contains(@value,'Add to Cart')]"
  element :sort_result_by_opt, :css, 'select.input-medium-sort-by'
  element :see_all_result_lnk, :xpath, "//*[@id='MainContent']//div[@class='resultList']//div[@class='row raised']/div[1]//a[contains(text(),'See all')]"
  element :available_product, :xpath, "//*[@value='Add to Cart']"

  # for filter function
  elements :filter_by_product_lnk, :xpath, "//*[@id='LeftContent']/div/div[@data-ga-dimname='Platform']//a"
  elements :filter_by_type_lnk, :xpath, "//*[@id='LeftContent']/div/div[@data-ga-dimname='Format']//a"
  elements :filter_by_age_lnk, :xpath, "//*[@id='LeftContent']/div/div[@data-ga-dimname='Age']//a"
  element :leapfrog_character_lnk, :xpath, "//*[@id='LeftContent']/div/div[@data-ga-dimname='Character']//a[contains(text(),'LeapFrog')]"
  element :show_more_product_lnk, :xpath, "//*[@id='LeftContent']/div/div[2]//a[contains(text(),'Show More')]"
  element :bread_crumb_text, :xpath, "//div[@class='BreadcrumbsWrapper']"
  element :toy_quickview_text, :xpath, "//div[@id='productQuickview']//span[text()='Toy']"
  element :close_quick_view_btn, :xpath, ".//*[@id='productQuickview']/a"
  element :btn_lightbox_close, '.lightboxClose>div'
  element :btn_monetate_close, :xpath, '/html/body/div/div[2]/div/map/area[1]'

  def load
    visit url
    visit url unless has_catalog_product_all_results_div?(wait: TimeOut::WAIT_CONTROL_CONST)
    btn_lightbox_close.click if has_btn_lightbox_close?
    btn_monetate_close.click if has_btn_monetate_close?

    TestDriverManager.session_id
  end

  #
  # Get random a product id on catalog page
  # Return id of product item
  #
  def get_random_product_id
    arr_id = []

    # get all id of product on catalog page
    catalog_product_all_results_div.each do |product|
      if product['id']
        arr_id.push(product['id']) unless has_xpath?("//*[@class='resultList']//div[@id='#{product['id']}']//button[@class='btn btn-block ajax btnDisbaleOutOfStock text-inherit']", wait: 1)
      end
    end

    arr_id[rand(arr_id.count - 1)]
  end

  # get random product information
  # return: hash with title and price
  def get_random_product_info
    # Get product ID
    id = get_random_product_id

    # Get product title
    title = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']/div/p/a").text

    # Get product price
    price, price_sale, sale, strike = ''
    if has_xpath?("//div[@class='resultList']//*[@id='#{id}']//span[@class='single price']", wait: 1)
      price = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price']").text
    else
      strike = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price strike']").text
      sale = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price sale']").text
      price_sale = "#{strike} #{sale}"
    end

    # Make sure quick view link is displayed
    page.execute_script("$('.resultList \##{id} div div a.quick-view.btn.btn-green.btn-small').removeAttr('class');")
    find(:xpath, "(//div[@class='resultList']//a[contains(@data-params,'id=#{id}')])[1]").click

    title = get_product_in_stock(title)

    # Close QuickView box
    find(:xpath, ".//*[@id='productQuickview']/a").click

    # return product info
    { id: id, title: title, price: price, price_sale: price_sale, sale: sale, strike: strike }
  end

  def get_chosen_product_info
    {
      id: SmokeCatalogData::PRODUCT[:prod_id],
      sku: SmokeCatalogData::PRODUCT[:ce_sku],
      title: SmokeCatalogData::PRODUCT[:title],
      price: SmokeCatalogData::PRODUCT[:price],
      strike: SmokeCatalogData::PRODUCT[:strike],
      sale: SmokeCatalogData::PRODUCT[:sale],
      price_sale: SmokeCatalogData::PRODUCT[:price],
      cart_title: SmokeCatalogData::PRODUCT[:cart_title],
      type: SmokeCatalogData::PRODUCT[:type]
    }
  end

  def sg_get_sku(prod_id)
    product = find(:xpath, "(//div[@class='catalog-product']/div[@id='#{prod_id}'])[1]")
    skus_arr = product['data-ga-prod-childskus'].split(',')

    skus_arr.each do |sku|
      return sku if (sku.length == 11)
    end

    ''
  end

  #
  # Get id, title, price of all product in result all section
  # Return array of hash elements
  #
  def get_all_product_info
    arr_product_info = []
    Timeout.timeout 30 do
      # handle exception: execution expired. The network is sometimes slow, default_wait_time is not enough
      begin
        active = evaluate_script 'jQuery.active'
        active = evaluate_script 'jQuery.active' until active == 0
      rescue
        return 'The network is slow. Should optimize the network or increase the time wait'
      end
    end

    find('div.row.product-row')

    all('div.row.product-row div.catalog-product').each do |product|
      within product do
        all_divs = all('div')
        id = all_divs[0][:id]
        div_index = 0

        if id.include? 'monetate'
          id = all_divs[2][:id]
          div_index = 2
        end

        current_div = all_divs[div_index]
        next_div = all_divs[div_index + 1]
        age_start = current_div['data-ga-prod-agestart']
        age_end = current_div['data-ga-prod-ageend']
        platforms = current_div['data-ga-prod-platforms']

        within next_div do
          title = find('p.heading a').text
          prices = all('div.product-availability p.prices span.single.price')
          price = prices.last.text
          arr_product_info.push(id: id, title: title, price: price, agestart: age_start, ageend: age_end, platforms: platforms)
        end
      end
    end

    arr_product_info
  end

  #
  # Click on Add to Cart button from Catalog page
  #
  def add_product_to_cart_from_catalog(prod_id)
    if has_xpath?("//*[@id='#{prod_id}']//a[contains(text(),'Add to Cart')]", wait: TimeOut::WAIT_MID_CONST)
      btn = find(:xpath, "//*[@id='#{prod_id}']//a[contains(text(),'Add to Cart')]")
    else
      btn = find(:xpath, "//*[@id='#{prod_id}']//button[contains(@class, 'btn-add-to-cart')]")
    end

    # Click on Add to Cart
    btn.click

    # process if item has multi colors
    get_product_in_stock('', true)
  end

  #
  # Click an item on catalog page randomize
  # Return array
  #   [0] => product detail page instance
  #   [1] => hash table for product infor {id, title, price}}
  #
  def click_random_product(type = 'link') # type = image or link
    id = get_random_product_id
    image = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//a/img")['src']
    image_link = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']/div/div[contains(@class,'product-thumb')]/a[1]")
    text_link = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']/div/p/a")
    title = text_link.text

    if has_xpath?("//div[@class='resultList']//*[@id='#{id}']//span[@class='single price']", wait: 1)
      price = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price']").text
    else
      strike = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price strike']").text
      sale = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price sale']").text
      price = "#{strike} #{sale}"
    end

    product_info = { id: id, title: title, price: price, image: image }

    # click on link
    if type == 'image'
      image_link.click
    else
      text_link.click
    end

    [ProductDetailATG.new, product_info]
  end

  def click_chosen_product(type = 'link') # type = image or link
    id = SmokeCatalogData::PRODUCT[:prod_id]

    image = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//a/img")['src']
    image_link = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']/div/div[contains(@class,'product-thumb')]/a[1]")
    text_link = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']/div/p/a")

    title = SmokeCatalogData::PRODUCT[:title]
    price = SmokeCatalogData::PRODUCT[:price]
    strike = SmokeCatalogData::PRODUCT[:strike]
    sale = SmokeCatalogData::PRODUCT[:sale]
    cart_title = SmokeCatalogData::PRODUCT[:cart_title]
    type = SmokeCatalogData::PRODUCT[:type]

    product_info = { id: id, title: title, price: price, strike: strike, sale: sale, image: image, cart_title: cart_title, type: type }

    # click on link
    if type == 'image'
      image_link.click
    else
      text_link.click
    end

    [ProductDetailATG.new, product_info]
  end

  #
  # Click an item on catalog page randomize
  # Return array
  #   [0] => search result page instance
  #   [1] => hash table for product infor {id, title, price}}
  #
  def search_random_product_by(type = 'id') # type can be name or id
    id = get_random_product_id
    title = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']/div/p/a").text

    if has_xpath?("//div[@class='resultList']//*[@id='#{id}']//span[@class='single price']", wait: 1)
      price = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price']").text
    else
      strike = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price strike']").text
      sale = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price sale']").text
      price = "#{strike} #{sale}"
    end

    product_info = { id: id, title: title, price: price }

    if type == 'id'
      search_item id
    else
      search_item title
    end
    [SearchResultATG.new, product_info]
  end

  def search_chosen_product_by(type = 'id') # type can be name or id
    id = SmokeCatalogData::PRODUCT[:prod_id]
    title = SmokeCatalogData::PRODUCT[:title]
    price = SmokeCatalogData::PRODUCT[:price]
    cart_title = SmokeCatalogData::PRODUCT[:cart_title]
    product_info = { id: id, title: title, price: price, cart_title: cart_title }

    if type == 'id'
      search_item id
    else
      search_item title
    end

    [SearchResultATG.new, product_info]
  end

  #
  # Check price is sorted low -> high on catalog by
  # Return true if sorted else return title that false
  #
  def price_sorted_low_to_high?
    arr_product_infor = get_all_product_info
    original_array = []

    (0..arr_product_infor.length - 1).each do |i|
      original_array << arr_product_infor[i][:price].gsub(/\$/, '').to_f
    end

    sorted_array = original_array.sort

    return true if (original_array <=> sorted_array) == 0
    false
  end

  #
  # Check price is sorted high -> low on catalog by
  # Return true if sorted else return title that false
  #
  def price_sorted_high_to_low?
    arr_product_infor = get_all_product_info
    original_array = []

    (0..arr_product_infor.length - 1).each do |i|
      original_array << arr_product_infor[i][:price].gsub(/\$/, '').to_f
    end

    sorted_array = original_array.sort { |x, y| y <=> x }

    return true if (original_array <=> sorted_array) == 0

    false
  end

  #
  # Check title sort by alphabetical (a->z)
  # Return true if sorted correctly else return titles that false
  #
  def title_sorted_alphabetical?
    arr_product_infor = get_all_product_info
    original_array = []

    (0..arr_product_infor.length - 1).each do |i|
      original_array << arr_product_infor[i][:title]
    end

    sorted_array = original_array.sort

    return true if (original_array <=> sorted_array) == 0

    false
  end

  #
  # Click on see all on all result section on catalog page
  #
  def see_all_result
    see_all_result_lnk.click if has_see_all_result_lnk?
  end

  #
  # Action sort on catalog page
  # Parameter is type of sort
  #   From SortOption in data.rb
  #   FEATURE_CONST = "Featured"
  #   HIGH_TO_LOW_CONST = "Price (High to Low)"
  #   LOW_TO_HIGH_CONST = "Price (Low to High)"
  #   NEW_CONST = "New"
  #   BEST_SELLING_CONST = "Bestselling"
  #   ALPHABETICAL_CONST = "Alphabetical (A-Z)"
  #
  def sort_result_by(type = SortOption::ALPHABETICAL_CONST)
    find('div.resultList')
    page.execute_script("$('div.resultList div div select:first').css('display','block')")
    element = find(:xpath, ".//select[@class='input-medium-sort-by requester chzn-done']")
    id = element[:id]
    select type, from: id
  end

  #
  # Click random (numb) product(s) to cart
  # Return array of added titles
  #
  def add_random_product_to_cart(numb = 1)
    arr_titles = []

    #  random click
    numb.times do
      id = get_random_product_id
      title = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']/div/p/a").text

      if has_xpath?("//div[@class='resultList']//*[@id='#{id}']//input[contains(@value, 'Add to Cart')]", wait: TimeOut::WAIT_MID_CONST)
        btn = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//input[contains(@value, 'Add to Cart')]")
      else
        btn = find(:xpath, "//*[@class='resultList']//*[@id='#{id}']//a[contains(text(),'Add to Cart')]")
      end

      # add to cart
      btn.click

      # process if item has multi colors
      get_product_in_stock('', true)
      arr_titles.push(title) unless arr_titles.include?(title)
    end

    arr_titles
  end

  def quick_view_product_by_prodnumber(prodnumber)
    quick_link_css = ".resultList \##{prodnumber} div div a.quick-view.btn.btn-green.btn-small"

    # Visible Quick link by make style 'display' = 'block'
    page.execute_script("$('#{quick_link_css}').css('display', 'block');")

    find(quick_link_css).click
  end

  #
  # Hover mouse and click on quick view button of item randomly
  # Return product information {id, title, price}
  #
  def quick_view_random_product
    # Get information of an item randomly
    id = get_random_product_id

    # Get product title
    title = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']/div/p/a").text

    # Get product price
    price, price_sale = ''
    if has_xpath?("//div[@class='resultList']//*[@id='#{id}']//span[@class='single price']", wait: 3)
      price = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price']").text
    else
      strike = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price strike']").text
      sale = find(:xpath, "//div[@class='resultList']//*[@id='#{id}']//span[@class='single price sale']").text
      price_sale = "#{strike} #{sale}"
    end

    # Make sure quick view link is displayed
    page.execute_script("$('.resultList \##{id} div div a.quick-view.btn.btn-green.btn-small').removeAttr('class');")
    find(:xpath, "(//div[@class='resultList']//a[contains(@data-params,'id=#{id}')])[1]").click
    sleep(TimeOut::WAIT_CONTROL_CONST / 9)

    { id: id, title: title, price: price, price_sale: price_sale }
  end

  def quick_view_chosen_product
    # Get information of chosen item
    id = SmokeCatalogData::PRODUCT[:prod_id]

    # Get product info
    title = SmokeCatalogData::PRODUCT[:title]
    price = SmokeCatalogData::PRODUCT[:price]
    price_sale = SmokeCatalogData::PRODUCT[:price]
    cart_title = SmokeCatalogData::PRODUCT[:cart_title]

    # Make sure quick view link is displayed
    page.execute_script("$('.resultList \##{id} div div a.quick-view.btn.btn-green.btn-small').removeAttr('class');")
    find(:xpath, "(//div[@class='resultList']//a[contains(@data-params,'id=#{id}')])[1]").click
    sleep(TimeOut::WAIT_CONTROL_CONST / 9)

    { id: id, title: title, price: price, price_sale: price_sale, cart_title: cart_title }
  end

  #
  # Quick view by id
  # Return description if have
  #
  def quick_view_product_by(id)
    product_description = nil
    detail_pdp_name = nil

    # Make sure quick view link is displayed
    page.execute_script("$('.resultList \##{id} div div a.quick-view.btn.btn-green.btn-small').removeAttr('class');")
    find(:xpath, "(//div[@class='resultList']//a[contains(@data-params,'id=#{id}')])[1]").click

    product_description = find(:xpath, ".//*[@id='#{id}QuickView']/div[3]/div[1]").text if has_xpath?(".//*[@id='#{id}QuickView']/div[3]/div[1]", wait: 3)
    detail_pdp_name = find(:xpath, ".//*[@id='#{id}QuickView']//span[@class='format-title']").text if has_xpath?(".//*[@id='#{id}QuickView']//span[@class='format-title']", wait: 0)

    # Close QuickView box
    close_quick_view_btn.click if has_close_quick_view_btn?

    { description: product_description, detail_pdp_name: detail_pdp_name }
  end

  #
  # Filter product randomly
  # Return hash {title, count}
  #
  def filter_random_product
    # show_more_product_lnk.click
    index_option = rand(filter_by_product_lnk.count - 2) + 1
    product_filter_lnk = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Platform' or @data-ga-dimname='Product' or @data-ga-dimname='#Product#']/ul/li[#{index_option}]/a")

    # Get infor of filter link
    title = product_filter_lnk.text
    count = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Platform' or @data-ga-dimname='Product' or @data-ga-dimname='#Product#']/ul/li[#{index_option}]/a/span").text.gsub(/[()]/, '').to_i

    # Click lick on filter link
    product_filter_lnk.click

    { title: title[0..title.index('(') - 2], count: count }
  end

  def filter_chosen_product
    # show_more_product_lnk.click
    index_option = 1 # LeapTV
    product_filter_lnk = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Platform' or @data-ga-dimname='Product' or @data-ga-dimname='#Product#']/ul/li[#{index_option}]/a")

    # Get infor of filter link
    title = product_filter_lnk.text
    count = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Platform' or @data-ga-dimname='Product' or @data-ga-dimname='#Product#']/ul/li[#{index_option}]/a/span").text.gsub(/[()]/, '').to_i
    product_info = { title: title[0..title.index('(') - 2], count: count }

    # Click lick on filter link
    product_filter_lnk.click

    5.times do
      return product_info unless find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Platform' or @data-ga-dimname='Product' or @data-ga-dimname='#Product#']/ul/li[#{index_option}]/a[@class='checkbox_on']").nil?
      sleep(TimeOut::WAIT_MID_CONST)
    end

    product_info
  end

  #
  # Filter type randomly
  # Return hash {title, count}
  #
  def filter_random_type
    index_option = rand(filter_by_type_lnk.count - 2) + 1

    # Get infor of filter link
    type_filter_lnk = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a")
    title = type_filter_lnk.text

    until has_xpath?("//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a/span", wait: 5)
      index_option = rand(filter_by_type_lnk.count - 2) + 1
      type_filter_lnk = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a")
      title = type_filter_lnk.text
    end

    count = find(:xpath, "//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a/span").text.gsub(/[()]/, '').to_i

    # Click lick on filter link
    type_filter_lnk.click

    { title: title[0..title.index('(') - 2], count: count }
  end

  def filter_first_option
    index_option = 6

    # Get infor of filter link
    type_filter_lnk = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a")
    title = type_filter_lnk.text

    until has_xpath?("//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a/span", wait: 5)
      index_option = rand(filter_by_type_lnk.count - 2) + 1
      type_filter_lnk = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a")
      title = type_filter_lnk.text
    end

    count = find(:xpath, "//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a/span").text.gsub(/[()]/, '').to_i

    # Click lick on filter link
    type_filter_lnk.click

    { title: title[0..title.index('(') - 2], count: count }
  end

  def filter_second_option
    index_option = 6

    # Get infor of filter link
    type_filter_lnk = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a")
    title = type_filter_lnk.text

    until has_xpath?("//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a/span", wait: 5)
      index_option = rand(filter_by_type_lnk.count - 2) + 1
      type_filter_lnk = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a")
      title = type_filter_lnk.text
    end

    count = find(:xpath, "//*[@id='LeftContent']/div/div[@data-ga-dimname='Format' or @data-ga-dimname='#Type#' or @data-ga-dimname='Type']/ul/li[#{index_option}]/a/span").text.gsub(/[()]/, '').to_i

    # Click lick on filter link
    type_filter_lnk.click

    { title: title[0..title.index('(') - 2], count: count }
  end

  #
  # Filter age randomly
  # Return hash {title, count}
  #
  def filter_random_age
    index_option = rand(filter_by_age_lnk.count - 3) + 2
    product_filter_lnk = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Age' or @data-ga-dimname='#Age#']/ul/li[#{index_option}]/a")

    # Get infor of filter link
    title = product_filter_lnk.text
    count = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Age' or @data-ga-dimname='#Age#']/ul/li[#{index_option}]/a/span").text.gsub(/[()]/, '').to_i

    # Click lick on filter link
    product_filter_lnk.click

    { title: title[0..title.index('(') - 2], count: count }
  end

  def filter_chosen_age
    index_option = 2
    product_filter_lnk = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Age' or @data-ga-dimname='#Age#']/ul/li[#{index_option}]/a")

    # Get infor of filter link
    title = product_filter_lnk.text
    count = find(:xpath, ".//*[@id='LeftContent']/div/div[@data-ga-dimname='Age' or @data-ga-dimname='#Age#']/ul/li[#{index_option}]/a/span").text.gsub(/[()]/, '').to_i

    # Click lick on filter link
    product_filter_lnk.click

    { title: title[0..title.index('(') - 2], count: count }
  end

  #
  # Filter leapfrog character
  # No return - only clicks on "Leapfrog" character
  #
  def filter_leapfrog_character
    # Click lick on filter link
    leapfrog_character_lnk.click
  end

  #
  # Get text of breadcrumb on catalog page after filtring
  # Return breadcrumb text
  #
  def get_text_breadcrumb
    bread_crumb_text.text
  end

  #
  # Return true if items display correctly after filtering products
  #
  def products_filter_correct?(product)
    # initial variables
    count = 0
    arr_product_info = get_all_product_info
    platform = product

    # convert some special string
    case product
    when 'Toys'
      platform = 'toys'
    when 'LeapTV'
      platform = 'thd1'
    when 'LeapBand'
      platform = 'lbat'
    when 'LeapPad3'
      platform = 'pad3'
    when 'LeapPad Ultra'
      platform = 'phr1'
    when 'LeapPad2'
      platform = 'pad2'
    when 'LeapsterGS Explorer'
      platform = 'gam2'
    when 'Leapster Explorer'
      platform = 'lst3'
    when 'LeapReader'
      platform = 'lprd'
    when 'Tag'
      platform = 'tag'
    when 'LeapReader Junior'
      platform = 'lprj'
    when 'Tag Junior'
      platform = 'tagj'
    when 'DVD'
      platform = 'dvd'
    end

    # check all product on all results section
    (0..arr_product_info.length - 1).each do |i|
      if arr_product_info[i][:platforms].include?(platform)
        count += 1
      else
        return "Fill by #{platform} is failed by #{arr_product_info[i][:title]}"
      end
    end

    return true if arr_product_info.count == count
  end

  #
  # Check DVD filtering
  #
  def dvd_filter_correct?
    # initial variables
    count = 0
    arr_product_info = get_all_product_info

    # check all DVDs on all results section
    (0..arr_product_info.length - 1).each do |i|
      if has_xpath?("//div[@class='resultList']//div[@id='#{arr_product_info[i][:id]}']//p[text()='DVD']", wait: 0)
        count += 1
      else
        return "DVD - #{arr_product_info[i][:title]}"
      end
    end

    return true if arr_product_info.count == count
  end

  #
  # Check age filtering
  #
  def age_filter_correct?(age_num)
    # initial variables
    count = 0
    arr_product_info = get_all_product_info

    # check ages on all results section
    (0..arr_product_info.length - 1).each do |i|
      agestart = arr_product_info[i][:agestart].to_i
      ageend = arr_product_info[i][:ageend].to_i
      age = age_num.to_i
      if ageend < age * 12 || agestart > (age + 1) * 12
        return "#{age} - #{arr_product_info[i][:title]}"
      else
        count += 1
      end
    end

    return true if arr_product_info.count == count

    false
  end

  #
  # Check multi type filtering
  #
  def multi_type_filter_correct?(*title)
    count = 0
    title_str = nil
    arr_product_info = get_all_product_info

    # check ages on all results section
    (0..arr_product_info.length - 1).each do |i|
      flag = false
      detail_pdp_name = quick_view_product_by(arr_product_info[i][:id])[:detail_pdp_name]

      (0..title.count - 1).each do |j|
        if detail_pdp_name.include?(title[j])
          count += 1
          title_str += title[j]
          flag = true
          break
        end

        next
      end

      return "#{title_str} - #{arr_product_info[i][:title]}" if flag == false
    end

    return true if arr_product_info.count == count

    false
  end
end
