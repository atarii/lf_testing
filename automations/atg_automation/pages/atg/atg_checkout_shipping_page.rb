require 'pages/atg/atg_common_page'
require 'pages/atg/atg_checkout_payment_page'

class ShippingAddress < SitePrism::Section
  element :firstname_input, '#atg_newAddrFirstName'
  element :lastname_input, '#atg_newAddrLastName'
  element :street_input, '#atg_addNewAddressLine1'
  element :street_line_2_input, '#atg_addNewAddressLine2'
  element :city_input, '#atg_newAddrCity'
  element :state_opt, '#atg_newAddrState'
  element :zip_input, '#atg_newAddrPostalCode'
  element :phone_input, '#atg_newAddrPhoneNumber'
  element :continue_btn, :xpath, "//*[@id='calculateShippingMethod' and not(@disabled)]"
end

class ValidateAddress < SitePrism::Section
  element :address_error_message_txt, :xpath, "//*[@id='validateAddress']/*[contains(@class,'alert-error')]"
  element :close_verify_address_lnk, :xpath, "//*[@id='validateAddress']/*[@class='close']"
  element :confirm_unit_number_input, '#confirmedStreet2'
  element :confirm_number_btn, '#confirmStreet2'
end

class ShippingMethod < SitePrism::Section
  element :shipping_method_checked, :xpath, "//*[@id='shipOptions']//label[@class='shipping-charge-label checked']"
  element :shipping_method_label, :xpath, "//*[@id='shipOptions']//label/span[contains(text(),'%s')]"
end

class ShippingATG < CommonATG
  section :shipping_address_form, ShippingAddress, '#shippingPayment'
  section :shipping_method_form, ShippingMethod, '#shippingMethodForm'
  section :validate_address_form, ValidateAddress, '#validateAddress', wait: TimeOut::WAIT_CONTROL_CONST * 3

  element :use_entered_address_btn, '#useEnteredAddress'
  element :validate_address_div, '#validateAddress', visible: false
  element :sale_tax_txt, :xpath, ".//*[@id='cartSummary']//div[contains(text(), 'Sales Tax')]/..//span"
  element :suggested_range_address, :xpath, "(.//*[@class='suggestedRangeAddressExperian'])[1]"

  #
  # fill shipping address on shipping tab
  # Return payment page instance
  #
  def fill_shipping_address(firstname, lastname, street, city, state, zip, phone, submit_form = true)
    shipping_address_form.firstname_input.set firstname
    shipping_address_form.lastname_input.set lastname
    shipping_address_form.street_input.set street
    shipping_address_form.city_input.set city

    # display state option
    page.execute_script("$('#atg_newAddrState').css('display','block')")
    shipping_address_form.state_opt.find("option[value='#{state}']").select_option
    shipping_address_form.zip_input.set zip
    shipping_address_form.phone_input.set phone

    # submit information
    shipping_address_form.continue_btn.click
    return unless submit_form

    use_entered_address_btn.click if has_use_entered_address_btn?(wait: TimeOut::WAIT_MID_CONST)
    shipping_address_form.continue_btn.click

    PaymentATG.new
  end

  #
  # Go to payment page from shipping page while account already contains address
  # Return payment page instance
  #
  def shipping_as_full_information_account
    shipping_address_form.continue_btn.click
    PaymentATG.new
  end

  #
  # get text of checked method
  # arg: full_text true/false, get full text or get only shipping date
  # Return text
  #
  def get_shipping_method_checked
    visit current_url if shipping_method_form.has_no_shipping_method_checked?(wait: TimeOut::WAIT_SMALL_CONST)

    shipping_method_checked_text = shipping_method_form.shipping_method_checked.text
    price = shipping_method_checked_text.split(' ')[0]

    # 2nd Day Air  Estimated Delivery:  Jun 26-27
    shipping_method_text = shipping_method_checked_text.gsub(price, '').gsub('Est', 'Estimated').strip
    text_on_csc = shipping_method_checked_text.split(':')[0].gsub(price, '').gsub(', Est. delivery', '').strip
    text_on_email = shipping_method_text.gsub(', Estimated. delivery: ', ' ')

    # Shipping Method 2nd Day Air Jun 27-30
    text_on_confirmation = shipping_method_text.gsub(/[,.]/, '').gsub('delivery', 'Delivery')

    { price: price, text_on_csc: text_on_csc, text_on_email: text_on_email, text_on_confirmation: text_on_confirmation }
  end

  # enter confirm apt/ste/unit number, then click on Confirm Number button
  def confirm_number(confirm_unit_number)
    validate_address_form.confirm_unit_number_input.set confirm_unit_number
    validate_address_form.confirm_number_btn.click
  end

  # choose an address from list on suggestion popup
  def choose_an_address(index = 2)
    return false unless has_xpath?(".//*[@id='#{index}']")

    find(:xpath, ".//*[@id='#{index}']").click
    validate_address_popup_not_appear?

    true
  end

  # close validate address popup then refresh current page
  def close_validate_address_and_refresh_page
    validate_address_form.close_verify_address_lnk.click
    visit current_url
  end

  # get street address line 2 by javascript
  def get_street_address_line2_by_js
    page.evaluate_script("$('#atg_addNewAddressLine2').val();")
  end

  def validate_address_popup_not_appear?
    sleep TimeOut::WAIT_SMALL_CONST
    has_no_validate_address_form?(wait: TimeOut::WAIT_SMALL_CONST)
  end

  # get sale tax
  def get_sale_tax
    wait_for_ajax
    sale_tax_txt.text
  end

  # choose shipping method
  def choose_shipping_method(method = '2nd Day Air')
    wait_for_ajax
    find(:xpath, ".//*[@id='shipOptions']/li/label[contains(text(),'#{method}') or ./span[contains(text(),'#{method}')]]").click
    wait_for_ajax
  end
end
