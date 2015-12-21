require File.expand_path('../../../spec_helper', __FILE__)
require 'owner_management'
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_profile_management'
require 'device_management'

=begin
Verify ClaimDevice service works correctly
=end

describe "TS01 - Claim Device - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:namespace]
  session = nil
  claim_res = nil
  dev_serial = nil
  cus_info = nil

  before :all do
    reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
  end

  context 'TC01.001 - claim device - Successful Response' do
    dev_serial = DeviceManagement.generate_serial
    platform = nil
    activated_by = nil
    res_serial1 = nil

    before :all do
      claim_res = OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_info[:id], dev_serial, 'leappad3', '0', 'Child01', '44444', Time.now, '1')

      xml_list_nominated_devices_res = DeviceManagement.list_nominated_devices(Misc::CONST_CALLER_ID, session, 'service')
      res_serial1 = xml_list_nominated_devices_res.xpath('//device[1]').attr('serial').text

      platform = claim_res.xpath('//claimed-device/@platform').text
      activated_by = claim_res.xpath('//claimed-device/@activated-by').text
    end

    it 'Check platform' do
      expect(platform).to eq('leappad3')
    end

    it 'Check activated by' do
      expect(activated_by).to eq(cus_info[:id])
    end

    it 'Check device serial' do
      expect(res_serial1).to eq(dev_serial)
    end
  end

  context 'TC01.002 - claim device - Invalid CallerID' do
    before :all do
      claim_res = OwnerManagement.claim_device('invalid', session, cus_info[:id], dev_serial, 'leappad3', '0', 'Child01', '44444')
    end

    it "Check error message 'Error while checking caller id'" do
      expect(claim_res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - claim device - Invalid session' do
    before :all do
      claim_res = OwnerManagement.claim_device(Misc::CONST_CALLER_ID, 'invalid', cus_info[:id], dev_serial, 'leappad3', '0', 'Child01', '44444')
    end

    it 'Check error message: AccessDeniedFault: invalid_session' do
      expect(claim_res).to eq('AccessDeniedFault invalid session')
    end
  end

  context 'TC01.004 - claim device - invalid platform' do
    before :all do
      claim_res = OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_info[:id], dev_serial, 'invalid', '0', 'Child01', '44444')
    end

    it 'Check error message: InvalidRequestFault' do
      expect(claim_res).to eq('InvalidRequestFault')
    end
  end

  context 'TC01.005 - claim device - Invalid slot' do
    before :all do
      claim_res = OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_info[:id], dev_serial, 'leappad3', 'invalid', 'Child01', '44444')
    end

    it 'Check error message: Unmarshalling Error: Not a number: Invalid' do
      expect(claim_res.strip).to eq('Unmarshalling Error: Not a number: invalid')
    end
  end

  context 'TC01.006 - claim device - Invalid DOB' do
    before :all do
      claim_res = OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_info[:id], dev_serial, 'leappad3', '0', 'Child01', '44444', 'invalid')
    end

    it 'Check error message: invalid dob' do
      if (claim_res != 'Invalid DOB')
        expect(claim_res).to eq('Issue #32')
      else
        expect(claim_res).to eq('Invalid DOB')
      end
    end
  end

  context 'TC01.007 - claim device - Invalid week-id: -1321321232121321321654654' do
    before :all do
      claim_res = LFCommon.soap_call(
        endpoint,
        namespace,
        :claim_device,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <device serial='#{dev_serial}' product-id='0' platform='leappad3' auto-create='true' pin=''>
           <profile claimed='false' slot='0' points='0' rewards='0' weak-id='-1321321232121321321654654' name='Child01' dob='#{Time.now}' grade='1' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
        </device>"
      )
    end

    it 'Check error message: Invalid week-id' do
      if (claim_res != 'Invalid week-id')
        expect(claim_res).to eq('Issue #31')
      else
        expect(claim_res).to eq('Invalid week-id')
      end
    end
  end

  context 'TC01.008 - claim device - Invalid Grade: 2378949812384723897489723894723897489237489273984728937489237484234234234234234234234234291213' do
    before :all do
      claim_res = LFCommon.soap_call(
        endpoint,
        namespace,
        :claim_device,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <device serial='#{dev_serial}' product-id='0' platform='leappad3' auto-create='true' pin=''>
           <profile claimed='false' slot='0' points='0' rewards='0' weak-id='0' name='Child01' dob='#{Time.now}' grade='2378949812384723897489723894723897489237489273984728937489237484234234234234234234234234291213' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
        </device>"
      )
    end

    it 'Check error message: Invalid grade' do
      if (claim_res != 'Invalid grade')
        expect(claim_res).to eq('Issue #31')
      else
        expect(claim_res).to eq('Invalid grade')
      end
    end
  end

  context 'TC01.009 - claim device - invalid points: 2378949812384723897489723894723897489237489273984728937489237484234234234234234234234234291213' do
    before :all do
      claim_res = LFCommon.soap_call(
        endpoint,
        namespace,
        :claim_device,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <device serial='#{dev_serial}' product-id='0' platform='leappad3' auto-create='true' pin=''>
           <profile claimed='false' slot='0' points='2378949812384723897489723894723897489237489273984728937489237484234234234234234234234234291213' rewards='0' weak-id='0' name='Child01' dob='#{Time.now}' grade='1' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
        </device>"
      )
    end

    it 'Check error message: Invalid points' do
      if (claim_res != 'Invalid points')
        expect(claim_res).to eq('Issue #31')
      else
        expect(claim_res).to eq('Invalid points')
      end
    end
  end

  context 'TC01.010 - claim device - Invalid rewards' do
    before :all do
      claim_res = LFCommon.soap_call(
        endpoint,
        namespace,
        :claim_device,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <device serial='#{dev_serial}' product-id='0' platform='leappad3' auto-create='true' pin=''>
           <profile claimed='false' slot='0' points='0' rewards='-131321346546460' weak-id='0' name='Child01' dob='#{Time.now}' grade='1' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
        </device>"
      )
    end

    it 'Check error message: Invalid rewards' do
      if (claim_res != 'Invalid rewards')
        expect(claim_res).to eq('Issue #32')
      else
        expect(claim_res).to eq('Invalid rewards')
      end
    end
  end

  context 'TC01.011 - claim device - claim linked device' do
    before :all do
      reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
      cus_info = CustomerManagement.get_customer_info(reg_cus_response)

      session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])

      claim_res = LFCommon.soap_call(
        endpoint,
        namespace,
        :claim_device,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <device serial='#{dev_serial}' product-id='0' platform='leappad3' auto-create='true' pin=''>
           <profile claimed='false' slot='0' points='0' rewards='0' weak-id='0' name='Child01' dob='#{Time.now}' grade='1' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
        </device>"
      )
    end

    it "Check error message: The device is already claimed, serial=#{dev_serial}" do
      expect(claim_res).to eq("The device is already claimed, serial=#{dev_serial}")
    end
  end

  context 'TC01.012 - claim device - claim device with more than 3 profiles' do
    before :all do
      dev_serial = DeviceManagement.generate_serial
      reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
      cus_info = CustomerManagement.get_customer_info(reg_cus_response)
      session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])

      claim_res = LFCommon.soap_call(
        endpoint,
        namespace,
        :claim_device,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <device serial='#{dev_serial}' product-id='0' platform='leappad3' auto-create='true' pin=''>
           <profile claimed='true' slot='0' points='0' rewards='0' weak-id='0' name='Child01' dob='#{Time.now}' grade='1' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
           <profile claimed='true' slot='1' points='0' rewards='0' weak-id='1' name='Child02' dob='#{Time.now}' grade='1' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
           <profile claimed='true' slot='2' points='0' rewards='0' weak-id='2' name='Child03' dob='#{Time.now}' grade='1' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
           <profile claimed='true' slot='3' points='0' rewards='0' weak-id='3' name='Child04' dob='#{Time.now}' grade='1' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
        </device>"
      )

    end

    it 'Check error message' do
      if (claim_res != 'Fault')
        expect(claim_res).to eq('Issue #79')
      else
        expect(claim_res).to eq('Fault')
      end
    end
  end

  context 'TC01.013 - claim device - claim single device with more than 1 profiles' do
    before :all do
      dev_serial = DeviceManagement.generate_serial
      reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
      cus_info = CustomerManagement.get_customer_info(reg_cus_response)
      session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])

      claim_res = LFCommon.soap_call(
        endpoint,
        namespace,
        :claim_device,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <device serial='#{dev_serial}' product-id='0' platform='leapreader' auto-create='true' pin=''>
           <profile claimed='false' slot='0' points='0' rewards='0' weak-id='0' name='Child01' dob='#{Time.now}' grade='1' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
           <profile claimed='true' slot='1' points='0' rewards='0' weak-id='0' name='Child01' dob='#{Time.now}' grade='1' gender='male' child-id='44444' auto-create='true' uploadable='false'/>
        </device>"
      )
    end

    it "Check error message: The device is already claimed, serial=#{dev_serial}" do
      if (claim_res != 'Fault')
        expect(claim_res).to eq('Issue #79')
      else
        expect(claim_res).to eq('Fault')
      end
    end
  end

  context 'TC01.014 - claim device - out of range slot: slot = 6' do
    before :all do
      dev_serial = DeviceManagement.generate_serial
      reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
      cus_info = CustomerManagement.get_customer_info(reg_cus_response)
      session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
      claim_res = OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_info[:id], dev_serial, 'leappad3', '6', 'Child01', '44444')
    end

    it 'Check error message' do
      if (claim_res != 'Fault')
        expect(claim_res).to eq('Issue #79')
      else
        expect(claim_res).to eq('Fault')
      end
    end
  end

  context 'TC01.015 - claim device - Profile and child' do

    child_name = "Ronaldo#{LFCommon.get_current_time}"
    child_id = nil
    dev_res = nil
    cus_info = nil
    platform = profile_name = profile_grade = profile_claimed = nil

    before :all do
      dev_serial = DeviceManagement.generate_serial
      reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
      cus_info = CustomerManagement.get_customer_info(reg_cus_response)
      session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
      claim_res = OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_info[:id], dev_serial, 'leappad3', '0', 'Child01', '44444', Time.now, '1')
      fetch_dev_res = DeviceManagement.fetch_device(Misc::CONST_CALLER_ID, dev_serial, 'leappad3')

      platform = fetch_dev_res.xpath('//device/@platform').text
      profile_name = fetch_dev_res.xpath('//profile/@name').text
      profile_grade = fetch_dev_res.xpath('//profile/@grade').text
    end

    it 'Check platform' do
      expect(platform).to eq('leappad3')
    end

    it 'Check profile name' do
      expect(profile_name).to eq('Child01')
    end

    it 'Check profile grade' do
      expect(profile_grade).to eq('1')
    end

    it 'Register child' do
      child_res = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_info[:id], child_name)
      child_id = child_res.xpath('//child/@id').text
    end

    it 'Assign device profile' do
      DeviceProfileManagement.assign_device_profile(Misc::CONST_CALLER_ID, cus_info[:id], dev_serial, 'leappad3', 1, 'Child01', child_id)
    end

    it 'Update device profile' do
      DeviceManagement.update_profiles(Misc::CONST_CALLER_ID, session, 'service', dev_serial, 'leappad3', '1', child_name, child_id)
    end

    it 'Fetch device after assign and update profile for child' do
      dev_res = DeviceManagement.fetch_device(Misc::CONST_CALLER_ID, dev_serial, 'leappad3')
    end

    it 'Check profile slot' do
      expect(dev_res.xpath('//profile/@slot').text).to eq('1')
    end

    it 'Check profile name' do
      expect(dev_res.xpath('//profile/@name').text).to eq(child_name)
    end
  end
end
