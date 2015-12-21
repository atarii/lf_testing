require 'pages/atg/atg_common_page'
require 'pages/atg/atg_checkout_review_page'

class ExpCreditCardOopsPopup < SitePrism::Section
  element :oops_text, '#expiredCC>p'
  element :close_btn, '.close'
end

class CreditCardAddForm < SitePrism::Section
  element :card_number_input, '#vin_PaymentMethod_creditCard_account'
  element :name_on_card_input, '#vin_PaymentMethod_accountHolderName'
  element :expiration_month_opt, '#vin_PaymentMethod_creditCard_expirationDate_Month'
  element :expiration_year_opt, '#vin_PaymentMethod_creditCard_expirationDate_Year'
  element :security_code_input, '#vin_PaymentMethod_nameValues_cvn'
  element :use_shipping_address_chk, :xpath, "//*[@id='creditCardAddForm']//label[@for='useShippingAddress']"
  element :shipping_checked_chk, :xpath, "//*[@id='creditCardAddForm']//label[@for='useShippingAddress' and @class='checked']"
  element :use_shipping_address_as_billing_address, '#checkoutUseSavedShippedAddressCheckbox'
  element :use_shipping_address_acc_chk, :xpath, ".//*[@id='checkoutUseSavedShippedAddressCheckbox']"
  element :invalid_exp_date_msg, '#creditCardForm #ccDate'

  # billing address
  element :bl_street_addr_input, :xpath, "(.//*[@id='vin_PaymentMethod_billingAddress_addr1'])[1]"
  element :bl_city_input, '#vin_PaymentMethod_billingAddress_city'
  element :bl_state_opt, '#stateSelect'
  element :bl_zip_code_input, '#vin_PaymentMethod_billingAddress_postalCode'
  element :bl_phone_input, '#vin_PaymentMethod_billingAddress_phone'
  element :continue_btn, '#billingContinue'
end

class PaymentATG < CommonATG
  set_url_matcher(%r{.*\/checkout\/payment.jsp})

  section :exp_credit_card_popup, ExpCreditCardOopsPopup, '#expiredCC'
  section :credit_card_add_form, CreditCardAddForm, '#paymentBilling'

  element :continue_btn, :xpath, "//*[@id='paymentBilling']//input[@value='Continue' and @data-target='#savedCreditCardButton']"
  element :payment_form, '#paymentForm'
  element :exp_credit_card_oops_popup, '#expiredCC'
  element :account_balance, '.price-type .cartRight'
  element :cart_total, '.side-price-type .cartRight'
  element :paypal_btn, '#payPalLink>img'

  def payment_page_exist?
    displayed?
  end

  def paypal_button_exist?
    has_paypal_btn?(wait: TimeOut::WAIT_MID_CONST)
  end

  # Fill billing address on payment tab
  def fill_billing_address(billing_address)
    credit_card_add_form.bl_street_addr_input.set billing_address[:street]
    credit_card_add_form.bl_city_input.set billing_address[:city]

    # display state option
    page.execute_script("$('#stateSelect').css('display','block')")
    credit_card_add_form.bl_state_opt.find("option[value='#{billing_address[:state]}']").select_option
    credit_card_add_form.bl_zip_code_input.set billing_address[:postal]
    credit_card_add_form.bl_phone_input.set billing_address[:phone_number]
  end

  #
  # Add credit card on payment tab
  # Return review tab
  #
  def add_credit_card(credit_card, billing_address = nil)
    credit_card_add_form.card_number_input.set credit_card[:card_number]
    credit_card_add_form.name_on_card_input.set credit_card[:card_name]

    # display expiration month option
    page.execute_script("$('#vin_PaymentMethod_creditCard_expirationDate_Month').css('display','block')")
    credit_card_add_form.expiration_month_opt.select credit_card[:exp_month]

    # display expiration year option
    page.execute_script("$('#vin_PaymentMethod_creditCard_expirationDate_Year').css('display','block')")
    credit_card_add_form.expiration_year_opt.select credit_card[:exp_year]

    credit_card_add_form.security_code_input.set credit_card[:security_code]

    if billing_address.nil?
      if credit_card_add_form.has_shipping_checked_chk?
        credit_card_add_form.use_shipping_address_chk.click
      else
        credit_card_add_form.use_shipping_address_as_billing_address.click
      end
    else
      fill_billing_address(billing_address)
    end

    # submit info
    credit_card_add_form.continue_btn.click

    ReviewATG.new
  end

  #
  # Pay while account existed information
  # Return Review tab
  #
  def pay_as_full_information_account
    wait_for_continue_btn(TimeOut::WAIT_MID_CONST)
    continue_btn.click

    ReviewATG.new
  end

  def invalid_exp_date_text
    credit_card_add_form.invalid_exp_date_msg.text
  end

  def exp_credit_card_oops_popup_displays?
    has_exp_credit_card_oops_popup?(wait: TimeOut::WAIT_CONTROL_CONST)
  end

  def exp_credit_card_oops_text
    exp_credit_card_popup.oops_text.text
  end

  def close_exp_credit_card_oops_popup
    exp_credit_card_popup.close_btn.click
  end
end
