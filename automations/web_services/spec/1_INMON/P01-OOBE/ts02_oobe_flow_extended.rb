require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'owner_management'
require 'device_management'
require 'device_profile_management'

=begin
Check OOBE (extended): Account Setup, claim device, un-claim device,...
=end

# Define common method
def claim_device_already_claimed(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id)
  claim_res = nil
  before :all do
    claim_res = OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id)
  end

  it "Match content of [@faultstring] - The device is already claimed, serial=#{device_serial}" do
    expect(claim_res).to eq("The device is already claimed, serial=#{device_serial}")
  end
end

describe "TS1.2 - OOBE flow Extended - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  device_serial = 'RIO' + DeviceManagement.generate_serial
  header_xml =
    '<caller-id>%s</caller-id>
    <session type="service">%s</session>'

  # Existing customer info
  username1, password1, session1 = 'INpsc06271413081118US@leapfrog.test', '123456', nil

  # New customer info
  username2 = email2 = LFCommon.generate_email
  screen_name2, password2 = CustomerManagement.generate_screenname, '123456'
  customer_id2 = session2 = child_id2 = nil

  context 'TC1.2.0 - OOBE Extended - 1st Account Setup' do
    before :all do
      session1 = Authentication.get_service_session(caller_id, username1, password1)
    end

    it 'Check session returns successfully' do
      expect(session1).not_to eq('')
    end
  end

  context 'TC1.2.1 - OOBE Extended - Unclaim LeapPad Ultra By 1st Account' do
    fetch_device_res = nil

    before :all do
      # Step 1: unclaimDevice - Rio by 1st Account
      OwnerManagement.unclaim_device(caller_id, session1, 'service', device_serial)

      # Step 2: fetchDevice - Device Info After Unclaim
      fetch_device_res = DeviceManagement.fetch_device(Misc::CONST_CALLER_ID, device_serial, 'leappad3')
    end

    it "Match content [@serial] - #{device_serial}" do
      expect(fetch_device_res.xpath('//device/@serial').text).to eq(device_serial)
    end

    it 'Match content [@activated-by] - 0' do
      expect(fetch_device_res.xpath('//device/@activated-by').text).to eq('0')
    end
  end

  context 'TC1.2.2 - OOBE Extended - 2nd Account Setup' do
    # Step 1: registerCustomer - 2nd Customer
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name2, email2, username2)
    xml_register_cus = CustomerManagement.get_customer_info(register_cus_res)
    customer_id2 = xml_register_cus[:id]

    it "Match content of [@username] - registerCustomer - #{username2}" do
      expect(xml_register_cus[:username]).to eq(username2)
    end

    it "Match content of [@password] - registerCustomer - #{password2}" do
      expect(xml_register_cus[:password]).to eq(password2)
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

    # Step 2: fetchCustomer - 2nd Customer Info
    fetch_cus_res = CustomerManagement.fetch_customer(caller_id, customer_id2)

    it "Match content of [@id] - fetchCustomer - #{customer_id2}" do
      expect(fetch_cus_res.xpath('//customer/@id').text).to eq(customer_id2)
    end

    it "Match content of [@username] - fetchCustomer - #{username2}" do
      expect(fetch_cus_res.xpath('//customer/credentials/@username').text).to eq(username2)
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

    # Step 3: acquireServiceSession - 2nd Customer Login
    session2 = Authentication.get_service_session(caller_id, username2, password2)

    it 'Check session returns successfully' do
      expect(session2).not_to eq('')
    end
  end

  context 'TC1.2.3 - OOBE Extended - Claim LeapPad Ultra By 2nd Account' do
    # Step 1: claimDevice - Rio by 2nd Account
    LFCommon.soap_call(
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:endpoint],
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:namespace],
      :claim_device,
      "#{header_xml % [caller_id, session2]}
      <device serial='#{device_serial}' product-id='0' platform='leappad3' auto-create='true'>
        <profile slot='0' name='RioKid' uploadable='false' claimed='false' dob='2007-05-21-07:00' grade='1' gender='male' auto-create='true' weak-id='0' points='0' rewards='0' child-id='00112233'/>
        <properties>
          <property key='erasesize' value='8192'/>
          <property key='parentemail' value='#{username2}'/><property key='model' value='1'/>
          <property key='writesize' value='2097152'/>
        </properties>
      </device>"
    )

    it 'Ignore will-not-fix defect: UPC# 35478 Web services: OwnerManagementPort: claimDevice: Missing "profile" element in the service response when calling claimDevice service with valid values' do
    end

    # Step 2: updateProfiles - RioKid
    LFCommon.soap_call(
      LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:endpoint],
      LFSOAP::CONST_INMON_ENDPOINTS[:device_management][:namespace],
      :update_profiles,
      "#{header_xml % [caller_id, session2]}
      <device serial='#{device_serial}' product-id='0' platform='leappad3'>
        <profile slot='0' name='RioKid' points='0' rewards='0' weak-id='0' uploadable='false' claimed='false'/>
        <properties>
          <property key='parentemail' value='#{username2}'/>
        </properties>
      </device>"
    )

    # Step 3: fetchDevice - Device Info
    fetch_device_res = DeviceManagement.fetch_device(caller_id, device_serial, 'leappad3')

    it "Match content of [@serial] = '#{device_serial}'" do
      expect(fetch_device_res.xpath('//device/@serial').text).to eq(device_serial)
    end

    it "Match content of [@value] = '#{username2}'" do
      expect(fetch_device_res.xpath('//device[1]/properties[1]/property[2]/@value').text).to eq(username2)
    end

    # Step 4: assignDeviceProfiles - RioKid
    DeviceProfileManagement.assign_device_profile(caller_id, customer_id2, device_serial, 'leappad3', '0', 'RioKid', child_id2)
  end

  context 'TC1.2.4 - Incorrectly Claim LeapPad Ultra By 1st Account' do
    # Step 1: acquireServiceSession - 1st Account Login
    session1 = Authentication.get_service_session(caller_id, username1, password1)

    it 'Check session returns successfully' do
      expect(session1).not_to eq('')
    end

    # Step 2: claimDevice - Rio by 1st Account
    claim_res = LFCommon.soap_call(
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:endpoint],
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:namespace],
      :claim_device,
      "#{header_xml % [caller_id, session1]}
      <device serial='#{device_serial}' product-id='0' platform='leappad3' auto-create='true'>
        <profile slot='0' name='RioKid' uploadable='false' claimed='false' dob='2007-05-21-07:00' grade='1' gender='male' auto-create='true' weak-id='0' points='0' rewards='0' child-id='00112233'/>
        <properties>
          <property key='erasesize' value='8192'/>
          <property key='parentemail' value='#{username1}'/><property key='model' value='1'/>
          <property key='writesize' value='2097152'/>
          </properties>
      </device>"
    )

    it "Match content of [@faultstring] - The device is already claimed, serial=#{device_serial}" do
      expect(claim_res).to eq("The device is already claimed, serial=#{device_serial}")
    end
  end

  context 'TC1.2.5 - Incorrectly Claim Devices - Precondition' do
    # Step 1: acquireServiceSession - 2nd Account Login
    session2 = Authentication.get_service_session(caller_id, username2, password2)

    it 'Check session returns successfully' do
      expect(session2).not_to eq('')
    end
  end

  context 'TC1.2.6 - Incorrectly Claim LeapReader By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'LRxyz123321xyzpsc0627141053', 'leapreader', '0', 'LeapReaderKid', '11223344')
  end

  context 'TC1.2.7 - Incorrectly Claim Lex By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'EMxyz123321xyzpsc0627141308', 'emerald', '0', 'EmeraldKid', '11223344')
  end

  context 'TC1.2.8 - Incorrectly Claim LeapPad By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'LPxyz123321xyzpsc0627141308', 'leappad', '0', 'LPadKid', '11223344')
  end

  context 'TC1.2.9 - Incorrectly Claim LeapPad2 By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'LP2yz123321xyzpsc0627141308', 'leappad2', '0', 'LPad2Kid', '11223344')
  end

  context 'TC1.2.10 - Incorrectly Claim Leapster2 By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'L2xyz123321xyzpsc0627141308', 'leapster2', '0', 'L2Kid', '11223344')
  end

  context 'TC1.2.11 - Incorrectly Claim LeapsterGS By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'LGSyz123321xyzpsc0627141308', 'explorer2', '0', 'GSKid', '11223344')
  end

  context 'TC1.2.12 - Incorrectly Claim Didj By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'DIDJz123321xyzpsc0627141308', 'didj', '0', 'DidjKid', '11223344')
  end

  context 'TC1.2.13 - Incorrectly Claim Crammer By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'CRAMpsc0627141308', 'crammer', '0', 'Crammer', '11223344')
  end

  context 'TC1.2.14 - Incorrectly Claim MOSTP By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'MOSTz123321xyzpsc0627141308', 'storytimepad', '0', 'MOSTPKid', '11223344')
  end

  context 'TC1.2.15 - Incorrectly Claim MyLeapTop By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'MLTyz123321xyzpsc0627141308', 'leaptop', '0', 'MyLeapTopKid', '11223344')
  end

  context 'TC1.2.16 - Incorrectly Claim MyPals By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'PALSz123321xyzpsc0627141308', 'mypals', '0', 'MyPalsKid', '11223344')
  end

  context 'TC1.2.17 - Incorrectly Claim Tag By 2nd Account' do
    claim_device_already_claimed(caller_id, session2, customer_id2, 'TAGyz123321xyzpsc0627141308', 'tag', '0', 'TagKid', '11223344')
  end

  context 'TC1.2.18 - Incorrectly Claim Narnia By 2nd Account' do
    claim_res = nil
    narnia_serial = 'NARNIA123321xyzpsc0627141308'
    it "Claim device (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_OWNER_NARNIA % narnia_serial})" do
      claim_res = owner_narnia caller_id, session2, narnia_serial
    end

    it "Match content of [@faultstring] - Cannot complete Claim Process. Device with serial# #{narnia_serial} is already owned by Customer - Id: (2768652)" do
      expect(claim_res['data']['message']).to eq("Cannot complete Claim Process. Device with serial# #{narnia_serial} is already owned by Customer - Id: (2768652)")
    end
  end
end
