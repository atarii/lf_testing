require File.expand_path('../../spec_helper', __FILE__)
require 'customer_management'
require 'device_management'
require 'authentication'
require 'owner_management'
require 'child_management'

=begin
Glasgow: OOBE flow checking
=end

describe "TS03 - GLASGOW - OOBE flow - #{Misc::CONST_ENV}" do
  context 'TC03.001 - Golden path' do
    device_serial = DeviceManagement.generate_serial
    platform = 'leapup'
    screen_name = CustomerManagement.generate_screenname
    username = email = LFCommon.generate_email
    password = '123456'
    act_code = nil
    session = nil
    customer_id = nil
    slot = '0'
    profile_name = 'profile1'
    dob = '2013-10-08'
    grade = '5'
    gender = 'male'
    child_id_fet_dev = nil
    child_id_lst_chn = nil

    context "register_device: device serial - #{device_serial} (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      reg_dev_res = DeviceManagement.register_device Misc::CONST_CALLER_ID, device_serial, platform

      it 'Successful response' do
        expect(reg_dev_res.to_s).to include('updateProfilesResponse')
      end
    end

    context "fetchDeviceActivationCode (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      act_code = nil

      before :all do
        fet_dev_act_res = DeviceManagement.fetch_device_activation_code Misc::CONST_CALLER_ID, device_serial
        act_code = fet_dev_act_res.xpath('//activation-code').text
      end

      it 'Verify activation code: 6 digits' do
        expect(act_code.length).to eq(6)
      end
    end

    context "registerCustomer (URL: #{LFWSDL::CONST_CUSTOMER_MGT})" do
      customer_id = nil

      before :all do
        register_cus_res = CustomerManagement.register_customer Misc::CONST_CALLER_ID, screen_name, username, email
        arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
        customer_id = arr_register_cus_res[:id]
      end

      it 'Successful response' do
        expect(customer_id.to_i > 0).to eq(true)
      end
    end

    context "acquireServiceSession (URL: #{LFWSDL::CONST_AUTHENTICATION})" do
      before :all do
        acq_res = Authentication.acquire_service_session Misc::CONST_CALLER_ID, username, password
        session = acq_res.xpath('//session').text
      end

      it 'Successful response' do
        expect(session.length > 0).to eq(true)
      end
    end

    context "lookupDeviceByActivationCode (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      loo_dev_res = nil

      before :all do
        loo_dev_res = DeviceManagement.lookup_device_by_activation_code Misc::CONST_CALLER_ID, session, act_code
      end

      it "Verify device serial: #{device_serial}" do
        expect(loo_dev_res.xpath('//device/@serial').text).to eq(device_serial)
      end

      it "Verify platform: #{platform}" do
        expect(loo_dev_res.xpath('//device/@platform').text).to eq(platform)
      end

      it 'Verify activated-by: 0' do
        expect(loo_dev_res.xpath('//device/@activated-by').text).to eq('0')
      end
    end

    context "claimDevice (URL: #{LFWSDL::CONST_OWNER_MGT})" do
      clm_dev_res = nil

      before :all do
        clm_dev_res = OwnerManagement.claim_device Misc::CONST_CALLER_ID, session, customer_id, device_serial, platform, slot, profile_name, '1111', dob, grade, gender
      end

      it "Verify activated-by: #{customer_id}" do
        pending "*** Verify activated-by: #{customer_id}"
        expect(clm_dev_res.xpath('//claimed-device/@activated-by').text).to eq(customer_id)
      end
    end

    context "updateProfiles - with parent token (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      upd_pro_res = nil

      before :all do
        upd_pro_res = DeviceManagement.update_profiles_with_properties Misc::CONST_CALLER_ID, email, session, 'service', device_serial, platform, slot, profile_name, dob, grade, gender, '1234', '1111'
      end

      it 'Successful response' do
        expect(upd_pro_res.to_s).to include('updateProfilesResponse')
      end
    end

    context "fetchDevice (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      fet_dev_res = nil

      before :all do
        fet_dev_res = DeviceManagement.fetch_device Misc::CONST_CALLER_ID, device_serial, platform
        child_id_fet_dev = fet_dev_res.xpath('//profile/@child-id').text
      end

      it 'Verify activated-by:' do
        pending "*** Verify activated-by: #{customer_id}"
        expect(fet_dev_res.xpath('//device/@activated-by').text).to eq(customer_id)
      end

      it "Verify device serial: #{device_serial}" do
        expect(fet_dev_res.xpath('//device/@serial').text).to eq(device_serial)
      end

      it "Verify platform: #{platform}" do
        expect(fet_dev_res.xpath('//device/@platform').text).to eq(platform)
      end

      it "Verify profile name: #{profile_name}" do
        expect(fet_dev_res.xpath('//profile/@name').text).to eq(profile_name)
      end

      it "Verify grade: #{grade}" do
        expect(fet_dev_res.xpath('//profile/@grade').text).to eq(grade)
      end

      it "Verify gender: #{gender}" do
        expect(fet_dev_res.xpath('//profile/@gender').text).to eq(gender)
      end

      it "Verify dob: #{dob}" do
        expect(fet_dev_res.xpath('//profile/@dob').text).to include(dob)
      end

      it "Verify parent pin: '1111'" do
        expect(fet_dev_res.xpath('//properties/property[1]/@value').text).to eq('1111')
      end
    end

    context "listChildren - validate children are automatically created (URL: #{LFWSDL::CONST_CHILD_MGT})" do
      lst_chn = nil

      before :all do
        lst_chn = ChildManagement.list_children Misc::CONST_CALLER_ID, session, customer_id
        child_id_lst_chn = lst_chn.xpath('//child/@id').text
      end

      it "Verify profile name: #{profile_name}" do
        expect(lst_chn.xpath('//child/@name').text).to eq(profile_name)
      end

      it "Verify grade: #{grade}" do
        expect(lst_chn.xpath('//child/@grade').text).to eq(grade)
      end

      it "Verify gender: #{gender}" do
        expect(lst_chn.xpath('//child/@gender').text).to eq(gender)
      end

      it "Verify dob: #{dob}" do
        expect(lst_chn.xpath('//child/@dob').text).to include(dob)
      end

      it "Verify child-id: #{child_id_lst_chn}" do
        pending "*** verify child-id: #{child_id_lst_chn}"
        expect(child_id_lst_chn).to eq(child_id_fet_dev)
      end
    end

    context "lookupDeviceByActivationCode - validate device info (URL: #{ LFWSDL::CONST_DEVICE_MGT})" do
      lkp_dev = nil

      before :all do
        lkp_dev = DeviceManagement.lookup_device_by_activation_code Misc::CONST_CALLER_ID, session, act_code
      end

      it 'Verify activated-by: 0' do
        pending "*** Verify activated-by: #{customer_id}"
        expect(lkp_dev.xpath('//device/@activated-by').text).to eq(customer_id)
      end

      it "Verify device serial: #{device_serial}" do
        expect(lkp_dev.xpath('//device/@serial').text).to eq(device_serial)
      end

      it "Verify platform: #{platform}" do
        expect(lkp_dev.xpath('//device/@platform').text).to eq(platform)
      end

      it "Verify pin: '1111'" do
        expect(lkp_dev.xpath('//device/@pin').text).to eq('1111')
      end
    end

    context "fetchCustomerDevices (URL: #{LFWSDL::CONST_CUSTOMER_MGT})" do
      before :all do
        CustomerManagement.fetch_customer_devices Misc::CONST_CALLER_ID, customer_id, device_serial
      end

      it 'fetchCustomerDevices' do
        pending '*** activated-id = 0'
      end
    end

    context "listNominatedDevices (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      before :all do
        DeviceManagement.list_nominated_devices Misc::CONST_CALLER_ID, session, 'service'
      end

      it 'fetchCustomerDevices' do
        pending '*** activated-id = 0'
      end
    end
  end

  context 'TC03.002 - reset device' do
    device_serial = DeviceManagement.generate_serial
    platform = 'leapup'
    screen_name = CustomerManagement.generate_screenname
    username = email = LFCommon.generate_email
    password = '123456'
    session = nil
    customer_id = nil
    slot = '0'
    profile_name = 'profile1'
    dob = '2013-10-08'
    grade = '5'
    gender = 'male'

    context "register_device: device serial - #{device_serial} (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      reg_dev_res = DeviceManagement.register_device Misc::CONST_CALLER_ID, device_serial, platform

      it 'Successful response' do
        expect(reg_dev_res.to_s).to include('updateProfilesResponse')
      end
    end

    context "fetchDeviceActivationCode (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      act_code = nil

      before :all do
        fet_dev_act_res = DeviceManagement.fetch_device_activation_code Misc::CONST_CALLER_ID, device_serial
        act_code = fet_dev_act_res.xpath('//activation-code').text
      end

      it 'Verify activation code: 6 digits' do
        expect(act_code.length).to eq(6)
      end
    end

    context "registerCustomer (URL: #{LFWSDL::CONST_CUSTOMER_MGT})" do
      before :all do
        register_cus_res = CustomerManagement.register_customer Misc::CONST_CALLER_ID, screen_name, username, email
        arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
        customer_id = arr_register_cus_res[:id]
      end

      it 'Successful response' do
        expect(customer_id.to_i > 0).to eq(true)
      end
    end

    context "acquireServiceSession (URL: #{LFWSDL::CONST_AUTHENTICATION})" do
      before :all do
        acq_res = Authentication.acquire_service_session Misc::CONST_CALLER_ID, username, password
        session = acq_res.xpath('//session').text
      end

      it 'Successful response' do
        expect(session.length > 0).to eq(true)
      end
    end

    context "claimDevice (URL: #{LFWSDL::CONST_OWNER_MGT})" do
      clm_dev_res = nil

      before :all do
        clm_dev_res = OwnerManagement.claim_device Misc::CONST_CALLER_ID, session, customer_id, device_serial, platform, slot, profile_name, '1111', dob, grade, gender
      end

      it "Verify activated-by: #{customer_id}" do
        pending "*** Verify activated-by: #{customer_id}"
        expect(clm_dev_res.xpath('//claimed-device/@activated-by').text).to eq(customer_id)
      end
    end

    context "updateProfiles - with parent token (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      upd_pro_res = nil

      before :all do
        upd_pro_res = DeviceManagement.update_profiles_with_properties Misc::CONST_CALLER_ID, email, session, 'service', device_serial, platform, slot, profile_name, dob, grade, gender, '1111'
      end

      it 'Successful response' do
        expect(upd_pro_res.to_s).to include('updateProfilesResponse')
      end
    end

    context "fetchDevice (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      fet_dev_res = nil

      before :all do
        fet_dev_res = DeviceManagement.fetch_device Misc::CONST_CALLER_ID, device_serial, platform
      end

      it 'Verify activated-by: 0' do
        expect(fet_dev_res.xpath('//device/@activated-by').text).to eq(customer_id)
      end

      it "Verify device serial: #{device_serial}" do
        expect(fet_dev_res.xpath('//device/@serial').text).to eq(device_serial)
      end

      it "Verify platform: #{platform}" do
        expect(fet_dev_res.xpath('//device/@platform').text).to eq(platform)
      end

      it "Verify profile name: #{profile_name}" do
        expect(fet_dev_res.xpath('//profile/@name').text).to eq(profile_name)
      end

      it "Verify grade: #{grade}" do
        expect(fet_dev_res.xpath('//profile/@grade').text).to eq(grade)
      end

      it "Verify gender: #{gender}" do
        expect(fet_dev_res.xpath('//profile/@gender').text).to eq(gender)
      end

      it "Verify dob: #{dob}" do
        expect(fet_dev_res.xpath('//profile/@dob').text).to include(dob)
      end
    end

    context "resetDevice (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      res_dev = nil

      before :all do
        res_dev = DeviceManagement.reset_device Misc::CONST_CALLER_ID, session, device_serial, true
      end

      it 'Successful response' do
        expect(res_dev.to_s).to include('resetDeviceResponse')
      end
    end

    context "fetchDevice - validate reset device (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      fet_dev_res = DeviceManagement.fetch_device Misc::CONST_CALLER_ID, device_serial, ''

      it 'Verify activated-by: 0' do
        expect(fet_dev_res.xpath('//device/@activated-by').text).to eq('0')
      end

      it "Verify device serial: #{device_serial}" do
        expect(fet_dev_res.xpath('//device/@serial').text).to eq(device_serial)
      end
    end
  end

  context 'TC03.003 - claim to a new customer after resetting' do
    device_serial = DeviceManagement.generate_serial
    platform = 'leapup'
    screen_name = CustomerManagement.generate_screenname
    screen_name2 = screen_name + '2'
    username = email = LFCommon.generate_email
    username2 = email2 = username + '2'
    password = '123456'
    session = nil
    session2 = nil
    customer_id = nil
    customer_id2 = nil
    slot = '0'
    profile_name = 'profile1'
    dob = '2013-10-08'
    grade = '5'
    gender = 'male'

    context "register_device: device serial - #{device_serial} (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      reg_dev_res = DeviceManagement.register_device Misc::CONST_CALLER_ID, device_serial, platform

      it 'Successful response' do
        expect(reg_dev_res.to_s).to include('updateProfilesResponse')
      end
    end

    context "fetchDeviceActivationCode (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      act_code = nil

      before :all do
        fet_dev_act_res = DeviceManagement.fetch_device_activation_code Misc::CONST_CALLER_ID, device_serial
        act_code = fet_dev_act_res.xpath('//activation-code').text
      end

      it 'Verify activation code: 6 digits' do
        expect(act_code.length).to eq(6)
      end
    end

    context "registerCustomer (URL: #{LFWSDL::CONST_CUSTOMER_MGT})" do
      before :all do
        register_cus_res = CustomerManagement.register_customer Misc::CONST_CALLER_ID, screen_name, username, email
        arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
        customer_id = arr_register_cus_res[:id]
      end

      it 'Successful response' do
        expect(customer_id.to_i > 0).to eq(true)
      end
    end

    context "acquireServiceSession (URL: #{LFWSDL::CONST_AUTHENTICATION})" do
      before :all do
        acq_res = Authentication.acquire_service_session Misc::CONST_CALLER_ID, username, password
        session = acq_res.xpath('//session').text
      end

      it 'Successful response' do
        expect(session.length > 0).to eq(true)
      end
    end

    context "claimDevice (URL: #{LFWSDL::CONST_OWNER_MGT})" do
      clm_dev_res = nil

      before :all do
        clm_dev_res = OwnerManagement.claim_device Misc::CONST_CALLER_ID, session, customer_id, device_serial, platform, slot, profile_name, '1111', dob, grade, gender
      end

      it "Verify activated-by: #{customer_id}" do
        pending "*** Verify activated-by: #{customer_id}"
        expect(clm_dev_res.xpath('//claimed-device/@activated-by').text).to eq(customer_id)
      end
    end

    context "updateProfiles - with parent token (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      upd_pro_res = nil

      before :all do
        upd_pro_res = DeviceManagement.update_profiles_with_properties Misc::CONST_CALLER_ID, email, session, 'service', device_serial, platform, slot, profile_name, dob, grade, gender, '1111'
      end

      it 'Successful response' do
        expect(upd_pro_res.to_s).to include('updateProfilesResponse')
      end
    end

    context "fetchDevice (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      fet_dev_res = nil

      before :all do
        fet_dev_res = DeviceManagement.fetch_device Misc::CONST_CALLER_ID, device_serial, platform
      end

      it "Verify activated-by: #{customer_id}" do
        pending "*** Verify activated-by: #{customer_id}"
        expect(fet_dev_res.xpath('//device/@activated-by').text).to eq(customer_id)
      end

      it "Verify device serial: #{device_serial}" do
        expect(fet_dev_res.xpath('//device/@serial').text).to eq(device_serial)
      end

      it "Verify platform: #{platform}" do
        expect(fet_dev_res.xpath('//device/@platform').text).to eq(platform)
      end

      it "Verify profile name: #{profile_name}" do
        expect(fet_dev_res.xpath('//profile/@name').text).to eq(profile_name)
      end

      it "Verify grade: #{grade}" do
        expect(fet_dev_res.xpath('//profile/@grade').text).to eq(grade)
      end

      it "Verify gender: #{gender}" do
        expect(fet_dev_res.xpath('//profile/@gender').text).to eq(gender)
      end

      it "Verify dob: #{dob}" do
        expect(fet_dev_res.xpath('//profile/@dob').text).to include(dob)
      end
    end

    context "resetDevice (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      it 'Successful response' do
        res_dev = DeviceManagement.reset_device Misc::CONST_CALLER_ID, session, device_serial, true
        expect(res_dev.to_s).to include('resetDeviceResponse')
      end
    end

    context "fetchDevice - validate reset device (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      fet_dev_res = DeviceManagement.fetch_device Misc::CONST_CALLER_ID, device_serial, ''

      it 'Verify activated-by: 0' do
        expect(fet_dev_res.xpath('//device/@activated-by').text).to eq('0')
      end

      it "Verify device serial: #{device_serial}" do
        expect(fet_dev_res.xpath('//device/@serial').text).to eq(device_serial)
      end
    end

    context 'registerCustomer - 2nd' do
      register_cus_res = nil

      it "Register customer (URL: #{LFWSDL::CONST_CUSTOMER_MGT})" do
        register_cus_res = CustomerManagement.register_customer Misc::CONST_CALLER_ID, screen_name2, username2, email2
        arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
        customer_id2 = arr_register_cus_res[:id]
      end

      it 'Successful response' do
        expect(customer_id2.to_i > 0).to eq(true)
      end
    end

    context "acquireServiceSession - 2nd (URL: #{LFWSDL::CONST_AUTHENTICATION})" do
      before :all do
        acq_res = Authentication.acquire_service_session Misc::CONST_CALLER_ID, username2, password
        session2 = acq_res.xpath('//session').text
      end

      it 'Successful response' do
        expect(session2.length > 0).to eq(true)
      end
    end

    context "claimDevice - for 2nd customer (URL: #{LFWSDL::CONST_OWNER_MGT})" do
      it "Verify activated-by: #{customer_id2}" do
        pending "*** Verify activated-by: #{customer_id2}"
        clm_dev_res = OwnerManagement.claim_device Misc::CONST_CALLER_ID, session2, customer_id2, device_serial, platform, slot, profile_name, '1111', dob, grade, gender
        expect(clm_dev_res.xpath('//claimed-device/@activated-by').text).to eq(customer_id2)
      end
    end

    context "fetchDevice - validate claim for 2nd customer (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      fet_dev_res = nil

      before :all do
        fet_dev_res = DeviceManagement.fetch_device Misc::CONST_CALLER_ID, device_serial, platform
      end

      it "Verify activated-by: #{customer_id2}" do
        pending "*** Verify activated-by: #{customer_id2}"
        expect(fet_dev_res.xpath('//device/@activated-by').text).to eq(customer_id2)
      end

      it "Verify device serial: #{device_serial}" do
        expect(fet_dev_res.xpath('//device/@serial').text).to eq(device_serial)
      end

      it "Verify platform: #{platform}" do
        expect(fet_dev_res.xpath('//device/@platform').text).to eq(platform)
      end
    end
  end

  context 'TC03.004 - Change Parent Pin' do
    device_serial = DeviceManagement.generate_serial
    platform = 'leapup'
    screen_name = CustomerManagement.generate_screenname
    username = email = LFCommon.generate_email
    password = '123456'
    customer_id = nil
    slot = '0'
    profile_name = 'profile1'
    dob = '2013-10-08'
    grade = '5'
    gender = 'male'
    session = nil

    context 'Register account and claim device' do
      it "Register device (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
        DeviceManagement.register_device Misc::CONST_CALLER_ID, device_serial, platform
      end

      it "Register customer (URL: #{LFWSDL::CONST_CUSTOMER_MGT})" do
        CustomerManagement.register_customer Misc::CONST_CALLER_ID, screen_name, username, email
      end

      it "Authentication account (URL: #{LFWSDL::CONST_AUTHENTICATION})" do
        acq_res = Authentication.acquire_service_session Misc::CONST_CALLER_ID, username, password
        session = acq_res.xpath('//session').text
      end

      it "Claim device (URL: #{LFWSDL::CONST_OWNER_MGT})" do
        OwnerManagement.claim_device Misc::CONST_CALLER_ID, session, customer_id, device_serial, platform, slot, profile_name, '1111', dob, grade, gender
      end
    end

    context "updateProfiles - with 1nd parent token (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      it 'Successful response' do
        upd_pro_res = DeviceManagement.update_profiles_with_properties Misc::CONST_CALLER_ID, email, session, 'service', device_serial, platform, slot, profile_name, dob, grade, gender, '1234', '3333'
        expect(upd_pro_res.to_s).to include('updateProfilesResponse')
      end
    end

    context "fetchDevice - check 1st Parent Pin (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      fet_dev_res = nil

      before :all do
        fet_dev_res = DeviceManagement.fetch_device Misc::CONST_CALLER_ID, device_serial, platform
      end

      it "Verify parent pin: '3333'" do
        expect(fet_dev_res.xpath('//properties/property[1]/@value').text).to eq('3333')
      end
    end

    context "updateProfiles - with 2nd parent token (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      it 'Successful response' do
        upd_pro_res = DeviceManagement.update_profiles_with_properties Misc::CONST_CALLER_ID, email, session, 'service', device_serial, platform, slot, profile_name, dob, grade, gender, '1234', '5555'
        expect(upd_pro_res.to_s).to include('updateProfilesResponse')
      end
    end

    context "fetchDevice - check 2nd Parent Pin (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      fet_dev_res2 = nil

      before :all do
        fet_dev_res2 = DeviceManagement.fetch_device Misc::CONST_CALLER_ID, device_serial, platform
      end

      it "Verify parent pin: '5555'" do
        expect(fet_dev_res2.xpath('//properties/property[1]/@value').text).to eq('5555')
      end
    end
  end

  context 'TC03.005 - Create multi profiles' do
    device_serial = DeviceManagement.generate_serial
    platform = 'leapup'
    screen_name = CustomerManagement.generate_screenname
    username = email = LFCommon.generate_email
    password = '123456'
    session = customer_id = nil

    context 'Register account and device' do
      it "Register device (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
        DeviceManagement.register_device Misc::CONST_CALLER_ID, device_serial, platform
      end

      it "Register customer (URL: #{LFWSDL::CONST_CUSTOMER_MGT})" do
        register_cus_res = CustomerManagement.register_customer Misc::CONST_CALLER_ID, screen_name, username, email
        arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
        customer_id = arr_register_cus_res[:id]
      end

      it "Authentication account (URL: #{LFWSDL::CONST_AUTHENTICATION})" do
        acq_res = Authentication.acquire_service_session Misc::CONST_CALLER_ID, username, password
        session = acq_res.xpath('//session').text
      end
    end

    context "claimDevice - with 6 profiles (URL: #{LFWSDL::CONST_OWNER_MGT})" do
      clm_dev_res = nil

      before :all do
        # claimDevice with 6 profiles
        clm_dev_res = LFCommon.soap_call(
          LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:endpoint],
          LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:namespace],
          :claim_device,
          "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
          <session type='service'>#{session}</session>
          <device serial='#{device_serial}' auto-create='true' product-id='0' platform='leapup' pin='1111'>
            <profile slot='0' name='profile1' weak-id='1' uploadable='true' claimed='true' child-id='11111' dob='2013-10-08+07:00' grade='1' gender='male' auto-create='false' points='0' rewards='0'/>
            <profile slot='1' name='profile2' weak-id='1' uploadable='true' claimed='true' child-id='11111' dob='2013-10-08+07:00' grade='2' gender='female' auto-create='false' points='0' rewards='0'/>
            <profile slot='2' name='profile3' weak-id='1' uploadable='true' claimed='true' child-id='11111' dob='2013-10-08+07:00' grade='3' gender='male' auto-create='false' points='0' rewards='0'/>
            <profile slot='3' name='profile4' weak-id='1' uploadable='true' claimed='true' child-id='11111' dob='2013-10-08+07:00' grade='4' gender='female' auto-create='false' points='0' rewards='0'/>
            <profile slot='4' name='profile5' weak-id='1' uploadable='true' claimed='true' child-id='11111' dob='2013-10-08+07:00' grade='5' gender='male' auto-create='false' points='0' rewards='0'/>
            <profile slot='5' name='profile6' weak-id='1' uploadable='true' claimed='true' child-id='11111' dob='2013-10-08+07:00' grade='6' gender='female' auto-create='false' points='0' rewards='0'/>
          </device>"
        )
      end

      it "Verify activated-by: #{customer_id}" do
        expect(clm_dev_res.xpath('//claimed-device/@activated-by').text).to eq(customer_id)
      end
    end

    context "updateProfiles (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      upd_pro_res = nil

      before :all do
        # claimDevice with 6 profiles
        upd_pro_res = LFCommon.soap_call(
          LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:endpoint],
          LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:namespace],
          :update_profiles,
          "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
          <session type='service'>#{session}</session>
          <device auto-create='true' serial='#{device_serial}' product-id='0' platform='leapup'>
            <properties>
              <property key='pin' value='1111'/>
              <property key='parentemail' value='#{username}'/>
            </properties>
            <profile slot='0' name='profile1' points='0' rewards='0' weak-id='0' gender='male' grade='2' dob='2014-08-11'/>
            <profile slot='1' name='profile2' points='0' rewards='0' weak-id='0' gender='male' grade='2' dob='2014-08-11'/>
            <profile slot='2' name='profile3' points='0' rewards='0' weak-id='0' gender='male' grade='2' dob='2014-08-11'/>
            <profile slot='3' name='profile4' points='0' rewards='0' weak-id='0' gender='male' grade='2' dob='2014-08-11'/>
            <profile slot='4' name='profile5' points='0' rewards='0' weak-id='0' gender='male' grade='2' dob='2014-08-11'/>
            <profile slot='5' name='profile6' points='0' rewards='0' weak-id='0' gender='male' grade='2' dob='2014-08-11'/>
          </device>"
        )
      end

      it 'Successful response' do
        expect(upd_pro_res.to_s).to include('updateProfilesResponse')
      end
    end

    context "fetchDevice - check number of profile (URL: #{LFWSDL::CONST_DEVICE_MGT})" do
      it 'Verify the number of profiles is 6' do
        fet_dev_res = DeviceManagement.fetch_device Misc::CONST_CALLER_ID, device_serial, platform
        expect(fet_dev_res.xpath('//device/profile').count).to eq(6)
      end
    end
  end
end
