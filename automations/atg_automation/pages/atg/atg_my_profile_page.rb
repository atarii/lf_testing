require 'pages/atg/atg_common_page'

class AccountInformation < SitePrism::Section
  element :firstname_txt, :xpath, "//div[@id='personalInfo']/div/dl[@class='personal-info-list']/dt[contains(text(),'First name')]/following::dd[1]"
  element :lastname_txt, :xpath, "//div[@id='personalInfo']/div/dl[@class='personal-info-list']/dt[contains(text(),'Last name')]/following::dd[1]"
  element :email_txt, :xpath, "//div[@id='personalInfo']/div/dl[@class='personal-info-list']/dt[contains(text(),'Email')]/following::dd[1]"
  element :password_txt, :xpath, "//div[@id='personalInfo']/div/dl[@class='personal-info-list']/dt[contains(text(),'Password')]/following::dd[1]"
  element :zip_code_txt, :xpath, "//div[@id='personalInfo']/div/dl[@class='personal-info-list']/dt[contains(text(),'code')]/following::dd[1]"
  element :country_txt, :xpath, "//div[@id='personalInfo']/div/dl[@class='personal-info-list']/dt[contains(text(),'Country')]/following::dd[1]"
end

class ChangePassword < SitePrism::Section
  element :change_password_title, '.row.raised>h2'
  element :old_password_txt, '#originalPassword'
  element :new_password_txt, '#newPassword'
  element :confirm_password_txt, '#confirmNewPassword'
  element :update_password_btn, :xpath, ".//button[contains(text(), 'Update Password')]"
end

class SavedAddresses < SitePrism::Section
  element :state_opt, '#atg_newAddrState'
  element :first_name_input, '#atg_newAddrFirstName'
  element :last_name_input, '#atg_newAddrLastName'
  element :street_address_input, :xpath, ".//input[@id='atg_addNewAddressLine1']"
  element :street_address_2_input, '#atg_addNewAddressLine2'
  element :city_input, '#atg_newAddrCity'
  element :postal_code_input, '#atg_newAddrPostalCode'
  element :phone_number_input, '#atg_newAddrPhoneNumber'
  element :submit_data_btn, :xpath, ".//*[@id='addNewAddressButton']"
  element :confirm_btn, '#useEnteredAddressSubmit'
  element :default_address_chk, :xpath, ".//*[@id='savedAddresses']//label"
  element :invalid_address_txt, :xpath, ".//*[@id='addNewAddressFormExperia']//strong[contains(text(),'We could not find a valid address matching the information you entered. Please either confirm your address, or update it with correct information.')]"
end

class AddCreditCard < SitePrism::Section
  element :card_number_input, '#creditCardAddForm #vin_PaymentMethod_creditCard_account'
  element :name_on_card_input, '#creditCardAddForm #vin_PaymentMethod_accountHolderName'
  element :expiration_day_month_opt, '#vin_PaymentMethod_creditCard_expirationDate_Month'
  element :expiration_day_year_opt, '#vin_PaymentMethod_creditCard_expirationDate_Year'
  element :security_code_input, '#creditCardAddForm #vin_PaymentMethod_nameValues_cvn'
  element :street_address_input, '#creditCardAddForm  #vin_PaymentMethod_billingAddress_addr1'
  element :street_address_line_2_input, '#creditCardAddForm  #vin_PaymentMethod_billingAddress_addr2'
  element :city_input, '#creditCardAddForm #vin_PaymentMethod_billingAddress_city'
  element :state_opt, '#creditCardAddForm #vin_PaymentMethod_billingAddress_district'
  element :country_opt, '#creditCardAddForm #selFKX'
  element :postal_code_input, '#creditCardAddForm #vin_PaymentMethod_billingAddress_postalCode'
  element :phone_number_input, '#creditCardAddForm #vin_PaymentMethod_billingAddress_phone'
  element :add_credit_card_btn, '#profileCardContinue'
end

class EditPersonalInformation < SitePrism::Section
  element :first_name_input, '#profileFirstName'
  element :last_name_input, '#profileLastName'
  element :email_input, '#profileEmail'
  element :zip_code_input, '#profilePostalCode'
  element :learning_path_optin, :xpath, ".//label[@for='learningPathOptIn']"
  element :leapfrog_optin, :xpath, ".//label[@for='leapFrogOptIn']"
  element :update_btn, :xpath, ".//*[@id='editProfileForm']//button[contains(text(),'Update')]"
end

class MyAccount < SitePrism::Section
  elements :past_orders_tr, :xpath, "//*[@id='pastOrders']//tr[@class='itemDivs']"
  element :first_past_order_number_td, :xpath, "(//*[@id='pastOrders']//tr[@class='itemDivs']/td[@class='orderNumber'])[1]"
  elements :in_process_tr, :xpath, "//tr[@class='itemDivs']" # "//*[@id='myAccount']//*[contains(text(),'In process')]/../*[@class='orderHistoryTable']//tr[@class='itemDivs']"
  element :first_in_progress_order_number_td, :xpath, "(//tr[@class='itemDivs']/td[@class='orderNumber'])[1]" # "(//*[@id='myAccount']//*[contains(text(),'In process')]/../*[@class='orderHistoryTable']//tr[@class='itemDivs']/td[@class='orderNumber'])[1]"
end

class RedeemCode < SitePrism::Section
  element :ui_redeem_input1, "input[name = 'uiRedeemCode1']"
  element :ui_redeem_input2, "input[name = 'uiRedeemCode2']"
  element :ui_redeem_input3, "input[name = 'uiRedeemCode3']"
  element :ui_redeem_input4, "input[name = 'uiRedeemCode4']"
  element :state_cbo, '.redeemForm1 .row.raised select'
  element :redeem_btn, :xpath, ".//*[@class='redeemForm1']//button[contains(text(),'Redeem')]"
end

class RedeemSuccess < SitePrism::Section
  element :close_btn, '.btn.btn-yellow.pull-right'
end

class MyProfileATG < CommonATG
  set_url_matcher(/.*\/profile/)

  section :edit_account_information_form, EditPersonalInformation, '#personalInfo'
  section :personal_info_box, AccountInformation, 'div.row.personal-information'
  section :address_form, SavedAddresses, '#addNewAddress'
  section :add_credit_card_form, AddCreditCard, '#addNewPayment'
  section :my_account_form, MyAccount, '#myAccount'
  section :change_password_box, ChangePassword, '.row.raised'
  section :redeem_code_box, RedeemCode, '.redeemForms'
  section :redeem_success_box, RedeemSuccess, '#valueCodeSuccessMessage'

  element :account_information_link, :xpath, "//*[@id='myAccount']//a[text()='Account Information']"
  element :account_information_link2, :xpath, ".//*[@id='lf.desktop']/body/div[18]/div[2]/div/ul/li[2]/a", visible: false
  element :email_preferences_link, :xpath, "//*[@id='myAccount']//a[text()='Email Preferences']"
  element :saved_addresses_link, :xpath, "//*[@id='myAccount']//a[text()='Saved Addresses']"
  element :save_payments_link, :xpath, "//*[@id='myAccount']//a[text()='Saved Payments']"
  element :add_address_btn, :xpath, ".//div[@id='savedAddresses']//a[contains(text(),'Add Address')]"
  elements :saved_address_txt, :xpath, "//div[@class='saved-address-info']"
  elements :address_lines_confirm, '#addNewAddressFormExperia .dl-horizontal>dd'
  element :saved_address_default_div, :xpath, "//div[@class='saved-address saved-address-default']/div[@class='saved-address-info']"
  elements :all_delete_saved_address_link, :xpath, "//*[@id='savedAddresses']//a[@data-spy='deleteAddress']"
  element :delete_saved_address_link, :xpath, "//*[@id='savedAddresses']//div[1]/a[@data-spy='deleteAddress']"
  element :delete_address_btn, '#confirmDeleteAddress'
  element :add_credit_card_btn, :xpath, ".//div[@id='savedPayments']//a[contains(text(),'Add Credit Card')]"
  element :log_out_btn, '#atg_logoutBtn'
  element :account, '#atg_account'
  element :main_catalog, :xpath, ".//*[@id='header']/div/div/div/div[2]/nav/ul/li[1]/a"
  elements :all_delete_saved_payment_link, :xpath, ".//*[@id='savedPayments']//a[@data-spy='deleteCard']"
  element :delete_saved_payment_link, :xpath, "//*[@id='savedPayments']//div/div/div[1]/div/a[@data-spy='deleteCard']"
  element :delete_payment_btn, '#confirmDeleteCreditCard'
  elements :saved_payments_txt, :xpath, ".//div[@class='saved-card-info']"
  element :edit_account_information_btn, :xpath, ".//*[@id='personalInfo']//a[contains(text(),'Edit')]"
  element :use_addr_as_billing_addr_radio, :xpath, "(//div[@id='divScroll']/input[contains(@id,'savedAddress')])[1]", visible: false
  element :change_password_lnk, '.change-password.pull-left'

  def my_profile_page_exist?
    displayed?
  end

  def get_account_info
    first_name = personal_info_box.has_firstname_txt? ? personal_info_box.firstname_txt.text.strip : ''
    last_name = personal_info_box.has_lastname_txt? ? personal_info_box.lastname_txt.text.strip : ''
    email = personal_info_box.has_email_txt? ? personal_info_box.email_txt.text.strip : ''
    zip_code = personal_info_box.has_zip_code_txt? ? personal_info_box.zip_code_txt.text.strip : ''
    country = personal_info_box.has_country_txt? ? personal_info_box.country_txt.text.strip : ''

    "#{first_name} #{last_name} #{email} #{zip_code} #{country}".gsub(/\s{2,}/, ' ')
  end

  def goto_account_information
    account_information_link.click
  end

  def goto_account_information2
    5.times do
      page.execute_script("$('.ui-popover__container').attr('style', 'opacity: 1; z-index: 1011; top: 41px; left: 506.7px; display: block;')")

      if has_logout_link?(wait: TimeOut::WAIT_MID_CONST)
        visit current_url
        wait_for_ajax
        break
      end

      next
    end
  end

  #
  # Go to Add Address tab on My profile page
  #
  def goto_add_address
    add_address_btn.click
  end

  #
  # Add new address with parameters:
  # (first_name, last_name, street_address, city, state, postal, phone_number)
  #
  def add_new_address(address)
    # open add address information popup
    wait_for_ajax
    add_address_btn.click

    # fill information
    address_form.first_name_input.set address[:first_name]
    address_form.last_name_input.set address[:last_name]
    address_form.street_address_input.set address[:street]
    address_form.city_input.set address[:city]

    page.execute_script("$('#atg_newAddrState').css('display','block')")
    address_form.state_opt.find("option[value='#{address[:state]}']").select_option

    address_form.postal_code_input.set address[:postal]
    address_form.phone_number_input.set address[:phone_number]

    # submit data
    address_form.submit_data_btn.click
  end

  #
  # Return true if Address Confirm popup display when entering bad address
  #
  def address_confirm_popup_displayed?
    return false unless address_form.has_confirm_btn?(wait: TimeOut::WAIT_CONTROL_CONST * 2)
    address_form.confirm_btn.click
    true
  end

  #
  # Get all address information that added to account
  # Return array includes addresses
  #
  def get_address_info
    arr_addr_info = []

    # go through all saved_address_infor div if having more one
    wait_for_saved_address_txt
    saved_address_txt.each do |addr|
      arr_addr_info.push(addr.text)
    end

    arr_addr_info[0]
  end

  #
  # Get all address information that added to account
  # Return array includes addresses
  #
  def get_address_info_on_confirm_page
    arr_addr_info = ''

    # go through all saved_address_infor div if having more one
    wait_for_address_lines_confirm
    address_lines_confirm.each do |addr|
      arr_addr_info << addr.text.strip << ' '
    end

    arr_addr_info.strip
  end

  #
  # Verify 'We could not find a valid address matching the information you entered. Please either confirm your address, or update it with correct information.' message displays
  #
  def invalid_address_message?
    address_form.has_invalid_address_txt?(wait: TimeOut::WAIT_MID_CONST)
  end

  #
  # Delete all addresses
  #
  def delete_all_addresses
    num_link = all_delete_saved_address_link.count
    num_link.times do
      delete_saved_address_link.click
      delete_address_btn.click
    end
  end

  #
  # Delete all payments
  #
  def delete_all_payments
    num_link = all_delete_saved_payment_link.count
    num_link.times do
      delete_saved_payment_link.click
      delete_payment_btn.click
    end
  end

  #
  # Add new credit card into account
  #
  def add_new_credit_card_with_new_billing(credit_card = nil, billing_address = nil)
    # open add credit card popup
    add_credit_card_btn.click

    unless credit_card.nil?
      add_credit_card_form.card_number_input.set credit_card[:card_number]
      add_credit_card_form.name_on_card_input.set credit_card[:card_name]

      page.execute_script("$('#vin_PaymentMethod_creditCard_expirationDate_Month').css('display','block')")
      add_credit_card_form.expiration_day_month_opt.select(credit_card[:exp_month])

      page.execute_script("$('#vin_PaymentMethod_creditCard_expirationDate_Year').css('display','block')")
      add_credit_card_form.expiration_day_year_opt.select(credit_card[:exp_year])

      add_credit_card_form.security_code_input.set credit_card[:security_code]
    end

    # fill billing address
    if billing_address.nil?
      wait_for_use_addr_as_billing_addr_radio(10)
      use_addr_as_billing_addr_radio.click
    else
      add_credit_card_form.street_address_input.set billing_address[:street_address]
      add_credit_card_form.city_input.set billing_address[:city]

      page.execute_script("$('#vin_PaymentMethod_billingAddress_district').css('display','block')")
      add_credit_card_form.state_opt.find("option[value='#{billing_address[:state]}']").select_option

      add_credit_card_form.postal_code_input.set billing_address[:postal_code]
      add_credit_card_form.phone_number_input.set billing_address[:phone_number]
    end

    # submit data
    add_credit_card_form.add_credit_card_btn.click

    # wait for creating data on server
    return false if has_no_add_credit_card_form?(wait: TimeOut::WAIT_BIG_CONST)
  end

  #
  # Get information of payments on my profile page
  # Return string "CARD_TYPE_CONST + ' XXXXXXXXXXXX' + CARD_TYPE_CONST[-4..-1] + ' Exp ' + Date::MONTHNAMES.index(EXP_MONTH_CONST)  + '/' + EXP_YEAR_CONST[-2..-1]"
  #
  def get_payment_info
    arr_pay_info = []

    # Go through all divs that contains payments infor
    saved_payments_txt.each do |saved_payment_txt|
      arr_pay_info.push(saved_payment_txt.text)
    end

    arr_pay_info[0]
  end

  # edit account information
  def edit_account_info(email = nil, first_name = nil, last_name = nil, zip_code = nil)
    edit_account_information_btn.click
    edit_account_information_form.first_name_input.set first_name unless first_name.nil?
    edit_account_information_form.last_name_input.set last_name unless last_name.nil?
    edit_account_information_form.email_input.set email unless email.nil?
    edit_account_information_form.zip_code_input.set zip_code unless zip_code.nil?
    edit_account_information_form.update_btn.click
  end

  def edit_email_preferences(learning_path_optin = 'checked', leapfrog_optin = 'checked')
    edit_account_information_btn.click

    lp_optin = page.evaluate_script("$('#learningPathOptIn').attr('checked')")
    lf_optin = page.evaluate_script("$('#leapFrogOptIn').attr('checked')")

    edit_account_information_form.learning_path_optin.click unless learning_path_optin == lp_optin
    edit_account_information_form.leapfrog_optin.click unless leapfrog_optin == lf_optin

    edit_account_information_form.update_btn.click
  end

  def get_email_preferences
    lp_optin = page.evaluate_script("$('#learningPathOptIn').attr('checked')") == 'checked' ? 'Opt in' : 'Opt out'
    lf_optin = page.evaluate_script("$('#leapFrogOptIn').attr('checked')") == 'checked' ? 'Opt in' : 'Opt out'

    { learning_path_optin: lp_optin, leapfrog_optin: lf_optin }
  end

  def change_password(old_pass, new_pass)
    change_password_lnk.click
    change_password_box.old_password_txt.set old_pass
    change_password_box.new_password_txt.set new_pass
    change_password_box.confirm_password_txt.set new_pass
    change_password_box.update_password_btn.click
  end

  def change_password_box_displays?
    change_password_box.has_change_password_title?(wait: TimeOut::WAIT_BIG_CONST)
  end

  def redeem_code
    env = (Data::ENV_CONST.upcase == 'PROD') ? 'PROD' : 'QA'
    code_type = "#{Data::LOCALE_CONST.upcase}V1"
    if Data::LOCALE_CONST.upcase == 'US'
      state = 'Alaska'
    else # Locale = CA
      state = 'Alberta'
    end

    3.times do
      # Get available PIN
      pin = PinRedemption.get_pin_info(env, code_type, 'Available')

      next if pin.blank?

      pin_number = pin['pin_number']
      redeem_code_box.ui_redeem_input1.set pin_number[0..3]
      redeem_code_box.ui_redeem_input2.set pin_number[5..8]
      redeem_code_box.ui_redeem_input3.set pin_number[10..13]
      redeem_code_box.ui_redeem_input4.set pin_number[15..18]

      # Select state
      page.execute_script("$('.redeemForm1 .row.raised select').css('display','block')")
      redeem_code_box.state_cbo.select state

      # click on Redeem button
      redeem_code_box.redeem_btn.click
      sleep TimeOut::WAIT_MID_CONST

      PinRedemption.update_pin_status(env, code_type, pin_number, 'Used')

      if redeem_success_box.has_close_btn?(wait: TimeOut::WAIT_BIG_CONST)
        redeem_success_box.close_btn.click
        return pin
      end

      next
    end

    {}
  end

  def order_number_exist?(order_id)
    page.has_xpath?(".//*[@id='div_']//a[contains(text(),'#{order_id}')]")
  end
end
