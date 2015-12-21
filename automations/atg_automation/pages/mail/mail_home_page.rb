require 'pages/atg/atg_common_page'

class HomePageMail < CommonATG
  set_url 'https://www.guerrillamail.com/inbox'
#
  # properties
  element :order_comfirmation_td, :xpath, "(//*[@id='email_table']//*[contains(text(),'Your LeapFrog Order') or contains(text(),'Votre commande LeapFrog')])[1]"
  element :registration_td, :xpath, "(//*[@id='email_table']//*[contains(text(),'Welcome to LeapFrog')])[1]"
  element :reset_password_td, :xpath, "(//*[@id='email_table']//*[contains(text(),'How to reset your LeapFrog password')])[1]"
  element :share_wishlist_td, :xpath, "(//*[@id='email_table']//*[contains(text(),'Check out my LeapFrog Wishlist!')])[1]"
  element :edit_email_btn, '#inbox-id'
  element :email_address_input, :xpath, "//*[@id='inbox-id']/input"
  element :set_btn, :xpath, "//*[@id='inbox-id']/button[text()='Set']"

  # methods
  def generate_cus_email(email_address)
    index = email_address.index('@')
    return email_address[0..index - 1] unless index.nil?
    email_address
  end

  def go_to_mail_detail(email_address, type = 0)
    # load page
    load

    # set inbox email
    edit_email_btn.click
    email_address_input.set(generate_cus_email email_address)
    set_btn.click

    # go to detail page
    case type
    when 0 # Open Order confirm email
      order_comfirmation_td.click if has_order_comfirmation_td?(wait: TimeOut::WAIT_EMAIL)
    when 1 # Open Account Registration email
      registration_td.click if has_registration_td?(wait: TimeOut::WAIT_EMAIL)
    when 2 # Open Account Reset Password email
      reset_password_td.click if has_reset_password_td?(wait: TimeOut::WAIT_EMAIL)
    when 3 # Open Share This Wishlist email
      share_wishlist_td.click if has_share_wishlist_td?(wait: TimeOut::WAIT_EMAIL)
    end

    # ensure that detail page is loaded
    mail_detail = DetailPageMail.new
    mail_detail.wait_for_back_to_inbox_link(TimeOut::WAIT_MID_CONST)

    DetailPageMail.new
  end
end
