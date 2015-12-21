require 'pages/csc/csc_common_page'

class CustomerSearchSection < SitePrism::Section
  element :firstname_input, '#atg_service_customer_searchFirstNameValue'
  element :email_address_input, '#atg_service_customer_searchEmailValue'
  element :search_btn, '#searchButton'
end

class CustomerResultsSection < SitePrism::Section
  element :result_total_txt, :xpath, "//*[@id='customerSearchResultsPanelContent']//div[@class='atg_resultTotal']"
  element :email_link, '#atg_commerce_csr_customer_viewMoreCustomerInfotheCustomerId'
  element :firstname_txt, :xpath, "//*[@id='customerSearchResultsPanelContent']/div/table/tbody/tr/td[4]"
  element :lastname_txt, :xpath, "//*[@id='customerSearchResultsPanelContent']/div/table/tbody/tr/td[3]"
  element :email_txt, :xpath, "//*[@id='customerSearchResultsPanelContent']/div/table/tbody/tr/td[6]"
  EMAIL_LINK_XPATH_CONST = "//*[@id='atg_commerce_csr_customer_viewMoreCustomerInfotheCustomerId' and contains(text(),'%s')]"
end

class OrderHistorySection < SitePrism::Section
  elements :orderhistory_tbl, :xpath, "//div[@id='atg_commerce_csr_customer_order_searchResultsTable']//div[@class='dojoxGrid-row' or @class='dojoxGrid-row dojoxGrid-row-odd']"
  element :fulfilled_td, :xpath, "(.//*[@id='page-0']//td[contains(text(),'Fulfilled')]/../..//td[2]/a)[1]"
end

class OrderAppeasementSection < SitePrism::Section
  element :add_appease_lnk, :xpath, "(//a[@class='atg_svc_popupLink'])[1]"
  element :amount_input, :xpath, "//input[@id='atg_commerce_csr_order_appeasement_amount']"
  element :note_input, :xpath, "//input[@name='atg_commerce_csr_order_note_comments']"
  element :save_btn, :xpath, "//input[@value='Save']"
  element :cancel_btn, :xpath, "//input[@value='Cancel']"
  element :reason_code_cbx, :xpath, "//select[@id='atg_commerce_csr_order_appeasement_reasoncode']"
  APPEASEMENT_RECORD_CONST = "//*[@id='cmcOrderAppeasementPContent']//tr[td[contains(text(), '%s')] and td[contains(text(), '%s')] and td[contains(text(), '%s.00 USD')]]"
end

class OrderView < SitePrism::Section
  element :order_number_txt, :xpath, "//*[@class='atg_commerce_csr_orderNumber']/span[2]"
  element :email_address_txt, :xpath, "//*[@class='atg_commerce_csr_profile']//*[contains(text(),'Email Address')]/../span[2]"
  element :status_txt, :xpath, "//*[@class='atg_commerce_csr_status']"
  element :customer_txt, :xpath, "//*[@class='atg_commerce_csr_profile']//*[contains(text(),'Customer')]/../span[2]"

  element :shopping_cart_table, '.atg_dataTable.atg_commerce_csr_innerTable'
  element :item_description_txt, :xpath, "//*[@class='atg_commerce_csr_itemDesc']/li/a"
  element :qty_txt, :xpath, "//table[@class='atg_dataTable atg_commerce_csr_innerTable']//td[count(//th[text()='Qty.']/preceding-sibling::*)+1]"
  element :price_each_txt, :xpath, "//table[@class='atg_dataTable atg_commerce_csr_innerTable']//td[count(//th[text()='Price Each']/preceding-sibling::*)+1]"
  element :total_price_txt, :xpath, "//table[@class='atg_dataTable atg_commerce_csr_innerTable']//td[count(//th[text()='Total Price']/preceding-sibling::*)+1]"
  element :subtotal_txt, :xpath, "//*[@id='atg_commerce_csr_neworder_orderSummaryData']//*[contains(text(),'Subtotal')]/../td[2]"
  element :order_discount_txt, :xpath, ".//*[@id='atg_commerce_csr_neworder_orderSummaryData']/tbody/tr[2]/td[2]"
  element :adjustment_txt, :xpath, "//*[@id='atg_commerce_csr_neworder_orderSummaryData']/tbody/tr[3]/td[2]"
  element :shipping_txt, :xpath, "//*[@id='atg_commerce_csr_neworder_orderSummaryData']//*[contains(text(),'Shipping')]/../td[2]"
  element :tax_txt, :xpath, "//*[@id='atg_commerce_csr_neworder_orderSummaryData']//*[contains(text(),'Tax')]/../td[2]"
  element :order_total_txt, :xpath, "//*[@id='atg_commerce_csr_neworder_orderSummaryData']//*[contains(text(),'Order Total')]/../../td[2]/span"

  element :shipping_address_txt, :xpath, "//*[@id='cmcExistingOrderPContent']//h4[contains(text(),'Shipping Address')]/../ul"
  element :shipping_method_txt, :xpath, "//*[@class='atg_commerce_csr_shippingMethod']/ul/li"
  element :gs_shipping_session, :xpath, ".//*[@id='cmcExistingOrderPContent']/div[@class='atg_commerce_csr_coreExistingOrderView']/div[3]"

  element :type_txt, :xpath, "//*[@class='atg_commerce_csr_subPanel']//h4[contains(text(),'Type')]/../ul"
  element :billing_address_txt, :xpath, "//*[@id='cmcExistingOrderPContent']//h4[contains(text(),'Billing Address')]/../ul"
  element :amount_txt, :xpath, "(//*[@id='cmcExistingOrderPContent']//h4[contains(text(),'Amount')]/../ul/li)[1]"

  element :vin_order_id_txt, :xpath, "//*[@id='cmcExistingOrderPContent']//li[span[text() = 'Vindicia Order Id:']]/span[@class='atg_commerce_csr_fieldData']"
end

class OrderSearchSection < SitePrism::Section
  element :order_id_input, '#atg_commerce_order_searchOrderIdValue'
  element :email_address_input, '#atg_commerce_order_searchEmailValue'
  element :search_btn, "input[name='advancedSearch']"
end

class OrderResultsSection < SitePrism::Section
  element :id_td, :xpath, "//*[@id='cmcOrderResultsPContent']/div/table/tbody/tr/td[2]"
  element :last_name_td, :xpath, "//*[@id='cmcOrderResultsPContent']/div/table/tbody/tr/td[3]"
  element :first_name_td, :xpath, "//*[@id='cmcOrderResultsPContent']/div/table/tbody/tr/td[4]"
  element :total_td, :xpath, "//*[@id='cmcOrderResultsPContent']/div/table/tbody/tr/td[5]"
  element :quantity_td, :xpath, "//*[@id='cmcOrderResultsPContent']/div/table/tbody/tr/td[6]"
  element :work_on_1st, :xpath, "//*[@id='cmcOrderResultsPContent']//a[text()='Work on'][1]"
end

class HomeCSC < CommonCSC
  # properties
  element :search_customer_link, '#navSearch_customerNavItem'
  element :search_order_link, '#navSearch_orderNavItem'
  element :find_by_id_order_input, "input[name='OPBIDOrderText']"
  element :find_by_id_order_btn, '#OPBIDOrder_button'
  element :warning_ok, '#warningsOk'
  element :select_customer_lnk, '#atg_commerce_csr_customer_selectCustomertheCustomerId'
  element :active_customer_successful_text, :xpath, ".//div[@id='messageFaderWidget']//span[contains(text(),'is now the active customer')]", visible: false
  element :sidebar_link, '#sidebarColumn'
  element :order_find_by_id_input, :xpath, ".//*[@id='OPBIDOrder']/table/tbody/tr/td[2]/input[1]"
  element :order_find_by_id_btn, '#OPBIDOrder_button'
  element :message_detail_widget, '#messageDetailWidget'
  element :message_bar, '#messageBar'

  section :customer_search, CustomerSearchSection, '#customerSearchPanelContent'
  section :customer_result, CustomerResultsSection, '#customerSearchResultsPanelContent'
  section :order_search, OrderSearchSection, '#atg_commerce_csr_orderSearchForm'
  section :order_result, OrderResultsSection, '#cmcOrderResultsPContent'
  section :order_view, OrderView, '#cmcExistingOrderPContent'
  section :order_history, OrderHistorySection, '#customerPanels_customerOrderHistoryPanel_6'
  section :order_appeasement, OrderAppeasementSection, '#cmcOrderAppeasementPContent'

  # for health check
  element :order_search_string, :xpath, ".//*[@id='cmcOrderSearchPS_cmcOrderSearchP_2']//h3"
  element :order_summanry_string, :xpath, ".//*[@id='cmcHelpfulPanels_orderSummaryPanel_1']//h3"

  #
  # methods
  #

  #
  # Check if Add Appeasement link exist
  # num = 1, 2, 3 (Credit Card, Account Balance, Paypal)
  #
  def add_appeasement_lnk_exist?(num = 1)
    # order_appeasement.has_add_appease_lnk?(:wait => TimeOut::WAIT_MID_CONST)
    has_xpath?("(//a[@class='atg_svc_popupLink'])[#{num}]", wait: TimeOut::WAIT_MID_CONST)
  end

  #
  # Click on the Add Appeasement link
  # num = 1, 2, 3 (Credit Card, Account Balance, Paypal)
  #
  def click_add_appeasement_lnk(num = 1)
    find(:xpath, "(//a[@class='atg_svc_popupLink'])[#{num}]").click
  end

  #
  # Make the test poll every 'wait_time' for the status update to a maximum of time_out.
  # wait_time, time_out: seconds
  # e.g. wait_for_change_order_status('lfou15520968', 'Fulfilled', 60, 180)
  #
  def wait_for_change_order_status(order_id, status, wait_time, time_out)
    start_time = 0
    while start_time < time_out
      # Find order by ID
      find_order_by_id order_id

      # Check order status
      return true if order_view.status_txt.text == "Status: #{status}"

      start_time += wait_time
      sleep(wait_time)
    end
    false
  end

  def search_customer_by_email(email)
    wait_for_ajax
    # order_search.has_order_id_input?
    search_customer_link.click
    customer_search.email_address_input.set email
    customer_search.search_btn.click
    (0..4).each do
      if has_no_xpath?("//div[@class='atg_commerce_csr_content']//tr", wait: TimeOut::WAIT_CONTROL_CONST*2)
        customer_search.search_btn.click
      else
        return
      end
    end
  end

  #
  # Search customer by email
  # Click on select link
  # Return error string if activing customer not successfully
  #
  def select_customer_by_email(email)
    # maximize browser to web driver can find select_custome_link
    browser = Capybara.current_session.driver.browser
    browser.manage.window.maximize

    search_customer_by_email(email)

    wait_for_select_customer_lnk(TimeOut::WAIT_CONTROL_CONST)
    select_customer_lnk.click

    if has_message_bar?(wait: TimeOut::WAIT_BIG_CONST)
      message_bar.click
      return message_detail_widget.text.include?('is now the active customer.')
    else
      return 'Error when activing customer'
    end
  end

  #
  # Get customer infor  on CSC page
  # Return string "<email> <firstname> <lastname>"
  #
  def get_customer_info
    (0..4).each do
      if has_xpath?("//div[@class='atg_commerce_csr_content']//tr", wait: TimeOut::WAIT_BIG_CONST)
        return "#{customer_result.email_link.text} #{customer_result.firstname_txt.text} #{customer_result.lastname_txt.text} #{customer_result.email_txt.text}"
      else
        customer_search.search_btn.click
      end
    end
    'Could not found customer information'
  end

  #
  # work on order
  #
  def search_for_order(order_id, email_address)
    is_one_result = true
    order_search.order_id_input.set order_id if !order_id.nil?

    if !email_address.nil?
      order_search.order_id_input.set email_address
      is_one_result = false
    end

    # try to search order by clicking search button many times
    (0..10).each do
      order_search.search_btn.click
      break if order_result.has_work_on_1st?(wait: TimeOut::WAIT_MID_CONST)
    end

    # if there is a order, click on the first order
    return if is_one_result != true
    order_result.work_on_1st.click
    if has_warning_ok?(wait: TimeOut::WAIT_MID_CONST)
      warning_ok.click
    else
      execute_script('atg.service.environment.acceptChangePrompt();return false;')
    end
  end

  #
  # Get order overview information
  #
  def get_order_overview_info
    { id: order_view.order_number_txt.text, \
      customer: order_view.customer_txt.text, \
      email: order_view.email_address_txt.text, \
      status: order_view.status_txt.text, \
      description: order_view.item_description_txt.text, \
      quatity: order_view.qty_txt.text, \
      price_each: order_view.price_each_txt.text, \
      total_price: order_view.total_price_txt.text, \
      subtotal: order_view.subtotal_txt.text, \
      order_discount: order_view.order_discount_txt.text, \
      adjustment: order_view.adjustment_txt.text, \
      shipping_cost: order_view.shipping_txt.text, \
      tax: order_view.tax_txt.text, \
      order_total: order_view.order_total_txt.text,
      shipping_address: order_view.shipping_address_txt.text, \
      shipping_method: order_view.shipping_method_txt.text, \
      billing_type: order_view.type_txt.text, \
      billing_address: order_view.billing_address_txt.text, \
      billing_amount: order_view.amount_txt.text }
  end

  #
  # Calculate order total
  #
  def caculate_order_total
    info = get_order_overview_info
    subtotal = info[:subtotal].gsub(ProductInformation::CURRENCY_CONST, '').to_f.round(2)
    order_discount = info[:order_discount].gsub('$', '').gsub('(', '').gsub(')', '').to_f.round(2)
    adjustment = info[:adjustment].gsub(ProductInformation::CURRENCY_CONST, '').to_f.round(2)
    shipping = info[:shipping_cost].gsub(ProductInformation::CURRENCY_CONST, '').to_f.round(2)
    tax = info[:tax].gsub(ProductInformation::CURRENCY_CONST, '').to_f.round(2)

    # return order total
    (subtotal + order_discount + adjustment + shipping + tax).round(2)
  end

  #
  # Get Originator of an order
  #
  def get_originator_of_order(id)
    goto_customer_info
    find(:xpath, "//*[@id='atg_commerce_csr_customer_order_searchResultsTable']//a[contains(text(),'#{id}')]/../../td[7]").text
  end

  #
  # Search customer by email
  # Click on email link
  # Return HomeCustomerInfor page
  #
  def view_customer_information(email, has_email_on_search_result = false)
    search_customer_by_email(email) if has_email_on_search_result == false

    # try to search order by clicking search button many times
    (1..10).each do
      if has_xpath?(CustomerResultsSection::EMAIL_LINK_XPATH_CONST % email, wait: TimeOut::WAIT_BIG_CONST)
        find(:xpath, CustomerResultsSection::EMAIL_LINK_XPATH_CONST % email, wait: 0).click
        sleep TimeOut::WAIT_CONTROL_CONST
        break
      end
      customer_search.search_btn.click
    end
    HomeCustomerInforCSC.new
  end

  def add_new_appeasement(code, amount, note)
    order_appeasement.reason_code_cbx.find("option[value='#{code}']").click
    order_appeasement.amount_input.set amount
    order_appeasement.note_input.set note

    order_appeasement.save_btn.click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
  end

  #
  # open right sidebar if it is hided
  #
  def show_sidebar
    wait_for_ajax
    return if has_sidebar_link?(wait: TimeOut::WAIT_CONTROL_CONST * 2) == false
    sidebar_link.click
    wait_for_ajax
  end

  #
  # find order by id
  #
  def find_order_by_id(id)
    order_find_by_id_input.set id
    order_find_by_id_btn.click
    wait_for_ajax
  end

  def check_billing_method(type)
    return true if page.has_xpath?("//*[@id='cmcExistingOrderPContent']//li[contains(text(),'#{type}')]")
    false
  end
end
