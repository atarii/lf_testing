require 'automation_common'
require 'pages/atg/atg_common_page'
require 'pages/atg/atg_checkout_paypal_page'
require 'pages/atg/atg_checkout_payment_page'
require 'pages/atg/atg_checkout_review_page'

class AppCenterCheckOutATG < CommonATG
  set_url AppCenterContent::CONST_CHECKOUT_URL

  # properties
  element :redeem_code_form, :xpath, ".//*[@id='paymentForm']/div[@class='redeemForms']/div[@class='redeemForm1']"
  element :checkout_btn, :xpath, ".//button[contains(text(),'Check Out')]"
  element :price_calculator, '#calculated'
  element :credit_card_radio, :xpath, ".//*[@id='savedCardsPaymentFrm']/div/label[1]"
  element :continue_btn, '.btn.btn-yellow.fauxSubmit.pull-right'
  element :place_order_btn, :xpath, "(//input[@value = 'Place Order'])[1]"
  element :successful_order_msg, :xpath, "(//*[@class = 'sub'])[1]"
  element :checkout_error_txt, :xpath, "(.//*[@id='productCompatibilityOverlay']//p)[1]"
  elements :all_delete_link, :xpath, ".//i[@class='fa fa-lg fa-times-circle']"
  element :delete_link, :xpath, "(.//i[@class='fa fa-lg fa-times-circle'])[1]"
  element :paypal_lnk, '#payPalLink>img'
  element :ui_redeem_input1, "input[name = 'uiRedeemCode1']"
  element :ui_redeem_input2, "input[name = 'uiRedeemCode2']"
  element :ui_redeem_input3, "input[name = 'uiRedeemCode3']"
  element :ui_redeem_input4, "input[name = 'uiRedeemCode4']"
  element :state_list, '#paymentForm .row.raised .chzn-single'
  element :continue_on_success_redeem_popup_btn, :xpath, ".//*[@id='valueCodeSuccessMessage']//a[contains(text(), 'Continue')]"
  element :apply_btn, :xpath, ".//*[@id='paymentForm']//input[@value='Apply']"
  element :redeem_btn, :xpath, ".//*[@id='paymentForm']//*[@class='redeemForm1']//button[contains(text(),'Redeem')]"
  element :checkout_error_txt, '.alert.alert-error.ng-binding.ng-scope'
  element :check_out_error_popup, '#productCompatibilityOverlay'
  element :back_to_cart_lnk, :xpath, ".//*[@id='productCompatibilityOverlay']//a[contains(text(),'Back to Cart')]"
  element :buy_hang_on_btn, :xpath, ".//*[@id='productCompatibilityOverlay']//a[contains(text(),'Buy')]"
  element :order_total, '.order-total-amount'
  element :state_cbo, '#paymentForm .row.raised select'
  element :redeem_payment_btn, :xpath, "(.//*[@id='paymentForm']//button[contains(text(),'Redeem')])[1]"
  element :email_txt, '#accountEmail'
  element :password_txt, '#accountPassword'
  element :checkout_user_login_btn, '#checkoutUserLogin'
  element :exp_credit_card_oops_popup, '#expiredCC'

  # methods
  # is an sku has been add to cart
  def sku_added_to_cart?(sku)
    has_xpath?("//li[@data-skuid='#{sku}']")
  end

  #
  # Check out using account with full information (credit card, billing address, shipping address)
  # Make sure your account is logged in site
  # Return successful message after ordering successfully
  #
  def checkout_with_credit_card
    wait_for_ajax
    checkout_btn.click
    wait_for_ajax

    # return error message if Checkout Error popup displays
    return checkout_error_txt.text if has_checkout_error_txt?
    return 'There is no added Credit Card on your account.' unless has_credit_card_radio?

    # Select a added Credit Card
    credit_card_radio.click
    wait_for_ajax

    # Click on Continue button
    continue_btn.click
    wait_for_ajax

    # return error message if Checkout Error popup displays
    return checkout_error_txt.text if has_checkout_error_txt?

    place_order_btn.click
    wait_for_ajax

    # return successful message
    successful_order_msg.text
  end

  #
  # check out with paypal
  #
  def checkout_with_paypal
    wait_for_ajax
    checkout_btn.click

    # return error message if Cheout Error popup is displayed
    return checkout_error_txt.text if has_checkout_error_txt?
    return 'Perhap your account exists balance amount. So you can not check out with paypal in this case' unless has_paypal_lnk?

    paypal_lnk.click
    wait_for_ajax

    paypal_page = PayPalCheckOutATG.new
    return 'Perhap you have problem with paypal site or paypal account' unless paypal_page.login_paypal_account(PayPalInfo::CONST_P_EMAIL, PayPalInfo::CONST_P_PASSWORD)

    paypal_page.pay_app

    # Click on Palace Order button
    place_order_btn.click
    wait_for_ajax

    # return successful message
    successful_order_msg.text
  end

  #
  # check out with existing balance
  #
  def checkout_with_balance
    wait_for_ajax
    checkout_btn.click

    # return error message if Cheout Error popup is displayed
    return checkout_error_txt.text if has_checkout_error_txt?
    return 'Perhap your account is not enough balance to purchase this app.' unless has_place_order_btn?

    place_order_btn.click
    wait_for_ajax

    # return successful message
    successful_order_msg.text
  end

  #
  # check out with value card (using redeem pin)
  #
  def checkout_with_value_card
    value_card_str = nil
    wait_for_ajax
    checkout_btn.click

    # return error message if Cheout Error popup is displayed
    return checkout_error_txt.text if has_checkout_error_txt?

    # Get env and code_type
    env = (Data::ENV_CONST.upcase == 'PROD') ? 'PROD' : 'QA'
    code_type = "#{Data::LOCALE_CONST.upcase}V1"
    if Data::LOCALE_CONST.downcase == 'us'
      state = 'Alaska'
    else # Locale = CA
      state = 'Alberta'
    end

    msg = "#{value_card_str} is redeemed or invalid..."

    3.times do
      # Click on Redeem button on payment form
      redeem_payment_btn.click if has_redeem_payment_btn?(wait: TimeOut::WAIT_MID_CONST)

      # Get available PIN
      pin = PinRedemption.get_pin_number(env, code_type, 'Available')

      next if pin.blank?

      # Enter PIN
      ui_redeem_input1.set pin[0..3]
      ui_redeem_input2.set pin[5..8]
      ui_redeem_input3.set pin[10..13]
      ui_redeem_input4.set pin[15..18]

      # Select State
      state_val = page.evaluate_script("$('#paymentForm .row.raised select option:eq(1)').text();")
      state_list.click
      find(:xpath, "//li[text()='#{state_val}']").click

      # Click on Redeem button
      redeem_btn.click

      # Select state
      page.execute_script("$('#paymentForm .row.raised select').css('display','block')")
      state_cbo.select state

      # click on Redeem button
      redeem_btn.click
      sleep TimeOut::WAIT_MID_CONST

      continue_on_success_redeem_popup_btn.click if has_continue_on_success_redeem_popup_btn?(wait: TimeOut::WAIT_BIG_CONST)

      if has_place_order_btn?(wait: TimeOut::WAIT_BIG_CONST)
        place_order_btn.click
        wait_for_ajax

        # return successful message
        msg = successful_order_msg.text

        # Update PIN status to Used
        PinRedemption.update_pin_status(env, code_type, pin, 'Used')

        break
      end

      next
    end

    msg
  end

  #
  # Delete all wish list are existing on wish list page
  #
  def delete_all_checkout
    wait_for_ajax
    return unless has_all_delete_link?(wait: TimeOut::WAIT_MID_CONST)

    num_of_link = all_delete_link.count
    num_of_link.times do
      delete_link.click
      sleep 1
      wait_for_ajax
    end
  end

  #
  # Click on Check Out button to go to Payment page
  #
  def sg_go_to_payment(allow_error = nil)
    wait_for_ajax
    checkout_btn.click if has_checkout_btn?(wait: TimeOut::WAIT_MID_CONST)

    if has_check_out_error_popup?(wait: TimeOut::WAIT_MID_CONST)
      if allow_error.nil?
        buy_hang_on_btn.click
        wait_for_ajax
      else
        back_to_cart_lnk.click
        return PaymentATG.new
      end
    end

    PaymentATG.new
  end

  #
  # User for Soft Good Smoke test
  # Login to account in Cart page
  #
  def sg_login_account_in_checkout_page(username, password)
    email_txt.set username
    password_txt.set password
    checkout_user_login_btn.click
    wait_for_ajax
  end

  def sg_select_credit_card
    return 'No saved credit card' unless has_credit_card_radio?

    credit_card_radio.click
    continue_btn.click
    ReviewATG.new
  end

  def sg_select_paypal_account
    wait_for_ajax
    return 'Missing Pay Pal link' unless has_paypal_lnk?

    paypal_page = PayPalCheckOutATG.new

    # Click on PayPal link
    paypal_lnk.click

    account_info = paypal_page.sg_login_paypal_account(PayPalInfo::CONST_P_EMAIL, PayPalInfo::CONST_P_PASSWORD)
    unless account_info == false
      paypal_page.pay_app
      return account_info
    end

    'Perhap you have problem with Paypal site or Paypal account'
  end

  def sg_redeem_value_card
    review_page = ReviewATG.new
    return review_page if review_page.review_page_exist?(TimeOut::WAIT_MID_CONST)

    # Get env and code_type
    env = (Data::ENV_CONST.upcase == 'PROD') ? 'PROD' : 'QA'
    code_type = "#{Data::LOCALE_CONST.upcase}V1"
    if Data::LOCALE_CONST.downcase == 'us'
      state = 'Alaska'
    else # Locale = CA
      state = 'Alberta'
    end

    # Enter redeem code
    3.times do
      # Click on Redeem button on payment form
      redeem_payment_btn.click if has_redeem_payment_btn?(wait: TimeOut::WAIT_MID_CONST)

      # Get available PIN
      pin = PinRedemption.get_pin_number(env, code_type, 'Available')

      next if pin.blank?

      ui_redeem_input1.set pin[0..3]
      ui_redeem_input2.set pin[5..8]
      ui_redeem_input3.set pin[10..13]
      ui_redeem_input4.set pin[15..18]

      # Select state
      page.execute_script("$('#paymentForm .row.raised select').css('display','block')")
      state_cbo.select state

      # click on Redeem button
      redeem_btn.click
      sleep TimeOut::WAIT_MID_CONST

      continue_on_success_redeem_popup_btn.click if has_continue_on_success_redeem_popup_btn?(wait: TimeOut::WAIT_BIG_CONST)

      PinRedemption.update_pin_status(env, code_type, pin, 'Used')

      return review_page if review_page.review_page_exist?

      next
    end

    'Error while redeem code. Please re-check!'
  end
end
