require File.expand_path('../../spec_helper', __FILE__)
require 'customer_management'
require 'device_management'
require 'pages/glasgow/glasgow_page'

=begin
Glasgow: Bug TTPRO_36030: Verify only allow to create 5 profiles
=end

start_browser

describe 'TTPRO 36030 - Verify only allow to create 5 profiles' do
  platform = 'leapup'
  screen_name = CustomerManagement.generate_screenname
  username = email = LFCommon.generate_email
  password = '123456'
  pin = '3333'
  device_serial = DeviceManagement.generate_serial
  device_registration_url = GLASGOW::CONST_GLASGOW_URL
  profile_arr = nil
  register_status = true

  context 'Pre-condition - Create child profile' do
    glasgow_page = GlasGowPage.new
    act_code = nil

    before :each do
      skip "Pre-condition fails (Error while submitting device serial: #{device_serial})" unless register_status
    end

    it "1. Register device (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      DeviceManagement.register_device(Misc::CONST_CALLER_ID, device_serial, platform)
    end

    it "2. Get device activation code (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      fet_dev_act_res = DeviceManagement.fetch_device_activation_code(Misc::CONST_CALLER_ID, device_serial)
      act_code = fet_dev_act_res.xpath('//activation-code').text
    end

    it "3. Register Customer (URL: #{LFWSDL::CONST_CUSTOMER_MGT})" do
      CustomerManagement.register_customer(Misc::CONST_CALLER_ID, screen_name, username, email)
    end

    it "4. Go to Device Registration page (URL: #{device_registration_url})" do
      glasgow_page.load(device_registration_url)
    end

    it '5. Submit device serial' do
      register_status = glasgow_page.register_device(device_serial)
      fail "Error while submitting device serial: #{device_serial}" unless register_status
      pending "*** 5. Submit device serial: (Serial number: #{device_serial})"
    end

    it '6. Submit device activation code' do
      glasgow_page.submit_act_code act_code
      pending "*** 6. Submit device activation code (Act code: #{act_code})"
    end

    it '7. Login account' do
      glasgow_page.login_account(username, password)
      pending "*** 7. Login account (Username: #{username} - Password: #{password})"
    end

    it '8. Create parent PIN' do
      glasgow_page.create_parent_pin pin
      pending "*** 8. Create parent PIN (PIN: #{pin})"
    end

    it '9. Create 5 child profiles' do
      url = glasgow_page.current_url
      profile_arr = glasgow_page.create_maximum_child_profile
      pending "*** 9. Create 5 child profiles (URL: #{url})"
    end
  end

  context 'Verify only allow to create 5 profiles' do
    fetch_dev_res = nil
    fetch_dev_info_arr = nil

    before :each do
      skip "Pre-condition fails (Error while submitting device serial: #{device_serial})" unless register_status
    end

    it "Fetch device info (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      fetch_dev_res = DeviceManagement.fetch_device(Misc::CONST_CALLER_ID, device_serial, platform)
      fetch_dev_info_arr = DeviceManagement.get_children_node_values(fetch_dev_res, '//device/profile')
    end

    it 'Verify the number of profiles is 5' do
      expect(fetch_dev_res.xpath('//device/profile').count).to eq(5)
    end

    it 'Verify child profiles are created correctly' do
      expect(fetch_dev_info_arr).to match_array(profile_arr)
    end
  end
end
