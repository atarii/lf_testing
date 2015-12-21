require 'pages/atg/atg_common_page'
require 'pages/atg/atg_checkout_confirmation_page'

class ReviewATG < CommonATG
  set_url_matcher(%r{.*\/checkout\/review})

  element :place_order_btn, :xpath, "//*[@id='commitOrder']/input[@type='submit']"
  element :error_message, :xpath, "//*[@id='errorMessage']/div/div"
  element :sale_tax_txt, :xpath, ".//div[contains(text(), 'Sales Tax')]/../div[@class='cartRight']"
  element :account_name_txt, :xpath, ".//*[@id='shippingAndBilling']//p[2]"
  element :street_txt, :xpath, ".//*[@id='shippingAndBilling']//p[3]"
  element :address_txt, :xpath, ".//*[@id='shippingAndBilling']//p[4]"
  element :email_txt, :xpath, ".//*[@id='shippingAndBilling']//p[6]"
  element :account_balance_txt, :xpath, "//*[@id='orderSummary']//div[@class='price-type text-success']/div[@class='cartRight']"

  def review_page_exist?(wait_time = TimeOut::WAIT_BIG_CONST)
    displayed?(wait_time)
  end

  # Click on Place Order button
  def place_order
    wait_for_place_order_btn
    place_order_btn.click

    return error_message.text if has_error_message?(wait: 5)
    ConfirmationATG.new
  end

  # get sale tax
  def get_sale_tax
    wait_for_ajax
    '%.2f' % sale_tax_txt.text.gsub(/[CAD,$]/, '').to_f
  end

  # get bill to information
  def get_bill_to_info
    has_account_name_txt? ? acc_name = account_name_txt.text : acc_name = ''
    has_street_txt? ? street = street_txt.text : street = ''
    has_address_txt? ? address = address_txt.text : address = ''
    has_email_txt? ? email = email_txt.text : email = ''

    "#{acc_name} #{street} #{address} #{email}"
  end

  # get account balance info on Review page
  def get_account_balance
    has_account_balance_txt? ? account_balance_txt.text.gsub('– $', '') : ''
  end
end
