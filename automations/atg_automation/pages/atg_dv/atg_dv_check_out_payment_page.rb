require 'pages/atg_dv/atg_dv_common_page'
require 'pages/atg_dv/atg_dv_check_out_review_page'

class CreditCardSection < SitePrism::Section
  element :txt_device_card_name, '#accountHolderName'
  element :txt_device_card_number, '#creditCardNumber'
  element :txt_device_security_code, '#creditCardCvn'
end

class BillingAddressSection < SitePrism::Section
  element :txt_device_street, '#billingAddress1'
  element :txt_device_street_2, '#billingAddress2'
  element :txt_device_city, '#billingAddressCity'
  element :txt_device_zip_code, '#billingAddressPostalCode'
  element :txt_device_phone_number, '#billingAddressPhone'
  element :btn_device_continue, '#billingContinue'
end

class DeviceRedeemCodeSection < SitePrism::Section
  element :txt_device_input1, :xpath, ".//input[@name='uiRedeemCode1']"
  element :txt_device_input2, :xpath, ".//input[@name='uiRedeemCode2']"
  element :txt_device_input3, :xpath, ".//input[@name='uiRedeemCode3']"
  element :txt_device_input4, :xpath, ".//input[@name='uiRedeemCode4']"
  element :btn_device_state, '.mobile-dropdown__button'
  element :btn_device_redeem, '.btn.btn-primary.pull-right.redeem__btn-submit'
end

class LFCRedeemCodeSection < SitePrism::Section
  element :txt_lfc_input1, :xpath, ".//input[@name='uiRedeemCode1']"
  element :txt_lfc_input2, :xpath, ".//input[@name='uiRedeemCode2']"
  element :txt_lfc_input3, :xpath, ".//input[@name='uiRedeemCode3']"
  element :txt_lfc_input4, :xpath, ".//input[@name='uiRedeemCode4']"
  element :btn_lfc_state, '.chzn-single.chzn-default'
  element :btn_lfc_redeem, :xpath, ".//div[@class='redeemForm1']//button[contains(text(),'Redeem') or contains(text(),'Utiliser')]"
end

class DeviceCodeAcceptedSection < SitePrism::Section
  element :btn_device_continue, :xpath, ".//a[text()='Continue' or text()='Continuer']"
end

class LFCCodeAcceptedSection < SitePrism::Section
  element :btn_lfc_continue, :xpath, ".//a[contains(text(),'Continue') or contains(text(),'Continuer')]"
end

class AtgDvCheckOutPaymentPage < AtgDvCommonPage
  section :credit_card_section, CreditCardSection, '.row.form-narrow.hcenter'
  section :billing_address_section, BillingAddressSection, '.row.form-narrow.hcenter'
  section :device_redeem_code_section, DeviceRedeemCodeSection, '.redeemForm1'
  section :device_code_accepted_section, DeviceCodeAcceptedSection, '.section-fluid'
  section :lfc_redeem_code_section, LFCRedeemCodeSection, '#paymentForm'
  section :lfc_code_accepted_section, LFCCodeAcceptedSection, '#valueCodeSuccessMessage'

  element :btn_device_redeem_now, :xpath, ".//a[@class='btn btn-default btn-sm pull-right' and (contains(text(),'Redeem Now') or contains(text(),'Utiliser'))]"
  element :btn_device_add_new_credit_card, :xpath, ".//a[contains(text(), 'Add New Credit Card')]"
  element :btn_device_continue, :xpath, ".//button[text()='Continue']"
  element :chk_device_first_credit_card, :xpath, "(.//input[@name='selectedSavedCreditCard'])[1]"
  element :btn_device_use_this_credit_card, :xpath, ".//button[text()='Use this Credit Card']"

  element :btn_lfc_redeem_now, :xpath, ".//div[@ng-hide='showRedeemForm']/button[contains(text(),'Redeem') or contains(text(),'Utiliser')]"

  # .trigger('tap'): use for Lpad3, Leappad Platinum
  # .click(): use for LeapPad Ultra, Narnia
  def show_dropdown_list(element)
    page.execute_script("$('#{element}').trigger('tap');")
    page.execute_script("$('#{element}').click();")
    sleep(1)
  end

  def dv_enter_credit_card(credit_card)
    credit_card_section.txt_device_card_name.set credit_card[:card_name]
    credit_card_section.txt_device_card_number.set credit_card[:card_number]

    show_dropdown_list('.cc-exp-month button')
    find(:xpath, ".//*[@class='mobile-dropdown__list']/li[text()='#{credit_card[:exp_month]}']").click

    show_dropdown_list('.cc-exp-year button')
    find(:xpath, ".//*[@class='mobile-dropdown__list']/li[text()='#{credit_card[:exp_year]}']").click

    credit_card_section.txt_device_security_code.set credit_card[:security_code]
  end

  def dv_enter_billing_address(billing_address)
    billing_address_section.txt_device_street.set billing_address[:street]
    billing_address_section.txt_device_city.set billing_address[:city]

    show_dropdown_list('.cc-us-state button')
    find(:xpath, ".//*[@class='mobile-dropdown__list']/li[contains(text(),'#{billing_address[:state]} -')]").click

    billing_address_section.txt_device_zip_code.set billing_address[:postal]
    billing_address_section.txt_device_phone_number.set billing_address[:phone_number]
  end

  def dv_add_credit_card(credit_card, billing_address)
    btn_device_add_new_credit_card.click

    dv_enter_credit_card credit_card
    dv_enter_billing_address billing_address

    btn_device_continue.click
    has_btn_device_use_this_credit_card?(wait: TimeOut::WAIT_CONTROL_CONST)
  end

  def dv_select_credit_card
    chk_device_first_credit_card.click
    btn_device_use_this_credit_card.click
    AtgDvCheckOutReviewPage.new
  end

  def dv_code_type_by_locale
    case
    when current_url.include?('fr-fr')
      'FRV1'
    when current_url.include?('fr-of')
      'OTHR'
    else
      'USV1'
    end
  end

  def dv_redeem_code(env, code_type, device_store, repeat_time = 1)
    if device_store == 'LeapPad3 FR' || device_store == 'LFC French'
      state = 'Afrique du Sud'
    else
      state = 'Alaska'
    end

    review_page = AtgDvCheckOutReviewPage.new

    repeat_time.times do
      pin = PinRedemption.get_pin_info(env, code_type, 'Available')
      return 'Please upload the PIN to redeem' if pin.blank?

      # Update PIN status to Used
      pin_number = pin['pin_number']
      PinRedemption.update_pin_status(env, code_type, pin_number, 'Used')

      if device_store.include? 'LFC'
        btn_lfc_redeem_now.click

        # Enter PIN values
        lfc_redeem_code_section.txt_lfc_input1.set pin_number[0..3]
        lfc_redeem_code_section.txt_lfc_input2.set pin_number[5..8]
        lfc_redeem_code_section.txt_lfc_input3.set pin_number[10..13]
        lfc_redeem_code_section.txt_lfc_input4.set pin_number[15..18]

        # Select State
        lfc_redeem_code_section.btn_lfc_state.click
        find(:xpath, ".//ul[@class='chzn-results']/li[contains(text(),'#{state}')]").click

        # Click on Redeem button
        lfc_redeem_code_section.btn_lfc_redeem.click
        sleep TimeOut::WAIT_MID_CONST

        return "The PIN: #{pin_number} has been redeemed or invalid" unless lfc_code_accepted_section.has_btn_lfc_continue?(wait: TimeOut::WAIT_BIG_CONST)

        # Click on Continue button on Code Accepted page
        lfc_code_accepted_section.btn_lfc_continue.click

        return review_page if review_page.has_btn_lfc_place_order?(wait: TimeOut::WAIT_MID_CONST * 2)
      else
        btn_device_redeem_now.click

        # Enter PIN values
        device_redeem_code_section.txt_device_input1.set pin_number[0..3]
        device_redeem_code_section.txt_device_input2.set pin_number[5..8]
        device_redeem_code_section.txt_device_input3.set pin_number[10..13]
        device_redeem_code_section.txt_device_input4.set pin_number[15..18]

        # Select State
        device_redeem_code_section.btn_device_state.click
        find(:xpath, ".//*[@class='mobile-dropdown__list']/li[contains(text(),'#{state}')]").click

        # Click on Redeem button
        device_redeem_code_section.btn_device_redeem.click
        sleep TimeOut::WAIT_MID_CONST

        return "The PIN: #{pin_number} has been redeemed or invalid" unless device_code_accepted_section.has_btn_device_continue?(wait: TimeOut::WAIT_BIG_CONST)

        # Click on Continue button on Code Accepted page
        device_code_accepted_section.btn_device_continue.click

        return review_page if review_page.has_btn_device_place_order?(wait: TimeOut::WAIT_MID_CONST * 2)
      end
    end
  end
end
