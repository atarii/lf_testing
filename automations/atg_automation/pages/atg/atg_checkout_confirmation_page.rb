require 'pages/atg/atg_common_page'

class ConfirmationCreateAccount < SitePrism::Section
  element :cf_firstname_input, '#atg_newAccountFirstName'
  element :cf_lastname_input, '#atg_newAccountLastName'
  element :cf_password_input, '#atg_newAccountPassword'
  element :cf_confirm_pass_input, '#atg_newAccountConfirmPassword'
  element :cf_new_account_chk, :xpath, "//*[@id='atg_newAccountOptIn']/../label", visible: false
  element :cf_create_account_btn, '#createAccount'
end

class ConfirmationATG < CommonATG
  section :confirm_create_account_form, ConfirmationCreateAccount, '#createAccountForm'

  element :account_created_successfully_popup, '#atg_guestAccountCreateSuccess'
  element :close_popup_btn, :xpath, ".//*[@id='atg_guestAccountCreateSuccess']/a"
  element :order_complete_txt, '.row.raised.gold-border.text-center'
  element :order_details_txt, '#orderDetails'
  element :order_summary_txt, '#orderSummary'
  element :order_confirmation_number_txt, :xpath, "//*[contains(text(),'Your order confirmation number is')]"
  element :order_total_cost_txt, :xpath, "//*[@id='orderDetails']//*[contains(text(),'Order Total')]"
  element :account_balance_txt, '.price-type-bigger.text-success .cartRight'
  elements :cart_right_txt, '.price-type-bigger .cartRight'
  elements :order_item_txt, :xpath, "//*[@id='orderDetails']//tbody/tr"
  element :sale_tax_txt, :xpath, ".//div[contains(text(), 'Sales Tax')]/../div[@class='cartRight']"
  element :payment_method_credit, :xpath, ".//p[contains(text(), 'Visa')]"
  element :payment_method_account_balance, :xpath, ".//p[contains(text(), 'Account Balance')]"
  element :order_subtotal, '.price-type-bigger.orderSubTotalCart .cartRight'

  # Return true if confirm new account checkbox is checked
  def confirmation_new_account_opt_in_checked?
    # click on check box to check status
    wait_for_ajax
    confirm_create_account_form.cf_new_account_chk.click
    wait_for_ajax
    confirm_create_account_form.cf_new_account_chk.click
    wait_for_ajax
    confirm_create_account_form.cf_new_account_chk['class'].include?('checked')
  end

  # Create account on confirmation tab
  def create_account(firstname, lastname, password, cfpassword)
    confirm_create_account_form.cf_firstname_input.set firstname
    confirm_create_account_form.cf_lastname_input.set lastname
    confirm_create_account_form.cf_password_input.set password
    confirm_create_account_form.cf_confirm_pass_input.set cfpassword
    confirm_create_account_form.cf_create_account_btn.click
    sleep TimeOut::WAIT_CONTROL_CONST
  end

  # Return true if created successfull popup is displayed
  def account_created_successfully_displayed?
    return false unless has_account_created_successfully_popup?
    close_popup_btn.click
    true
  end

  def id_transaction_displayed?
    order_confirmation_number_txt.text.include?('Your order confirmation number is lfo')
  end

  def get_order_complete_message
    order_complete_txt.text
  end

  #
  # this function will update record id of an email to atg_tracking table
  #
  def record_order_id(email)
    order_number_message = order_confirmation_number_txt.text
    order_id = ''
    if Data::ENV_CONST == 'PROD'
      idx = order_number_message.index 'lfop'
    else
      idx = order_number_message.index 'lfou'
    end

    order_id = order_number_message[idx..-1].delete('.').strip if idx

    # Update Order ID to tracking table
    query = "select * from atg_tracking where email = '#{email}'"
    rs_select_email = Connection.my_sql_connection query

    if rs_select_email.num_rows == 0
      query = "insert into atg_tracking(firstname, lastname, email, country, order_id, created_at, updated_at) values ('#{Data::FIRSTNAME_CONST}', '#{Data::LASTNAME_CONST}', '#{email}', '#{Data::COUNTRY_CONST}', '#{order_id}', \'#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\', \'#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\')"
    else
      rs_select_order_id = Connection.my_sql_connection "select order_id from atg_tracking where email = '#{email}'"
      temp = ''
      rs_select_order_id.each_hash do |row|
        if row['order_id'].nil?
          temp = order_id
        else
          temp = row['order_id'] + ', ' + order_id
        end

        break
      end

      query = "update atg_tracking set order_id = '#{temp}', updated_at = \'#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\' where email = '#{email}'"
    end

    Connection.my_sql_connection query
  end

  #
  # this will return order id after checkout successfully
  # return error message if checkout unsuccessfully
  #
  def get_order_id
    order_number_message = order_confirmation_number_txt.text

    if Data::ENV_CONST == 'PROD' # production
      idx = order_number_message.index('lfop')
    else
      idx = order_number_message.index('lfou')
    end

    return order_number_message[idx..-1].delete('.').strip if idx

    "Cannot get Order Id, please recheck. Actual message: #{order_number_message}"
  end

  #
  # get sale tax
  #
  def get_sale_tax
    wait_for_ajax
    sale_tax_txt.text
  end

  #
  # Get order overview information
  #
  def get_order_overview_info
    summary = ''
    summary = order_summary_txt.text if has_order_summary_txt?

    {
      complete: order_complete_txt.text,
      details: order_details_txt.text,
      summary: summary
    }
  end

  #
  # calculate order total on order details
  # return value
  def calculate_order_total
    total = 0.00
    cart_right_txt.each do |crv|
      total += crv.text.gsub(/[$,CAD]/, '').tr('(', '-').tr(')', '').gsub(/\s+/, '').tr('–', '-').to_f
    end

    '%.2f' % total.round(2)
  end

  def cal_total_price(price)
    '%.2f' % price.split('$')[-1].strip
  end

  def get_account_balance
    has_account_balance_txt? ? account_balance_txt.text.strip.delete('()') : ''
  end

  def order_total
    order_total_cost_txt.text
  end

  def sale_tax
    sale_tax_txt.text
  end

  def sub_total
    order_subtotal.text
  end

  def payment_method?(method)
    page.has_xpath?(".//p[contains(text(), '#{method}')]")
  end
end
