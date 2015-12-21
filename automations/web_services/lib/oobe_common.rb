require File.expand_path('../../spec/spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'device_profile_management'
require 'pin_management'
require 'device_log_upload'
require 'license_management'
require 'package_management'

def web_services_smoke_test(e_child_name, device_name, platform, package_id = '')
  # Customer info variable
  caller_id = Misc::CONST_REST_CALLER_ID
  device_serial = device_name + DeviceManagement.generate_serial
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  update_username = update_email = 'up_' + email
  password = '123456'
  new_password = hint = LFCommon.generate_password
  customer_id, session, child_id = nil

  # Device/content upload log variable
  filename = 'Stretchy monkey.log'
  content_path = "#{Misc::CONST_PROJECT_PATH}/data/Log2.xml"

  context '1. Register customer' do
    customer_info = nil

    before :all do
      register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
      customer_info = CustomerManagement.get_customer_info(register_cus_res)
      customer_id = customer_info[:id]
    end

    it "Match content of [@username] - #{username}" do
      expect(customer_info[:username]).to eq(username)
    end

    it "Match content of [@password] - #{password}" do
      expect(customer_info[:password]).to eq(password)
    end

    it 'Match content of [@last-name] - Tester' do
      expect(customer_info[:last_name]).to eq('Tester')
    end

    it 'Match content of [@first-name] - LTRC' do
      expect(customer_info[:first_name]).to eq('LTRC')
    end
  end

  context '2. Fetch customer' do
    fetch_cus_res = nil

    before :all do
      fetch_cus_res = CustomerManagement.fetch_customer(caller_id, customer_id)
    end

    it "Match content of [@username] - #{username}" do
      expect(fetch_cus_res.xpath('//customer/credentials/@username').text).to eq(username)
    end

    it 'Match content of [@last-name] - Tester' do
      expect(fetch_cus_res.xpath('//customer/@last-name').text).to eq('Tester')
    end

    it 'Match content of [@first-name] - LTRC' do
      expect(fetch_cus_res.xpath('//customer/@first-name').text).to eq('LTRC')
    end
  end

  context '3. Update customer information' do
    fetch_cus_res = nil

    before :all do
      CustomerManagement.update_customer(caller_id, customer_id, update_username, update_email, password, '')
      fetch_cus_res = CustomerManagement.fetch_customer(caller_id, customer_id)

      # Ensure DB refresh in 5 seconds
      (1..5).each do
        break if fetch_cus_res.xpath('//customer/credentials/@username').text == update_username
        sleep 1
        fetch_cus_res = CustomerManagement.fetch_customer(caller_id, customer_id)
      end
    end

    it "Match content of [@username] - #{update_username}" do
      expect(fetch_cus_res.xpath('//customer/credentials/@username').text).to eq(update_username)
    end

    it 'Match content of [@last-name] - uTester' do
      expect(fetch_cus_res.xpath('//customer/@last-name').text).to eq('uTester')
    end

    it 'Match content of [@first-name] - uLTRC' do
      expect(fetch_cus_res.xpath('//customer/@first-name').text).to eq('uLTRC')
    end
  end

  context '4. Change password' do
    acquire_session_res1, acquire_session_res2 = nil

    before :all do
      CustomerManagement.change_password(caller_id, customer_id, update_username, password, new_password, hint)
      acquire_session_res1 = Authentication.acquire_service_session(caller_id, update_username, password)

      (1..5).each do
        break if acquire_session_res1.include? 'incorrect'
        sleep 1
        CustomerManagement.change_password(caller_id, customer_id, update_username, password, new_password, hint)
        acquire_session_res1 = Authentication.acquire_service_session(caller_id, update_username, password)
      end

      acquire_session_res2 = Authentication.acquire_service_session(caller_id, update_username, new_password)
    end

    it "Verify user is unable to login with old password - #{password}" do
      expect(acquire_session_res1).to eq(ErrorMessageConst::INVALID_PASSWORD_MESSAGE)
    end

    it "Verify user is able to login with new password - #{new_password}" do
      expect(acquire_session_res2.xpath('//session').text).not_to be_empty
    end
  end

  context '5. Register child' do
    child_id, a_child_name, child_grade, child_gender, child_num = nil

    before :all do
      # Register child
      session = Authentication.get_service_session(caller_id, update_username, new_password)
      reg_child_res = ChildManagement.register_child_smoketest(caller_id, session, customer_id, e_child_name, 'male', '3')
      child_id = reg_child_res.xpath('//child/@id').text
      a_child_name = reg_child_res.xpath('//child/@name').text
      child_grade = reg_child_res.xpath('//child/@grade').text
      child_gender = reg_child_res.xpath('//child/@gender').text

      # List chile info of customer
      list_child_res = ChildManagement.list_children(caller_id, session, customer_id)
      child_num = list_child_res.xpath('//child').count
    end

    it 'Match content of [@childID]' do
      pending "***Match content of [@childID]: #{child_id}"
      expect(child_id).not_to be_empty
    end

    it "Match content of [@Name] - #{e_child_name}" do
      expect(a_child_name).to eq(e_child_name)
    end

    it 'Match content of [@Grade] - 3' do
      expect(child_grade).to eq('3')
    end

    it 'Match content of [@Gender] - male' do
      expect(child_gender).to eq('male')
    end

    it 'Verify the child number of customer - 1' do
      expect(child_num).to eq(1)
    end
  end

  context '6. Claim device profile' do
    serial, platform_res, activated_by, is_claimed = nil

    before :all do
      # Claim device
      OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, platform, '0', 'RioKid', child_id)

      # Assign device profile
      DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, platform, '0', 'RioKid', child_id)

      # listNominatedDevices and get device serials value
      list_res = DeviceManagement.list_nominated_devices(caller_id, session, 'service')
      serial = list_res.xpath('//device/@serial').text
      activated_by = list_res.xpath('//device/@activated-by').text
      platform_res = list_res.xpath('//device/@platform').text
      is_claimed = list_res.xpath('//device/profile/@claimed').text
    end

    it "Match content of [@serial] - #{device_serial}" do
      expect(serial).to eq(device_serial)
    end

    it "Match content of [@activated-by] - #{customer_id}" do
      pending "***Match content of [@activated-by] - #{customer_id}"
      expect(activated_by).to eq(customer_id)
    end

    it "Match content of [@platform] - #{platform}" do
      expect(platform_res).to eq(platform)
    end

    it 'Match content of [@claimed] - true' do
      expect(is_claimed).to eq('true')
    end
  end

  context '7. Update device profile and Fetch device information' do
    fetch_device_res = nil

    before :all do
      # Update device profile
      DeviceManagement.update_profiles(caller_id, session, 'service', device_serial, platform, '0', 'AlternateKid', child_id, '5', 'male')
      fetch_device_res = DeviceManagement.fetch_device(caller_id, device_serial, platform)
    end

    it "Match content of [@serial] - #{device_serial}" do
      expect(fetch_device_res.xpath('//device/@serial').text).to eq(device_serial)
    end

    it "Match content of [@platform] - #{platform}" do
      expect(fetch_device_res.xpath('//device/@platform').text).to eq(platform)
    end

    it 'Match content of [@slot] - 0' do
      expect(fetch_device_res.xpath('//device/profile/@slot').text).to eq('0')
    end

    it 'Match content of [@name] - AlternateKid' do
      expect(fetch_device_res.xpath('//device/profile/@name').text).to eq('AlternateKid')
    end

    it 'Match content of [@gender] - male' do
      expect(fetch_device_res.xpath('//device/profile/@gender').text).to eq('male')
    end

    it 'Match content of [@grade] - 5' do
      expect(fetch_device_res.xpath('//device/profile/@grade').text).to eq('5')
    end
  end

  context '8. Package installation' do
    license_id = nil

    it 'GrantLicense' do
      grant_license_res = LicenseManagement.grant_license(caller_id, session, customer_id, device_serial, package_id)
      license_id = grant_license_res.xpath('//license').attr('id').text

      pending "***GrantLicense [@license-id] - #{license_id} (URL: #{LFWSDL::CONST_LICENSE_MGT})"
    end

    it "Install package [@package-id]: #{package_id} (URL: #{LFWSDL::CONST_LICENSE_MGT})" do
      LicenseManagement.install_package(caller_id, device_serial, '0', package_id)
    end

    it "Report installation (URL: #{LFWSDL::CONST_PACKAGE_MGT})" do
      PackageManagement.report_installation(caller_id, session, device_serial, '0', package_id, license_id)
    end

    it "Verify package is installed successfully (status = installed) (URL: #{LFWSDL::CONST_PACKAGE_MGT})" do
      device_inventory_res1 = PackageManagement.device_inventory(caller_id, 'application', device_serial, 'Application')
      check_install_pgk1 = LicenseManagement.check_install_package(device_inventory_res1, package_id, 'installed')

      expect(check_install_pgk1).to eq(1)
    end

    it "Verify 'fetchRestrictedLicenses' returns @license-count - 1 (URL: #{LFWSDL::CONST_LICENSE_MGT})" do
      fetch_restricted_res = LicenseManagement.fetch_restricted_licenses(caller_id, 'service', session, customer_id, device_serial)
      license_num = fetch_restricted_res.xpath('//licenses').count

      expect(license_num).to eq(1)
    end

    it "Remove package on device [@package-id] - #{package_id} (URL: #{LFWSDL::CONST_PACKAGE_MGT})" do
      PackageManagement.remove_installation(caller_id, session, device_serial, 0, package_id)
    end

    it "Verify package is removed from device (status = removed) (URL: #{LFWSDL::CONST_PACKAGE_MGT})" do
      device_inventory_res2 = PackageManagement.device_inventory(caller_id, 'application', device_serial, 'Application')
      check_install_pgk2 = LicenseManagement.check_install_package(device_inventory_res2, package_id, 'removed')

      expect(check_install_pgk2).to eq(1)
    end
  end unless package_id.empty?

  context '9. Device log/game upload' do
    soap_fault1, soap_fault2 = nil

    before :all do
      # Upload Device log
      upload_device_res = DeviceLogUpload.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial, '2013-11-11T00:00:00', 'jeweltrain2.bin')
      soap_fault1 = upload_device_res.xpath('//faultcode').count

      # Upload Game log
      upload_game_res = DeviceLogUpload.upload_game_log(caller_id, child_id, '2013-11-11T00:00:00', filename, content_path)
      soap_fault2 = upload_game_res.xpath('//faultcode').count
    end

    it "Verify 'Device Log Upload' calls successfully - #{LFWSDL::CONST_DEVICE_LOG_UPLOAD_MGT}" do
      expect(soap_fault1).to eq(0)
    end

    it "Verify 'Device Game Upload' calls successfully - #{LFSOAP::CONST_GAME_LOG_UPLOAD_ENDPOINT}" do
      expect(soap_fault2).to eq(0)
    end
  end

  context '10. Unclaim device' do
    fetch_device_res = nil

    before :all do
      # Unclaim device
      OwnerManagement.unclaim_device(caller_id, session, 'service', device_serial)

      # Fetch device info
      fetch_device_res = DeviceManagement.fetch_device(caller_id, device_serial, platform)
    end

    it 'Match content of [@activated-by] = 0' do
      expect(fetch_device_res.xpath('//device/@activated-by').text).to eq('0')
    end

    it 'Match content of [@claimed] = false' do
      expect(fetch_device_res.xpath('//device/profile/@claimed').text).to eq('false')
    end
  end
end
