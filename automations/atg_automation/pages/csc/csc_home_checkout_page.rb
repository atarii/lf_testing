require 'pages/csc/csc_common_page'

class Billing < SitePrism::Section
  element :add_new_credit_card_lnk, '#add-cc-overlay-link'
  element :continue_to_order_review_btn, '#checkoutFooterNextButton'
end

class AddNewCreditCard < SitePrism::Section
  element :card_holder_name_input, '#vin_PaymentMethod_accountHolderName'
  element :card_number_input, '#vin_PaymentMethod_creditCard_account'
  element :exp_month_input, '#vin_PaymentMethod_creditCard_expirationDate_Month'
  element :exp_year_input, '#vin_PaymentMethod_creditCard_expirationDate_Year'
  element :cvv_input, '#vin_PaymentMethod_nameValues_cvn'
  element :country_input, '#vin_PaymentMethod_billingAddress_country'
  element :submit_btn, '#submitCard'
  element :address_input, '#vin_PaymentMethod_billingAddress_addr1'
  element :city_input, '#vin_PaymentMethod_billingAddress_city'
  element :state_input, '#vin_PaymentMethod_billingAddress_district'
  element :zip_input, '#vin_PaymentMethod_billingAddress_postalCode'
  element :phone_input, '#vin_PaymentMethod_billingAddress_phone'
  element :close_btn, :xpath, ".//*[@id='myCsrAddCreditCardFloatingPane']//span[@class='dijitDialogCloseIcon']"
end

class HomeCheckOutCSC < CommonCSC
  # PROPERTIES
  section :billing_section, Billing, '#cmcBillingPContent'
  section :add_new_credit_cart_popup, AddNewCreditCard, '#myCsrAddCreditCardFloatingPane'

  # for check out on csc
  element :product_id_input, '#productID'
  element :search_product_btn, '#searchButton'
  element :item_quantity_input, :xpath, "//input[contains(@id,'itemQuantityprod') and @type='text']"
  element :view_product_btn, :xpath, '(//tr/td[2]//a)[1]'
  elements :product_view_tbl, :xpath, "//table[@class='atg_dataTable']/tbody/tr"
  element :add_to_cart_btn, :xpath, "//input[contains(@id,'itemQuantityprod') and @type='button']"
  element :add_to_cart_on_view_btn, '#skuBrowserAction'
  element :check_out_lnk, :xpath, ".//*[@id='atg_csc_ordersummary_action']/a"
  element :check_out_btn, '#checkoutFooterNextButton'
  element :select_address_btn, :xpath, ".//*[@id='atg_commerce_csr_neworder_ShippingAddressHome']/li[1]/input"
  element :second_day_air_div, :xpath, "//*[@id='csrSelectShippingMethods']//input[@value='#{ProductInformation::SHIPPING_METHOD_CONST}']/.."
  element :second_day_air_radio, :xpath, "//*[@id='csrSelectShippingMethods']//input[@value='#{ProductInformation::SHIPPING_METHOD_CONST}']"
  element :continue_to_billing_btn, :xpath, ".//*[@id='csrSelectShippingMethods']/div[@class='atg_commerce_csr_shippingFooter']/div/input"
  element :credit_card_info_radio, :xpath, ".//*[@id='csrBillingForm']/div[@class='credit-card-info-layout']/input[1]"
  element :continue_to_order_review_btn, '#checkoutFooterNextButton'
  element :submit_order_btn, :xpath, ".//div[@id='cmcCompleteOrderPContent']//div[1]/div/*[@id='checkoutFooterNextButton']"
  element :order_id_lnk, :xpath, ".//*[@id='cmcConfirmOrderPContent']/ul/li[1]/strong/a"
  element :send_confirmation_btn, :xpath, "//input[contains(@id,'atg_widget_validation_SubmitButton') and @value='Send']"
  element :confirm_message_text, :xpath, ".//*[@id='atg_widget_messaging_MessageItem_6']/li/span"
  element :finalize_btn, '#_billingFinalizeButton'
  element :error_message_txt, :xpath, "//span[@class='atg_messaging_title' and contains(text(),'The action produced one or more errors.')]"
  #
  # METHODS
  #
  # Create new customer
  #
  #
  # add new credit card
  #
  def add_new_credit_card(name = 'LTRC DN', cardnumber = '5111005111051128', exp_month = '01', exp_year = '2017', cvv = '123', country = 'US')
    wait_for_ajax
    # open add new credit card popup
    billing_section.add_new_credit_card_lnk.click

    wait_for_ajax
    # fill information
    add_new_credit_cart_popup.card_holder_name_input.set name
    add_new_credit_cart_popup.card_number_input.set cardnumber
    add_new_credit_cart_popup.exp_month_input.set exp_month
    add_new_credit_cart_popup.exp_year_input.set exp_year
    add_new_credit_cart_popup.cvv_input.set cvv
    add_new_credit_cart_popup.country_input.set country

    # fill billing info
    add_new_credit_cart_popup.address_input.set Data::ADDRESS1_CONST
    add_new_credit_cart_popup.city_input.set Data::CITY_CONST
    add_new_credit_cart_popup.state_input.set Generate.state_name(Data::STATE_CODE_CONST)
    add_new_credit_cart_popup.zip_input.set Data::ZIP_CONST
    add_new_credit_cart_popup.phone_input.set Data::PHONE_CONST

    # submit information
    add_new_credit_cart_popup.submit_btn.click

    # sleep to work around with problem at popup cannot close after submiting info
    sleep 5
    execute_script("document.getElementById('myCsrAddCreditCardFloatingPane').removeAttribute('style');")
    wait_for_add_new_credit_cart_popup(TimeOut::WAIT_MID_CONST)
    execute_script("document.getElementsByClassName('dijitDialogUnderlayWrapper')[0].setAttribute('style','display:none');")
    execute_script("document.getElementsByClassName('dijitDialogUnderlayWrapper')[1].setAttribute('style','display:none');")
    wait_for_ajax
    finalize_btn.click
    wait_for_ajax
  end

  #
  # add to cart by product id
  #
  def add_to_cart(id, quantity = 1)
    product_id_input.set id
    search_product_btn.click
    wait_for_ajax
    view_product_btn.click
    wait_for_ajax
    flag = 0
    sku = nil
    title = nil
    product_view_tbl.each do |tr|
      within tr do
        if has_xpath?("td[contains(text(),'In Stock')]", wait: 1)
          find(:xpath, "td/input[@type='text']").set quantity
          flag = 1
          sku = find(:xpath, 'td[2]').text
          title = find(:xpath, 'td[3]').text
        end
      end
      break if flag == 1
    end
    add_to_cart_on_view_btn.click
    wait_for_ajax

    return "Cannot add sku: #{sku} to cart" if has_error_message_txt?(wait: TimeOut::WAIT_MID_CONST)
    { sku: sku, title: title }
  end

  #
  # check out items that added to cart
  # after adding to cart
  # click on check out -> complete checkout -> send mail
  # return shipping price, order number, message when send mail
  # parameters: infor of credit cart if check out for new user (create new credit card while checking)
  #
  def check_out(email = '', name = 'LTRC DN', cardnumber = '5111005111051128', exp_month = '01', exp_year = '2016', cvv = '123', country = 'US')
    # 1. Goto check out page
    check_out_lnk.click
    wait_for_ajax

    # 2. Click on check out button
    check_out_btn.click
    wait_for_ajax

    # 3. Select default address
    select_address_btn.click
    wait_for_ajax

    # 4. Choose shipping method is 2nd day air
    second_day_air_radio.click

    # Get shipping price ======
    shipping_price = second_day_air_div.text[second_day_air_div.text.rindex('$')..-1]

    # 5. Go to billing page
    continue_to_billing_btn.click
    wait_for_ajax

    # 6. Choose default credit card
    if has_credit_card_info_radio?(wait: TimeOut::WAIT_MID_CONST)
      credit_card_info_radio.click
    else
      country = 'Canada' if country == 'CA'
      add_new_credit_card(name, cardnumber, exp_month, exp_year, cvv, country)
      if has_credit_card_info_radio?(wait: TimeOut::WAIT_MID_CONST)
        credit_card_info_radio.click
      else
        return 'Add credit card is not successful'
      end
    end

    # 7. Go to order review page
    continue_to_order_review_btn.click
    wait_for_ajax

    # 8. Submit order
    submit_order_btn.click
    wait_for_ajax

    # 9. Send email confirmation
    send_confirmation_btn.click
    wait_for_ajax

    # Get message after sending email ======
    message = confirm_message_text.text if has_confirm_message_text?

    # 10. Go to order view page
    order_id_lnk.click

    # Get order id
    order_id = order_id_lnk.text

    # record data
    record_order_id(email, order_id) unless email == ''
    { shipping_price: shipping_price, message: message, id: order_id }
  end
end
