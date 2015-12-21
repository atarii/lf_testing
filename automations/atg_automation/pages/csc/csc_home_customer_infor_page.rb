require 'pages/csc/csc_common_page'

class CustomerInformationCreateAccount < SitePrism::Section
  element :firstname_input, '#cpFirstName'
  element :lastname_input, '#cpLastName'
  element :country_opt, '#customerCreatePanelContent select'
  element :email_input, '#cpEmail'
  element :login_input, '#cpLogin'
  element :create_account_chk, ".atg_commerce_csr_createAccount>input[type='checkbox']"
  element :save_btn, '#update'
end

class AddNewAddress < SitePrism::Section
  element :firstname_input, '#profileAddressEditorForm_lastName'
  element :lastname_input, '#profileAddressEditorForm_lastName'
  element :country_input, '#profileAddressEditorForm_country'
  element :address_input, '#profileAddressEditorForm_address1'
  element :city_input, '#profileAddressEditorForm_city'
  element :state_input, '#profileAddressEditorForm_state'
  element :zip_input, '#profileAddressEditorForm_postalCode'
  element :phone_input, '#profileAddressEditorForm_phoneNumber'
  element :default_billing_chk, :xpath, "(.//*[@id='profileAddressEditorForm']//input[@type='checkbox'])[1]"
  element :default_shipping_chk, :xpath, "(.//*[@id='profileAddressEditorForm']//input[@type='checkbox'])[2]"
  element :save_btn, :xpath, "(.//*[@id='profileAddressEditorForm']//input[@type='button'])[1]"
end

class CustomerInformation < SitePrism::Section
  element :first_name_txt, :xpath, "//*[@class='atg_svc_addressForm customerInfo']//*[contains(text(),'First Name:')]/../../span[2]"
  element :last_name_txt, :xpath, "//*[@class='atg_svc_addressForm customerInfo']//*[contains(text(),'Last Name:')]/../../span[2]"
  element :email_address_txt, :xpath, "//*[@class='atg_svc_addressForm customerInfo']//*[contains(text(),'Email Address:')]/../../span[2]"
  element :login_txt, :xpath, "//*[@class='atg_svc_addressForm customerInfo']//*[contains(text(),'Login:')]/../../span[2]"
  element :addresses_txt, :xpath, "//*[@id='atg_commerce_csr_customerinfo_addresses']/../../../..//*[@class='atg_svc_shipAddress']"
  element :credit_cards_txt, :xpath, "//*[@id='atg_commerce_csr_customerinfo_paymentMethods']/../../../..//*[@class='atg_svc_addressWrapper']"

  # for adding address and credit card
  element :add_new_address_lnk, :xpath, ".//*[@id='customerCreateForm']//a[contains(text(),'Add New Address')]"
  element :add_new_credit_lnk, :xpath, ".//*[@id='customerCreateForm']//a[contains(text(),'Add new credit')]"
end

class HomeCustomerInforCSC < CommonCSC
  # PROPERTIES
  section :customer_info, CustomerInformation, '#customerInformationPanelContent'
  section :cus_create_form, CustomerInformationCreateAccount, '#customerCreatePanelContent'
  section :add_new_address_popup, AddNewAddress, '#addressPopup'
  #
  # METHODS
  #
  # Create new customer
  #
  def create_new_customer(firstname, lastname, country, email, loginname)
    customer_nav_lnk.click
    wait_for_ajax
    cus_create_form.firstname_input.set firstname
    cus_create_form.lastname_input.set lastname
    cus_create_form.country_opt.select(country)
    cus_create_form.email_input.set email
    cus_create_form.login_input.set loginname
    cus_create_form.create_account_chk.set true
    cus_create_form.save_btn.click
    wait_for_ajax
  end

  #
  # add new address
  #
  def add_new_address(firstname = 'LTRC', lastname = 'DN', country = 'United States', address = '217 2nd St', city = 'Juneau', state = 'AK - Alaska', zip = '99801-1267', phone = '0123456789', billing = true, shipping = true)
    # open address popup
    customer_info.add_new_address_lnk.click

    # fill information
    add_new_address_popup.firstname_input.set firstname
    add_new_address_popup.lastname_input.set lastname
    add_new_address_popup.country_input.set country
    add_new_address_popup.address_input.set address
    add_new_address_popup.city_input.set city
    add_new_address_popup.state_input.set state
    add_new_address_popup.zip_input.set zip
    add_new_address_popup.phone_input.set phone

    # make default billing, shipping or not
    add_new_address_popup.default_billing_chk.set true if billing == true
    add_new_address_popup.default_shipping_chk.set true if shipping == true

    # submit information
    add_new_address_popup.save_btn.click
    wait_for_ajax
  end
end
