require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'owner_management'
require 'device_management'
require 'device_profile_management'
require 'device_log_upload'

=begin
Check OOBE golden path for all devices platform: Account Setup, register child, setup profile, claim device,
=end

def claim_device_1st(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id, dob, grade)
  OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id, dob, grade)
  fetch_device_res = DeviceManagement.fetch_device(caller_id, device_serial, platform)

  it "Match content of [device/@serial] - #{device_serial}" do
    expect(fetch_device_res.xpath('//device/@serial').text).to eq(device_serial)
  end

  it "Match content of [device/@platform] - #{platform}" do
    expect(fetch_device_res.xpath('//device/@platform').text).to eq(platform)
  end

  it "Match content of [device/profile/@name] - #{profile_name}" do
    expect(fetch_device_res.xpath('//device/profile/@name').text).to eq(profile_name)
  end

  it 'Match content of [device/profile/@weak-id] - 1' do
    expect(fetch_device_res.xpath('//device/profile/@weak-id').text).to eq('1')
  end

  it "Match content of [device/profile/@slot] - #{slot}" do
    expect(fetch_device_res.xpath('//device/profile/@slot').text).to eq(slot)
  end

  it "Match content of [device/profile/@grade] - #{grade}" do
    expect(fetch_device_res.xpath('//device/profile/@grade').text).to eq(grade)
  end
end

def claim_device_single_profile_2nd(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id)
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:namespace]

  # Step 3: updateProfile
  LFCommon.soap_call(
    endpoint,
    namespace,
    :update_profiles,
    "<caller-id>#{caller_id}</caller-id>
    <session type='service'>#{session}</session>
    <device serial='#{device_serial}' product-id='0' platform='leapreader'>
      <profile slot='0' name='AlternateKid' points='0' rewards='0' weak-id='1' uploadable='false' claimed='true'/>
    </device>"
  )

  # Step 4: unclaimDevice
  OwnerManagement.unclaim_device(caller_id, session, 'service', device_serial)

  # Step 5: claimDevice
  OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id)

  # Step 6: assignDeviceProfiles
  DeviceProfileManagement.assign_device_profile(caller_id, customer_id, device_serial, platform, slot, 'AlternateKid', child_id)

  # Step 7: fetchDevice
  fetch_device_res = DeviceManagement.fetch_device(caller_id, device_serial, platform)

  it "Match content of [device/@serial] - #{device_serial}" do
    expect(fetch_device_res.xpath('//device/@serial').text).to eq(device_serial)
  end

  it "Match content of [device/@platform] - #{platform}" do
    expect(fetch_device_res.xpath('//device/@platform').text).to eq(platform)
  end

  it 'Match content of [device/profile/@name] - AlternateKid' do
    expect(fetch_device_res.xpath('//device/profile/@name').text).to eq('AlternateKid')
  end

  it 'Match content of [device/profile/@weak-id] - 1' do
    expect(fetch_device_res.xpath('//device/profile/@weak-id').text).to eq('1')
  end

  it "Match content of [device/profile/@slot] - #{slot}" do
    expect(fetch_device_res.xpath('//device/profile/@slot').text).to eq(slot)
  end
end

def claim_device_multi_profiles_2nd(caller_id, session, customer_id, device_serial, username, platform, profile_name1, profile_name2, child_id1, child_id2)
  # Step 3: updateProfile
  LFCommon.soap_call(
    LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:endpoint],
    LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:namespace],
    :update_profiles,
    "<caller-id>#{caller_id}</caller-id>
    <session type='service'>#{session}</session>
    <device serial='#{device_serial}' product-id='0' platform='emerald'>
    <profile slot='0' name='EmeraldKid' points='0' rewards='0' weak-id='0' uploadable='false' claimed='false'/>
    <profile slot='1' weak-id='1' name='AlternateKid' uploadable='false' claimed='false' points='0' rewards='0'/>
    </device>"
  )

  # Step 4: assignDeviceProfiles
  LFCommon.soap_call(
    LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_management][:endpoint],
    LFSOAP::CONST_INMON_ENDPOINTS[:device_profile_management][:namespace],
    :assign_device_profile,
    "<caller-id>#{caller_id}</caller-id>
    <username>#{username}</username>
    <customer-id>#{customer_id}</customer-id>
    <device-profile device='#{device_serial}' platform='emerald' slot='0' name='#{profile_name1}' child-id='#{child_id1}'/>
    <device-profile device='#{device_serial}' platform='emerald' slot='1' name='#{profile_name2}' child-id='#{child_id2}'/>"
  )

  # Step 5: fetchDevice
  fetch_device_res = DeviceManagement.fetch_device(caller_id, device_serial, platform)

  it "Match content of [device/@serial] - #{device_serial}" do
    expect(fetch_device_res.xpath('//device/@serial').text).to eq(device_serial)
  end

  it "Match content of [device/@platform] - #{platform}" do
    expect(fetch_device_res.xpath('//device/@platform').text).to eq(platform)
  end

  it 'Check the number of profile - 2' do
    expect(fetch_device_res.xpath('//device/profile').count).to eq(2)
  end
end

describe "TS1.1 - OOBE Flow - Golden Path - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID

  # Customer info
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = Misc::CONST_PASSWORD
  customer_id = session = nil

  # Device info
  fetch_device_res1 = fetch_device_res2 = nil
  upload_res = nil
  device_service_code = 'android1'

  # Child ID
  rio_kid_id = leap_reader_kid_id = emerald_kid_id = lpad_kid_id = lpad2_kid_id = lpad3_kid_id = l2_kid_id = gs_kid_id = didj_kid_id = crammer_kid_id = mostp_kid_id = my_leaptop_kid_id = my_pals_kid_id = tag_kid_id = nil

  # Device serial
  device_serial_rio = 'RIO' + DeviceManagement.generate_serial
  device_serial_lr = 'LR' + DeviceManagement.generate_serial
  device_serial_lex = 'LEX' + DeviceManagement.generate_serial
  device_serial_lpad = 'LPAD' + DeviceManagement.generate_serial
  device_serial_lpad2 = 'LPAD2' + DeviceManagement.generate_serial
  device_serial_l2 = 'L2' + DeviceManagement.generate_serial
  device_serial_gs = 'GS' + DeviceManagement.generate_serial
  device_serial_didj = 'DIDJ' + DeviceManagement.generate_serial
  device_serial_crammer = 'CRAMMER' + DeviceManagement.generate_serial
  device_serial_mostp = 'MOSTP' + DeviceManagement.generate_serial
  device_serial_myleaptop = 'LEAPTOP' + DeviceManagement.generate_serial
  device_serial_pals = 'PALS' + DeviceManagement.generate_serial
  device_serial_tag = 'TAG' + DeviceManagement.generate_serial
  device_serial_lpad3 = 'LPAD3' + DeviceManagement.generate_serial
  device_serial_narnia = 'NARNIA' + DeviceManagement.generate_serial

  context 'TC1.1.0 OOBE - Accounts Setup' do
    context 'Step 1: Register Customer' do
      register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
      xml_register_cus = CustomerManagement.get_customer_info(register_cus_res)
      customer_id = xml_register_cus[:id]

      it "Match content of [@username] - registerCustomer - #{username}" do
        expect(xml_register_cus[:username]).to eq(username)
      end

      it "Match content of [@password] - registerCustomer - #{password}" do
        expect(xml_register_cus[:password]).to eq(password)
      end

      it 'Match content of [@alias] - registerCustomer - LTRCTester' do
        expect(xml_register_cus[:str_alias]).to eq('LTRCTester')
      end

      it 'Match content of [@last-name] - registerCustomer - Tester' do
        expect(xml_register_cus[:last_name]).to eq('Tester')
      end

      it 'Match content of [@first-name] - registerCustomer - LTRC' do
        expect(xml_register_cus[:first_name]).to eq('LTRC')
      end
    end

    context 'Step 2: Fetch Customer' do
      fetch_cus_res = CustomerManagement.fetch_customer(caller_id, customer_id)

      it "Match content of [@username] - fetchCustomer - #{username}" do
        expect(fetch_cus_res.xpath('//customer/credentials/@username').text).to eq(username)
      end

      it 'Match content of [@alias] - fetchCustomer - LTRCTester' do
        expect(fetch_cus_res.xpath('//customer/@alias').text).to eq('LTRCTester')
      end

      it 'Match content of [@last-name] - fetchCustomer - Tester' do
        expect(fetch_cus_res.xpath('//customer/@last-name').text).to eq('Tester')
      end

      it 'Match content of [@first-name] - fetchCustomer - LTRC' do
        expect(fetch_cus_res.xpath('//customer/@first-name').text).to eq('LTRC')
      end
    end

    context 'Step 3: Register Child' do
      # acquireServiceSession
      session = Authentication.get_service_session(caller_id, username, password)

      # Step 4: registerChild for all devices (13 child)
      res1 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'AlternateKid', 'male', '3')
      res2 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'LeapReaderKid', 'male', '5')
      res3 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'EmeraldKid', 'female', '3')
      res4 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'LpadKid', 'male', '5')
      res5 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'Lpad2Kid', 'male', '5')
      res6 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'L2Kid', 'male', '5')
      res7 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'GSKid', 'male', '4 ')
      res8 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'DidjKid', 'male', '4')
      res9 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'CrammerKid', 'male', '1')
      res10 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'MOSTPKid', 'female', '2')
      res11 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'MyLeaptopKid', 'female', '4')
      res12 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'MyPalsKid', 'male', '3')
      res13 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'TagKid', 'male', '1')
      res14 = ChildManagement.register_child_smoketest(caller_id, session, customer_id, 'Lpad3Kid', 'male', '5')

      # Get child IDs
      rio_kid_id = res1.xpath('//child/@id').text
      leap_reader_kid_id = res2.xpath('//child/@id').text
      emerald_kid_id = res3.xpath('//child/@id').text
      lpad_kid_id = res4.xpath('//child/@id').text
      lpad2_kid_id = res5.xpath('//child/@id').text
      l2_kid_id = res6.xpath('//child/@id').text
      gs_kid_id = res7.xpath('//child/@id').text
      didj_kid_id = res8.xpath('//child/@id').text
      crammer_kid_id = res9.xpath('//child/@id').text
      mostp_kid_id = res10.xpath('//child/@id').text
      my_leaptop_kid_id = res11.xpath('//child/@id').text
      my_pals_kid_id = res12.xpath('//child/@id').text
      tag_kid_id = res13.xpath('//child/@id').text
      lpad3_kid_id = res14.xpath('//child/@id').text

      # Step 5: listChildren
      list_child_res = ChildManagement.list_children(caller_id, session, customer_id)

      it 'Verify the number of child is 14' do
        expect(list_child_res.xpath('//child').count).to eq(14)
      end
    end
  end

  context 'TC1.1.1 OOBE - LeapPadUltra' do
    context 'Claim device - 1st' do
      # Step 1: claimDevice - Rio
      OwnerManagement.claim_rio_device(caller_id, session, email, device_serial_rio, 'RioKid', rio_kid_id)

      # Step 2: updateProfiles - Alternate Kid
      # Step 3: updateProfiles - Parent PIN
      DeviceManagement.update_profiles(caller_id, session, 'service', device_serial_rio, 'leappad3', '0', 'AlternateKid', rio_kid_id, '5', 'male')

      # Step 4: fetchDevice - Device Info
      fetch_device_res1 = DeviceManagement.fetch_device(caller_id, device_serial_rio, 'leappad3')

      # Ensure DB refresh in 5 seconds
      (1..5).each do
        break if fetch_device_res1.xpath('//device/profile/@claimed').text == 'true'
        sleep 1
        fetch_device_res1 = DeviceManagement.fetch_device(caller_id, device_serial_rio, 'leappad3')
      end

      it "Match content of [device/@serial] - #{device_serial_rio}" do
        expect(fetch_device_res1.xpath('//device/@serial').text).to eq(device_serial_rio)
      end

      it 'Match content of [device/@platform] - leappad3' do
        expect(fetch_device_res1.xpath('//device/@platform').text).to eq('leappad3')
      end

      it 'Match content of [device/profile/@name] - AlternateKid' do
        expect(fetch_device_res1.xpath('//device/profile/@name').text).to eq('AlternateKid')
      end

      it 'Match content of [device/profile/@weak-id] - 1' do
        expect(fetch_device_res1.xpath('//device/profile/@weak-id').text).to eq('1')
      end

      it 'Match content of [device/profile/@slot] - 0' do
        expect(fetch_device_res1.xpath('//device/profile/@slot').text).to eq('0')
      end

      it 'Match content of [device/profile/@claimed] - true' do
        expect(fetch_device_res1.xpath('//device/profile/@claimed').text).to eq('true')
      end
    end

    context 'Claim device - 2nd' do
      # Step 5: unclaimDevice - Rio
      OwnerManagement.unclaim_device(caller_id, session, 'service', device_serial_rio)

      # Step 6: claimDevice - Rio 2nd
      OwnerManagement.claim_device(caller_id, session, customer_id, device_serial_rio, 'leappad3', '0', 'AlternateKid', rio_kid_id, nil, '5', 'male')

      # Step 7: fetchDevice - Rio 2nd
      fetch_device_res2 = DeviceManagement.fetch_device(caller_id, device_serial_rio, 'leappad3')

      it "Match content of [device/@serial] - #{device_serial_rio}" do
        expect(fetch_device_res2.xpath('//device/@serial').text).to eq(device_serial_rio)
      end

      it 'Match content of [device/@platform] - leappad3' do
        expect(fetch_device_res2.xpath('//device/@platform').text).to eq('leappad3')
      end

      it 'Match content of [/device/profile/@name] - AlternateKid' do
        expect(fetch_device_res2.xpath('//device/profile/@name').text).to eq('AlternateKid')
      end

      it 'Match content of [device/profile/@weak-id] - 1' do
        expect(fetch_device_res2.xpath('//device/profile/@weak-id').text).to eq('1')
      end

      it 'Match content of [device/profile/@slot] - 0' do
        expect(fetch_device_res2.xpath('//device/profile/@slot').text).to eq('0')
      end

      it 'Match content of [device/profile/@grade] - 5' do
        expect(fetch_device_res2.xpath('//device/profile/@grade').text).to eq('5')
      end

      it 'Match content of [device/profile/@claimed] - true' do
        expect(fetch_device_res2.xpath('//device/profile/@claimed').text).to eq('true')
      end
    end
  end

  context 'TC1.1.2 OOBE - LeapReader' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_lr, 'leapreader', '0', 'LeapReaderKid', leap_reader_kid_id, nil, '5')
    end

    context 'Claim device - 2nd' do
      claim_device_single_profile_2nd(caller_id, session, customer_id, device_serial_lr, 'leapreader', '0', 'LeapReaderKid', leap_reader_kid_id)
    end
  end

  context 'TC1.1.3 OOBE - Lex' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_lex, 'emerald', '0', 'EmeraldKid', emerald_kid_id, nil, '5')
    end

    context 'Claim device - 2nd' do
      claim_device_multi_profiles_2nd(caller_id, session, customer_id, device_serial_lex, username, 'emerald', 'EmeraldKid', 'AlternateKid', emerald_kid_id, rio_kid_id)
    end
  end

  context 'TC1.1.4 OOBE - LeapPad' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_lpad, 'leappad', '0', 'LPadKid', lpad_kid_id, nil, '2')
    end

    context 'Claim device - 2nd' do
      claim_device_multi_profiles_2nd(caller_id, session, customer_id, device_serial_lpad, username, 'leappad', 'LPadKid', 'AlternateKid', lpad_kid_id, rio_kid_id)
    end
  end

  context 'TC1.1.5 OOBE - LeapPad2' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_l2, 'leappad2', '0', 'LPad2Kid', lpad2_kid_id, nil, '4')
    end

    context 'Claim device - 2nd' do
      claim_device_multi_profiles_2nd(caller_id, session, customer_id, device_serial_l2, username, 'leappad2', 'LPad2Kid', 'AlternateKid', lpad2_kid_id, rio_kid_id)
    end
  end

  context 'TC1.1.6 OOBE - Leapster2' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_lpad2, 'leapster2', '0', 'L2Kid', l2_kid_id, nil, '1')
    end

    context 'Claim device - 2nd' do
      claim_device_multi_profiles_2nd(caller_id, session, customer_id, device_serial_lpad2, username, 'leapster2', 'L2Kid', 'AlternateKid', l2_kid_id, rio_kid_id)
    end

    context 'Upload device log - Cars2' do
      before :all do
        upload_res = DeviceLogUpload.upload_device_log(caller_id, 'Cars_II_2.log', '0', device_serial_l2, '2014-06-27T14:08:04', 'Cars II 2.log')
      end

      it 'Verify \'uploadDeviceLog\' calls successfully - Cars2' do
        expect(upload_res.xpath('//faultcode').count).to eq(0)
      end
    end

    context 'Upload device log - Rewards' do
      before :all do
        upload_res = DeviceLogUpload.upload_device_log(caller_id, 'Dragons_Rewards.log', '0', device_serial_l2, '2014-06-27T14:08:30', 'Dragons Rewards.log')
      end

      it 'Verify \'uploadDeviceLog\' calls successfully - Dragons_Rewards' do
        expect(upload_res.xpath('//faultcode').count).to eq(0)
      end
    end
  end

  context 'TC1.1.7 OOBE - LeapsterGS' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_gs, 'explorer2', '0', 'GSKid', gs_kid_id, nil, '4')
    end

    context 'Claim device - 2nd' do
      claim_device_multi_profiles_2nd(caller_id, session, customer_id, device_serial_gs, username, 'explorer2', 'GSKid', 'AlternateKid', gs_kid_id, rio_kid_id)
    end
  end

  context 'TC1.1.8 OOBE - Didj' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_didj, 'didj', '0', 'DidjKid', didj_kid_id, nil, '4')
    end

    context 'Claim device - 2nd' do
      claim_device_multi_profiles_2nd(caller_id, session, customer_id, device_serial_didj, username, 'didj', 'DidjKid', 'AlternateKid', didj_kid_id, rio_kid_id)
    end
  end

  context 'TC1.1.9 OOBE - Crammer' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_crammer, 'didj', '0', 'DidjKid', crammer_kid_id, nil, '4')
    end

    context 'Claim device - 2nd' do
      claim_device_multi_profiles_2nd(caller_id, session, customer_id, device_serial_crammer, username, 'didj', 'DidjKid', 'AlternateKid', crammer_kid_id, rio_kid_id)
    end
  end

  context 'TC1.1.10 OOBE - MOSTP' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_mostp, 'storytimepad', '0', 'MOSTPKid', mostp_kid_id, nil, '2')
    end

    context 'Claim device - 2nd' do
      claim_device_single_profile_2nd(caller_id, session, customer_id, device_serial_mostp, 'storytimepad', '0', 'MOSTPKid', mostp_kid_id)
    end
  end

  context 'TC1.1.11 OOBE - MyLeapTop' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_myleaptop, 'leaptop', '0', 'myLeapTopKid', my_leaptop_kid_id, nil, '4')
    end

    context 'Claim device - 2nd' do
      claim_device_single_profile_2nd(caller_id, session, customer_id, device_serial_myleaptop, 'leaptop', '0', 'myLeapTopKid', my_leaptop_kid_id)
    end
  end

  context 'TC1.1.12 OOBE - MyPals' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_pals, 'mypals', '0', 'MyPalsKid', my_pals_kid_id, nil, '4')
    end

    context 'Claim device - 2nd' do
      claim_device_single_profile_2nd(caller_id, session, customer_id, device_serial_pals, 'mypals', '0', 'MyPalsKid', my_pals_kid_id)
    end
  end

  context 'TC1.1.13 OOBE - Tag' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_tag, 'tag', '0', 'TagKid', tag_kid_id, nil, '4')
    end

    context 'Claim device - 2nd' do
      claim_device_single_profile_2nd(caller_id, session, customer_id, device_serial_tag, 'tag', '0', 'TagKid', tag_kid_id)
    end

    context 'Upload device log - Ozzie & Mac Rewards' do
      before :all do
        upload_res = DeviceLogUpload.upload_device_log(caller_id, 'App5_Log_080325_211903.log', '0', device_serial_tag, '2014-06-27T14:08:07', 'POG_ozzieandmack_rewards.bin')
      end

      it 'Verify \'uploadDeviceLog\' calls successfully - Ozzie & Mac Rewards' do
        expect(upload_res.xpath('//faultcode').count).to eq(0)
      end
    end

    context 'Upload device log - Spongebob Rewards' do
      before :all do
        upload_res = DeviceLogUpload.upload_device_log(caller_id, 'SBQ_Spongebob_Rewards.bin', '0', device_serial_tag, '2014-06-27T14:08:20', 'SBQ_SpongeBob_Rewards.bin')
      end

      it 'Verify \'uploadDeviceLog\' calls successfully - Spongebob Rewards' do
        expect(upload_res.xpath('//faultcode').count).to eq(0)
      end
    end
  end

  context 'TC1.1.14 OOBE - LeapPad3' do
    context 'Claim device - 1st' do
      claim_device_1st(caller_id, session, customer_id, device_serial_lpad3, 'leappad3explorer', '0', 'LPad3Kid', lpad3_kid_id, nil, '4')
    end

    context 'Claim device - 2nd' do
      claim_device_multi_profiles_2nd(caller_id, session, customer_id, device_serial_lpad3, username, 'leappad3explorer', 'LPad3Kid', 'AlternateKid', lpad3_kid_id, rio_kid_id)
    end
  end

  context 'TC1.1.15 OOBE - Narnia' do
    context 'Claim device' do
      it "Update Narnia device - Locale: en_US (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial_narnia})" do
        update_narnia(
          caller_id,
          '',
          device_serial_narnia,
          '{
            "mfgsku": "31576-99903",
            "parentemail": "",
            "model": "1",
            "locale": "en_US"
          }',
          '[]',
          device_service_code
        )
      end

      it "Claim device (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_OWNER_NARNIA % device_serial_narnia})" do
        owner_narnia caller_id, session, device_serial_narnia
      end

      it "Update Narnia device - Email: #{email} (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial_narnia})" do
        update_narnia(
          caller_id,
          session,
          device_serial_narnia,
          '{
            "mfgsku": "31576-99903",
            "parentemail": "%s",
            "model": "1",
            "pin": "1111",
            "locale": "en_US"
          }' % email,
          '[{
             "userName": "Test",
             "userGender": "female",
             "userWeakId": 1,
             "userEdu": "PRE",
             "userDob": "2014-3-1"
          }]',
          device_service_code
        )
      end

      fetch_nar_device_1 = nil
      it "Fetch device info (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_FETCH_DEVICE % device_serial_narnia})" do
        fetch_nar_device_1 = fetch_device(caller_id, device_serial_narnia)
      end

      it "Match content of [@devSerial] - #{device_serial_narnia}" do
        expect(fetch_nar_device_1['data']['devSerial']).to eq(device_serial_narnia)
      end

      it "Match content of [@devServiceCode] - #{device_service_code}" do
        expect(fetch_nar_device_1['data']['devServiceCode']).to eq(device_service_code)
      end

      it 'Match content of [@userName] - Test' do
        expect(fetch_nar_device_1['data']['devUsers'][0]['userName']).to eq('Test')
      end

      it 'Match content of [@userWeakId] - 1' do
        expect(fetch_nar_device_1['data']['devUsers'][0]['userWeakId']).to eq(1)
      end

      it 'Match content of [@userSlot] - 0' do
        expect(fetch_nar_device_1['data']['devUsers'][0]['userSlot']).to eq(0)
      end

      it 'Match content of [@userEdu] - PRE' do
        expect(fetch_nar_device_1['data']['devUsers'][0]['userEdu']).to eq('PRE')
      end

      it 'Match content of [@userGender] - female' do
        expect(fetch_nar_device_1['data']['devUsers'][0]['userGender']).to eq('female')
      end

      it 'Check the number of profile - 1' do
        expect(fetch_nar_device_1['data']['devUsers'].count).to eq(1)
      end
    end

    context 'Update device profile' do
      it "Update Narnia device - Add new profile (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial_narnia})" do
        update_narnia(
          caller_id,
          session,
          device_serial_narnia,
          '{
            "mfgsku": "31576-99903",
            "parentemail": "%s",
            "model": "1",
            "pin": "1111",
            "locale": "en_US"
          }' % email,
          '[{
             "userName": "Test-edit",
             "userGender": "male",
             "userWeakId": 1,
             "userEdu": "FOUR",
             "userDob": "2010-3-1"
            },
            {
             "userName": "Test_2",
             "userGender": "male",
             "userWeakId": 2,
             "userEdu": "THRE",
             "userDob": "2010-3-2"
          }]',
          device_service_code
        )
      end

      fetch_nar_device_2 = nil
      it "Fetch device info (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_FETCH_DEVICE % device_serial_narnia})" do
        fetch_nar_device_2 = fetch_device(caller_id, device_serial_narnia)
      end

      it "Match content of [@devSerial] - #{device_serial_narnia}" do
        expect(fetch_nar_device_2['data']['devSerial']).to eq(device_serial_narnia)
      end

      it "Match content of [device / @devServiceCode] - #{device_service_code}" do
        expect(fetch_nar_device_2['data']['devServiceCode']).to eq(device_service_code)
      end

      it 'Check the number of profile - 2' do
        expect(fetch_nar_device_2['data']['devUsers'].count).to eq(2)
      end
    end
  end
end
