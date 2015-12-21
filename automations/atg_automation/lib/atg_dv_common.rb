require File.expand_path('../../spec/spec_helper', __FILE__)
require 'atg_checkout_payment_page'
require 'atg_dv_check_out_payment_page'
require 'atg_dv_check_out_review_page'
require 'mail_detail_page'

def dv_check_out_method(email, payment_method, device_store)
  env = Data::ENV_CONST.upcase == 'PROD' ? 'PROD' : 'QA'
  atg_dv_payment_page = AtgDvCheckOutPaymentPage.new
  review_page = AtgDvCheckOutReviewPage.new

  credit_card = Data::CREDIT_CARD
  billing_address = Data::ADDRESS
  billing_address[:state] = 'AK'

  case payment_method
  when 'Credit Card'
    scenario '7. Check out with Credit Card' do
      if device_store.include? 'LFC'
        PaymentATG.new.add_credit_card(credit_card, billing_address)
      else
        # Add new Credit Card
        atg_dv_payment_page.dv_add_credit_card(credit_card, billing_address)

        # Select the added Credit Card
        atg_dv_payment_page.dv_select_credit_card
      end

      update_info_account(email, billing_address[:street], credit_card[:card_number])
    end
  when 'Account Balance'
    scenario '7. Check out with Redeem Code' do
      code_type = atg_dv_payment_page.dv_code_type_by_locale
      atg_dv_payment_page.dv_redeem_code(env, code_type, device_store, 3)
    end
  else # Credit Card + Account Balance
    scenario '7. Check out with Credit Card + Account Balance' do
      # Add new Credit Card
      atg_dv_payment_page.dv_add_credit_card(credit_card, billing_address)

      # Redeem Code
      code_type = atg_dv_payment_page.dv_code_type_by_locale
      atg_dv_payment_page.dv_redeem_code(env, code_type, device_store)

      # If Account Balance is not enough -> Pay with Credit Card + Account Balance
      atg_dv_payment_page.dv_select_credit_card unless review_page.has_btn_device_place_order?(wait: TimeOut::WAIT_MID_CONST * 2)

      update_info_account(email, billing_address[:street], credit_card[:card_number])
    end
  end
end

def create_account_via_webservice(caller_id, first_name, last_name, email, password, location)
  scenario "1. Register new account (Email:#{email})" do
    CustomerManagement.register_customer(caller_id, first_name, last_name, email, email, password, location)
    Connection.my_sql_connection("INSERT INTO atg_tracking(firstname, lastname, email, country, created_at, updated_at) VALUES (\'#{first_name}\',\'#{last_name}\',\'#{email}\',\'#{location}\',\'#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\', \'#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\');")
  end

  scenario '2. Link account to all devices' do
    device_platforms = { LeapPad: 'leappad', Val: 'leappad2', Cabo: 'leappad3', LeapterExplore: 'emerald', LeapterGS: 'explorer2', LeapReader: 'leapreader', Narnia: 'android1', Glasgow: 'leapup' }

    search_res = CustomerManagement.search_for_customer caller_id, email
    cus_id = search_res.xpath('//customer/@id').text

    session_res = AuthenticationService.acquire_service_session caller_id, email, password
    session = session_res.xpath('//session').text

    register_child_res = ChildManagementService.register_child caller_id, session, cus_id
    child_id = register_child_res.xpath('//child/@id').text

    claim_all_devices caller_id, session, cus_id, child_id, device_platforms
  end
end

def dv_record_order_id(email, order_id)
  temp_id = ''
  rs = Connection.my_sql_connection "select order_id from atg_tracking where email = '#{email}'"

  rs.each_hash do |row|
    if row['order_id'].nil?
      temp_id = order_id
    else
      temp_id = row['order_id'] + ', ' + order_id
    end
  end

  Connection.my_sql_connection "update atg_tracking set order_id = '#{temp_id}', updated_at = '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}' where email = '#{email}'"
end

def device_support_payment_method?(device_store, payment_method)
  support_list = [
    ['LFC English', 'Credit Card'],
    ['LFC English', 'Account Balance'],
    ['LFC French', 'Account Balance'],
    ['LeapPad3 EN', 'Credit Card'],
    ['LeapPad3 EN', 'Account Balance'],
    ['LeapPad3 EN', 'CC + Balance'],
    ['LeapPad3 FR', 'Account Balance'],
    ['LeapPad Ultra', 'Credit Card'],
    ['LeapPad Ultra', 'Account Balance'],
    ['LeapPad Ultra', 'CC + Balance'],
    ['LeapPad Platinum', 'Credit Card'],
    ['LeapPad Platinum', 'Account Balance'],
    ['LeapPad Platinum', 'CC + Balance'],
    ['Narnia', 'Credit Card'],
    ['Narnia', 'Account Balance'],
    ['Narnia', 'CC + Balance']
  ]

  return true if support_list.include?([device_store, payment_method])

  skip "BLOCKED: The #{device_store} does not support for #{payment_method} payment method"
  false
end
