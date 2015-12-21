require File.expand_path('../../spec/spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'
require 'atg_app_center_page'
require 'atg_product_detail_page'
require 'atg_checkout_page'
require 'atg_wishlist_page'

def create_account_and_link_all_devices(first_name, last_name, full_email, password, confirm_password)
  atg_home_page = HomeATG.new
  atg_register_page = nil
  atg_my_profile_page = nil
  caller_id = ServicesInfo::CONST_CALLER_ID

  scenario '1. Go to register/login page' do
    atg_register_page = atg_home_page.goto_login
    pending "***1. Go to register/login page (URL: #{atg_register_page.current_url})"
  end

  scenario "2. Register a new account with full information (Email: #{full_email})" do
    atg_my_profile_page = atg_register_page.register first_name, last_name, full_email, password, confirm_password
  end

  scenario '3. Verify My Profile page displays' do
    expect(atg_my_profile_page.my_profile_page_exist?).to eq(true)
  end

  scenario '4. Link account to all devices' do
    flatform_devices = { LeapPad: 'leappad', Val: 'leappad2', Cabo: 'leappad3', LeapterExplore: 'emerald', LeapterGS: 'explorer2', LeapReader: 'leapreader', Narnia: 'android1', Glasgow: 'leapup' }

    search_res = CustomerManagement.search_for_customer caller_id, full_email
    cus_id = search_res.xpath('//customer/@id').text

    session_res = AuthenticationService.acquire_service_session caller_id, full_email, password
    session = session_res.xpath('//session').text

    register_child_res = ChildManagementService.register_child caller_id, session, cus_id
    child_id = register_child_res.xpath('//child/@id').text

    claim_all_devices caller_id, session, cus_id, child_id, flatform_devices

    xml_res = DeviceManagementService.list_nominated_devices caller_id, session, 'service'
    device_number = xml_res.xpath('//device').count
    expect(device_number).to eq(8)
  end
end

def check_status_url_and_print_session(atg_home_page, status_code = '200')
  before :each do
    skip "Pre-condition fails (Could not reach page #{URL::ATG_APP_CENTER_URL})" unless status_code == '200'
  end

  context 'Print Session ID' do
    cookie_session_id = ''

    scenario "Go to App Center home page #{URL::ATG_APP_CENTER_URL}" do
      status_code = LFCommon.get_http_code URL::ATG_APP_CENTER_URL
      fail "Could not reach page #{URL::ATG_APP_CENTER_URL}" unless status_code == '200'
      cookie_session_id = atg_home_page.load
    end

    scenario 'SESSION_ID' do
      pending "***SESSION_ID: #{cookie_session_id}"
    end
  end
end

def claim_all_devices(caller_id, session, cus_id, child_id, flatform_devices)
  flatform_devices.each do |key, value|
    device_serial = key.to_s + DeviceManagementService.generate_serial
    OwnerManagementService.claim_device caller_id, session, device_serial, value, '0', key.to_s, child_id
    DeviceProfileManagementService.assign_device_profile caller_id, cus_id, device_serial, value, '0', key.to_s, child_id
  end
end

def update_info_account(email, address = nil, credit_number = nil)
  sql_string = "address1='#{address}'," if address
  sql_string = "credit_number='#{credit_number}', exp_month='#{CreditInfo::EXPIRED_MONTH_CONST}', exp_year=#{CreditInfo::EXPIRED_YEAR_CONST}," if credit_number

  Connection.my_sql_connection(
    <<-INTERPOLATED_SQL
      UPDATE atg_tracking
      SET #{sql_string} updated_at='#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}'
      WHERE email='#{email}';
    INTERPOLATED_SQL
  )
end
