require 'pages/atg/atg_common_page'
require 'lib/const'

class DetailPageMail < CommonATG
  element :order_number_txt, :xpath, "//*[@id='display_email']//*[contains(text(),'N° DE COMMANDE') or contains(text(),'ORDER NUMBER')]"
  element :order_total_txt, :xpath, ".//td/b[contains(text(),'Purchase Total') or contains(text(),'Total achats')]/../.."
  element :order_sub_total_txt, :xpath, "//*[@id='display_email']//*[contains(text(),'Sous-total') or contains(text(),'Order subtotal')]/.."
  element :account_balance_txt, :xpath, "(.//td[contains(text(),'Account Balance') or contains(text(),'Solde du compte')])[1]/.."
  element :tax_txt, :xpath, "(.//td[contains(text(),'Tax')])[1]/.."
  element :shipping_detail_txt, :xpath, "//*[@id='display_email']//*[contains(text(),'Purchase Total')]/../../../../../.."
  element :payment_method_txt, :xpath, "//*[@id='display_email']//*[contains(text(),'Payment Method')]/../../../tr[2]"
  element :shipping_method_txt, :xpath, "//*[@id='display_email']//*[contains(text(),'Shipping Method')]/../../../tr[2]"
  element :bill_to_txt, :xpath, ".//*[@id='display_email']/div[@class='email_page']/div[2]/div/table[3]/tbody/tr/td[3]"
  element :email_subject_txt, :xpath, ".//*[@id='display_email']//div[@class='email']/p"
  element :registration_success_txt, :xpath, ".//*[@id='display_email']//table/tbody/tr[2]/td/p[1]"
  element :email_subject_account_update_txt, :xpath, ".//*[@id='display_email']//div[@class='email']/p"
  element :update_success_txt, :xpath, ".//*[@id='display_email']//table/tbody//tr[5]//table/tbody/tr/td/p[1]"
  element :back_to_inbox_link, '#back_to_inbox_link'
  element :temp_password_txt, :xpath, ".//b[contains(text(),'Temporary password:')]/.."

  # from csc
  element :csc_order_number_txt, :xpath, "//*[@id='display_email']//*[contains(text(),'The confirmation number for your order is')]"
  element :csc_prod_detail_tbl, :xpath, "(.//*[@id='display_email']//table)[1]"
  element :csc_shipping_detail_tbl, :xpath, "(.//*[@id='display_email']//div[@class='email_body']/div)[1]"
  element :csc_billing_detail_tbl, :xpath, "(.//*[@id='display_email']//div[@class='email_body']/div)[2]"
  element :csc_subject_order_txt, :xpath, "(.//*[@id='display_email']//h3)[1]"

  #
  # return information in response email
  #
  def get_order_information_from_csc
    {
      id: csc_order_number_txt.text,
      prod_detail: csc_prod_detail_tbl.text,
      shipping_detail: csc_shipping_detail_tbl.text,
      billing_detail: csc_billing_detail_tbl.text,
      subject: csc_subject_order_txt.text
    }
  end

  def get_temp_password
    has_temp_password_txt?(wait: TimeOut::WAIT_MID_CONST) ? temp_password_txt.text.split('Temporary password:')[1].strip : ''
  end

  def get_shared_wishlist_info
    wishlist_arr = []

    # get element
    if page.has_css?('.email_body')
      str = page.evaluate_script("$('.email_body').html();")
    else
      return wishlist_arr
    end

    # convert string element to html element
    html_doc = Nokogiri::HTML(str)

    # get all information of product
    html_doc.css('table>tbody>tr>td').each do |el|
      id = el.css('p>a>@href').to_s
      prod_id = id.blank? ? '' : id.split('/')[-1].gsub('A-', '')
      title = el.css('strong').text.delete("\n")

      # Put all info into array
      wishlist_arr.push(prod_id: prod_id, title: title)
    end

    wishlist_arr.reject! { |c| c[:prod_id].empty? }.uniq
  end

  def order_number
    order_number_txt.text
  end

  def order_sub_total
    order_sub_total_txt.text
  end

  def payment_method
    payment_method_txt.text.gsub(/\s/, '')
  end

  def order_email_info
    account_balance = has_account_balance_txt?(wait: TimeOut::WAIT_MID_CONST) ? account_balance_txt.text.strip : ''
    tax = has_tax_txt?(wait: TimeOut::WAIT_MID_CONST) ? tax_txt.text.strip : ''
    {
      order_number: order_number_txt.text.strip,
      order_sub_total: order_sub_total_txt.text.strip,
      account_balance: account_balance,
      tax: tax,
      order_total: order_total_txt.text.strip
    }
  end

  def bill_to_info
    bill_to_txt.text
  end
end
