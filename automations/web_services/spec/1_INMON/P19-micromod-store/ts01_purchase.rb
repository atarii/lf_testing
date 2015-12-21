require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'device_management'
require 'owner_management'
require 'micromod_store'
require 'package_management'

=begin
Verify Purchase service works correctly
=end

describe "TS01 - Purchase - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  device_serial = DeviceManagement.generate_serial
  package_id = 'PADS-0x001B0057-000000'
  package_name = 'Roly Poly Picnic 2: Treasure Hunt'
  checksum = 'b7a1f8627b539ff4c11abd5aa2f40d95954ee9f8'
  href = 'http://qa-digitalcontent.leapfrog.com/packages/PADS/PADS-0x001B0057-000000.lf3'
  type = 'MicroDownload'
  status = 'installed'
  cost = '1'
  res = nil

  it 'Precondition 1 - register customer' do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res1 = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = xml_register_child_res1.xpath('//child').attr('id').text

    LFCommon.soap_call(
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:endpoint],
      LFSOAP::CONST_INMON_ENDPOINTS[:owner_management][:namespace],
      :claim_device,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'>#{session}</session>
      <device serial='#{device_serial}' auto-create='false' product-id='0' platform='emerald' pin='1111'>
        <profile slot='0' name='profile1' points='0' rewards='0' weak-id='1' uploadable='true' claimed='false' dob='2006-10-31+07:00' grade='3' gender='male' child-id='#{child_id}' auto-create='false'/>
      </device>"
    )
  end

  context 'TC01.001 - purchase - Successful Purchase' do
    device_serial1 = package_id1 = nil

    before :all do
      MicromodStore.purchase(caller_id, device_serial, '0', package_id, package_name, checksum, href, type, status, cost)

      xml_response = PackageManagement.device_inventory(caller_id, 'service', device_serial, '')
      device_serial1 = xml_response.xpath('//device').attr('serial').text
      package_id1 = xml_response.xpath('//device/slot[2]/package').attr('id').text
    end

    it 'Match content of [@serial]' do
      expect(device_serial1).to eq(device_serial)
    end

it 'Match content of [@id]' do
      expect(package_id1).to eq(package_id)
    end
  end

  context 'TC01.002 - purchase - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = MicromodStore.purchase(caller_id2, device_serial, '0', package_id, package_name, checksum, href, type, status, cost)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - purchase - Invalid Device Serial' do
    device_serial3 = 'invalidDeviceSerial##'

    before :all do
      res = MicromodStore.purchase(caller_id, device_serial3, '0', package_id, package_name, checksum, href, type, status, cost)
    end

    it "Verify 'The service call returned with fault: Unknown device serial number' error responses" do
      expect(res).to eq('The service call returned with fault: Unknown device serial number')
    end
  end

  context 'TC01.004 - purchase - Input character into @cost' do
    cost4 = 'characters'

    before :all do
      res = MicromodStore.purchase(caller_id, device_serial, '0', package_id, package_name, checksum, href, type, status, cost4)
    end

    it "Verify 'The service call returned with fault: InvalidRequestFault: price cannot be null' error responses" do
      expect(res).to eq('The service call returned with fault: InvalidRequestFault: price cannot be null')
    end
  end

  context 'TC01.005 - purchase - Input out of boundary into @cost - positive' do
    cost5 = ''

    before :all do
      res = MicromodStore.purchase(caller_id, device_serial, '0', package_id, package_name, checksum, href, type, status, cost5)
    end

    it "Verify 'The service call returned with fault: InvalidRequestFault: price cannot be null' error responses" do
      expect(res).to eq('The service call returned with fault: InvalidRequestFault: price cannot be null')
    end
  end

  context 'TC01.006 - purchase - Input out of boundary into @cost - negative' do
    cost6 = '-200'

    begin
      before :all do
        res = MicromodStore.purchase(caller_id, device_serial, '0', package_id, package_name, checksum, href, type, status, cost6)
      end
    rescue Savon::SOAPFault
      it 'Verify SOAP Fault responses' do
        expect(res).to eq('SOAP Fault')
      end
    else
      it 'Report bug' do
        expect('#36385: Web Services: micromod-store: purchase: The service accepts negative value of @cost').to eq(res)
      end
    end
  end

  context 'TC01.007 - purchase - Invalid PackageId' do
    package_id7 = 'invalid'

    before :all do
      res = MicromodStore.purchase(caller_id, device_serial, '0', package_id7, package_name, checksum, href, type, status, cost)
    end

    it "Verify 'The service call returned with fault: Unable to process the request: an invalid package id was received: invalid' error responses" do
      expect(res).to eq('The service call returned with fault: Unable to process the request: an invalid package id was received: invalid')
    end
  end

  context 'TC01.008 - purchase - Empty @href' do
    href8 = ''

    before :all do
      res = MicromodStore.purchase(caller_id, device_serial, '0', package_id, package_name, checksum, href8, type, status, cost)
    end

    it 'Report bug' do
      expect('#36386: Web Services: micromod-store: purchase: The services call  return SOAP fault with SQL information in faultstring when calling service with empty @href, @checksum value').to eq(res)
    end
  end

  context 'TC01.009 - purchase - Empty @checksum' do
    checksum9 = ''

    before :all do
      res = MicromodStore.purchase(caller_id, device_serial, '0', package_id, package_name, checksum9, href, type, status, cost)
    end

    it 'Report bug' do
      expect('#36386: Web Services: micromod-store: purchase: The services call  return SOAP fault with SQL information in faultstring when calling service with empty @href, @checksum value').to eq(res)
    end
  end

  context 'TC01.010 - purchase - Invalid @type' do
    type10 = 'invalid'

    before :all do
      res = MicromodStore.purchase(caller_id, device_serial, '0', package_id, package_name, checksum, href, type10, status, cost)
    end

    it "Verify 'The service call returned with fault: WsDevicePackage.type must be the value MicroDownload" do
      expect(res).to eq('The service call returned with fault: WsDevicePackage.type must be the value MicroDownload')
    end
  end
end
