require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'
# require 'csc_login_page'
# require 'csc_home_page'

=begin
Tests basic ATG/LF.com features: setup customer, setup device, upload play data
=end

# initial variables
atg_home_page = HomeATG.new
atg_register_page = nil
atg_my_profile_page = nil
# csc_login_page = LoginCSC.new
# csc_home_page = nil
username = email = Data::EMAIL_GUEST_CONST
password = Data::PASSWORD_CONST
registered_account_infor = "ltrc vn #{email} #{Data::COUNTRY_CONST}"
# csc_customer_infor = "#{email} ltrc vn #{email}"

feature 'ATG/LF.com smoke test. Tests basic features: setup customer, setup device, upload play data ', js: true do
  context 'Set up customer' do
    before :all do
      atg_home_page.load
    end

    context 'On Register page' do
      scenario '1- Go to register/login page' do
        atg_register_page = atg_home_page.goto_login
      end

      scenario '2- Enter completely the information displayed on the Registration page' do
        atg_my_profile_page = atg_register_page.register(CreditInfo::FIRST_NAME_CONST, CreditInfo::LAST_NAME_CONST, email, password, password)
      end

      scenario '3- Verify My Profile page should be displayed' do
        expect(atg_my_profile_page.my_profile_page_exist?).to eq(true)
      end
    end

    context 'On My profile page' do
      scenario '1- Click on Account information link' do
        atg_my_profile_page.goto_account_information
        atg_my_profile_page.goto_account_information2  # (This line required for Bug ATG #12497)
      end

      scenario '2- Account information in My Profile page is correct' do
        expect(atg_my_profile_page.get_account_info).to eq(registered_account_infor)
      end
    end

    # context 'On CSC page' do
    #   scenario '1- Make sure csc page is displaying' do
    #     csc_home_page = csc_login_page.login(Data::CSC_USERNAME_CONST, Data::CSC_PASSWORD_CONST)
    #   end
    #
    #   scenario "2- Seach a customer by email - #{email}" do
    #     csc_home_page.search_customer_by_email(email)
    #   end
    #
    #   scenario '3- User already created can be found in CSC' do
    #     expect(csc_home_page.get_customer_info).to eq(csc_customer_infor)
    #   end
    # end
  end

  context 'Set up device and Upload play data' do
    #---Set variable all TS
    caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
    device_serial1 = 'RIO' + DeviceManagementService.generate_serial
    device_serial2 = 'LP2' + DeviceManagementService.generate_serial
    device_serial3 = 'LR' + DeviceManagementService.generate_serial
    session = nil
    customer_id = nil
    rio_child_id = lp2_child_id = lr_child_id = nil

    # Set variable device/content upload log
    filename = 'Stretchy monkey.log'
    content_path = "#{ServicesInfo::CONST_PROJECT_PATH}\\data\\Log2.xml"

    context 'Account Setup - Register children' do
      child_name1 = child_name2 = child_name3 = nil
      gender1 = gender2 = gender3 = nil
      grade1 = grade2 = grade3 = nil
      it "Register child1 for customer '#{email}'" do
        # Get customer id
        search_res = CustomerManagement.search_for_customer(caller_id, email)
        customer_id = search_res.xpath('//customer/@id').text

        # acquire service session
        session_res = AuthenticationService.acquire_service_session(caller_id, email, password)
        session = session_res.xpath('//session').text

        # Create RIO Child
        xml_register_child_rio = ChildManagementService.register_child(caller_id, session, customer_id, 'RIOKid', 'male', '1')
        rio_child_id = xml_register_child_rio.xpath('//child').attr('id').text
        child_name1 = xml_register_child_rio.xpath('//child').attr('name').text
        gender1 = xml_register_child_rio.xpath('//child').attr('gender').text
        grade1 = xml_register_child_rio.xpath('//child').attr('grade').text
      end

      it 'Match content of [@name] - RIO' do
        expect(child_name1).to eq('RIOKid')
      end

      it 'Match content of [@grade] - RIO' do
        expect(gender1).to eq('male')
      end

      it 'Match content of [@gender] - RIO' do
        expect(grade1).to eq('1')
      end

      it "Register child2 for customer '#{email}'" do
        # Create Leapad2 Child
        xml_register_child_lp2 = ChildManagementService.register_child(caller_id, session, customer_id, 'LP2Kid', 'female', '1')
        lp2_child_id = xml_register_child_lp2.xpath('//child').attr('id').text
        child_name2 = xml_register_child_lp2.xpath('//child').attr('name').text
        gender2 = xml_register_child_lp2.xpath('//child').attr('gender').text
        grade2 = xml_register_child_lp2.xpath('//child').attr('grade').text
      end

      it 'Match content of [@name] - LP2' do
        expect(child_name2).to eq('LP2Kid')
      end

      it 'Match content of [@grade] - LP2' do
        expect(gender2).to eq('female')
      end

      it 'Match content of [@gender] - LP2' do
        expect(grade2).to eq('1')
      end

      it "Register child3 for customer '#{email}'" do
        # Create Leap Reader Child
        xml_register_child_lr = ChildManagementService.register_child(caller_id, session, customer_id, 'LRKid', 'male', '2')
        lr_child_id = xml_register_child_lr.xpath('//child').attr('id').text
        child_name3 = xml_register_child_lr.xpath('//child').attr('name').text
        gender3 = xml_register_child_lr.xpath('//child').attr('gender').text
        grade3 = xml_register_child_lr.xpath('//child').attr('grade').text
      end

      it 'Match content of [@name] - LR' do
        expect(child_name3).to eq('LRKid')
      end

      it 'Match content of [@grade] - LR' do
        expect(gender3).to eq('male')
      end

      it 'Match content of [@gender] - LR' do
        expect(grade3).to eq('2')
      end
    end

    context 'Claim Devices' do
      serial1 = serial2 = serial3 = nil
      platform1 = platform2 = platform3 = nil
      it 'Claim RIO device'  do
        # Claim RIO
        OwnerManagementService.claim_device(caller_id, session, device_serial1, 'leappad3', '0', 'RIOKid', '04444454')

        # listNominatedDevices and get device serials value
        xml_list_nominated_devices_res = DeviceManagementService.list_nominated_devices(caller_id, session, 'service')
        serial1 = xml_list_nominated_devices_res.xpath('//device[1]').attr('serial').text
        platform1 = xml_list_nominated_devices_res.xpath('//device[1]').attr('platform').text
      end

      it 'Match content of [@serial] - RIO' do
        expect(serial1).to eq(device_serial1)
      end

      it 'Match content of [@platform] - RIO' do
        expect(platform1).to eq('leappad3')
      end

      it 'Claim LP2 device'  do
        # Claim LP2
        a = OwnerManagementService.claim_device(caller_id, session, device_serial2, 'leappad2', '0', 'LP2Kid', '04444454')

        # listNominatedDevices and get device serials value
        xml_list_nominated_devices_res = DeviceManagementService.list_nominated_devices(caller_id, session, 'service')
        serial2 = xml_list_nominated_devices_res.xpath('//device[2]').attr('serial').text
        platform2 = xml_list_nominated_devices_res.xpath('//device[2]').attr('platform').text
      end

      it 'Match content of [@serial] - LP2' do
        expect(serial2).to eq(device_serial2)
      end

      it 'Match content of [@platform] - LP2' do
        expect(platform2).to eq('leappad2')
      end

      it 'Claim LR device'  do
        # Step 3: Claim LR
        OwnerManagementService.claim_device(caller_id, session, device_serial3, 'leapreader', '0', 'LRKid', '04444454')

        # listNominatedDevices and get device serials value
        xml_list_nominated_devices_res = DeviceManagementService.list_nominated_devices(caller_id, session, 'service')
        serial3 = xml_list_nominated_devices_res.xpath('//device[3]').attr('serial').text
        platform3 = xml_list_nominated_devices_res.xpath('//device[3]').attr('platform').text
      end

      it 'Match content of [@serial] - LR' do
        expect(serial3).to eq(device_serial3)
      end

      it 'Match content of [@platform] - LR' do
        expect(platform3).to eq('leapreader')
      end

      soap_fault = nil
      it 'Assign device profile'  do
        assign_device_res = LFCommon.soap_call(
          ServicesInfo::CONST_INMON_ENDPOINTS[:device_profile_management][:endpoint],
          ServicesInfo::CONST_INMON_ENDPOINTS[:device_profile_management][:namespace],
          :assign_device_profile,
          "<device-profile device='#{device_serial1}' platform='leappad3' slot='0' name='RIOKid' child-id='#{rio_child_id}'/>
          <device-profile device='#{device_serial2}' platform='leappad2' slot='0' name='LP2Kid' child-id='#{lp2_child_id}'/>
          <device-profile device='#{device_serial3}' platform='leapreader' slot='0' name='LRKid' child-id='#{lr_child_id}'/>
          <caller-id>#{caller_id}</caller-id>
          <username/>
          <customer-id>#{customer_id}</customer-id>"
        )

        xml_assign_device = Nokogiri::XML(assign_device_res.to_s)
        soap_fault = xml_assign_device.xpath('//faultstring').count
      end

      it "Verify 'Assign Device Profiles' calls successfully" do
        expect(soap_fault).to eq(0)
      end

      profile_num = nil
      it 'Get list device profiles'  do
        # Get Device Profiles
        xml_get_device_profile = DeviceProfileManagementService.list_device_profiles(caller_id, username, customer_id, '10', '10', '')
        profile_num = xml_get_device_profile.xpath('//device-profile').count
      end

      it 'Check count of [device-profile]' do
        expect(profile_num).to eq(3)
      end
    end

    context 'Device Log & Content Upload - RIO' do
      soap_fault1 = soap_fault2 = nil

      it 'Upload play data' do
        # Upload Device log
        xml_upload_device = DeviceLogUploadService.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial1, '2013-11-11T00:00:00', 'jeweltrain2.bin')
        soap_fault1 = xml_upload_device.xpath('//faultcode').count

        # Upload Game log
        xml_upload_game = DeviceLogUploadService.upload_game_log(caller_id, rio_child_id, '2013-11-11T00:00:00', filename, content_path)
        soap_fault2 = xml_upload_game.xpath('//faultcode').count
      end

      it "Verify 'Device Log Upload - RIO' calls successfully" do
        expect(soap_fault1).to eq(0)
      end
      it "Verify 'Device Content Upload - RIO' calls successfully" do
        expect(soap_fault2).to eq(0)
      end
    end

    context 'Device Log & Content Upload - LP2' do
      soap_fault1 = soap_fault2 = nil

      it 'Upload play data' do
        # Upload Device log
        xml_upload_device = DeviceLogUploadService.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial2, '2013-11-11T00:00:00', 'jeweltrain2.bin')
        soap_fault1 = xml_upload_device.xpath('//faultcode').count

        # Upload Game log
        xml_upload_game = DeviceLogUploadService.upload_game_log(caller_id, lp2_child_id, '2013-11-11T00:00:00', filename, content_path)
        soap_fault2 = xml_upload_game.xpath('//faultcode').count
      end

      it "Verify 'Device Log Upload - LP2' calls successfully" do
        expect(soap_fault1).to eq(0)
      end

      it "Verify 'Device Content Upload - LP2' calls successfully" do
        expect(soap_fault2).to eq(0)
      end
    end

    context 'Device Log & Content Upload - LR' do
      soap_fault1 = soap_fault2 = nil

      it 'Upload play data' do
        # Upload Device log
        xml_upload_device = DeviceLogUploadService.upload_device_log(caller_id, 'Jewel_Train_2.log', '0', device_serial3, '2013-11-11T00:00:00', 'jeweltrain2.bin')
        soap_fault1 = xml_upload_device.xpath('//faultcode').count

        # Upload Game log
        xml_upload_game = DeviceLogUploadService.upload_game_log(caller_id, lr_child_id, '2013-11-11T00:00:00', filename, content_path)
        soap_fault2 = xml_upload_game.xpath('//faultcode').count
      end

      it "Verify 'Device Log Upload - LR' calls successfully" do
        expect(soap_fault1).to eq(0)
      end

      it "Verify 'Device Content Upload - LR' calls successfully" do
        expect(soap_fault2).to eq(0)
      end
    end
  end
end
