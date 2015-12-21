require File.expand_path('../../../spec_helper', __FILE__)
require 'device_profile_content'
require 'customer_management'
require 'authentication'
require 'child_management'
require 'owner_management'
require 'device_management'
require 'container_management'
require 'asset'

=begin
Verify fetchContainer service works correctly
=end

describe "TS02 - fetchContainer - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  device_serial = DeviceManagement.generate_serial
  password = '123456'
  platform = 'leappad'
  slot = '1'
  profile_name = 'profile'
  customer_id = container_id = nil
  res = nil

  it 'Precondition 1 - Register customer' do
    register_cus_res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_register_cus_res = CustomerManagement.get_customer_info(register_cus_res)
    customer_id = arr_register_cus_res[:id]

    xml_acquire_session_res = Authentication.acquire_service_session(caller_id, username, password)
    session = xml_acquire_session_res.xpath('//session').text

    xml_register_child_res = ChildManagement.register_child(caller_id, session, customer_id)
    child_id = xml_register_child_res.xpath('//child').attr('id').text

    OwnerManagement.claim_device(caller_id, session, customer_id, device_serial, platform, slot, profile_name, child_id)
  end

  context 'Precondition 2 - add package to container' do
    xml_create_container_res = ContainerManagement.create_container(caller_id, customer_id)
    container_id = xml_create_container_res.xpath('//container').attr('id').text

    ContainerManagement.add_package(caller_id, container_id, 'Chicka Chicka Boom Boom', 'SFTW', 'http://www.leapfrog.com/etc/medialib/inmon/leapfrog/connectedproducts/tag/packages.Par.29811.File.dat/TAGR-0x000b001a-000000.lfp', '84790a502b12a6c91057c68c3567f7c3ed6c9e1c')
  end

  context 'TC02.001 - fetchContainer - Successful Response' do
    package_num = nil

    before :all do
      xml_res = Asset.fetch_container(caller_id, '', container_id)
      package_num = xml_res.xpath('//package').count
    end

    it "Verify 'fetchContainer' calls successfully" do
      expect(package_num).not_to eq(0)
    end
  end

  context 'TC02.002 - fetchContainer - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = Asset.fetch_container(caller_id2, '', container_id)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC02.003 - fetchContainer - Invalid ContainerID' do
    container_id3 = 'invalid'

    before :all do
      res = Asset.fetch_container(caller_id, '', container_id3)
    end

    it "Verify 'Invalid container id=invalid' error message responses" do
      expect(res).to eq('Invalid container id=invalid')
    end
  end

  context 'TC02.004 - fetchContainer - Not add package' do
    package_num4 = nil

    before :all do
      xml_create_container_res = ContainerManagement.create_container(caller_id, customer_id)
      container_id = xml_create_container_res.xpath('//container').attr('id').text

      xml_response = Asset.fetch_container(caller_id, '', container_id)
      package_num4 = xml_response.xpath('//package').count
    end

    it "Verify 'fetchContainer' calls successfully" do
      expect(package_num4).to eq(0)
    end
  end

  context 'TC02.005 - fetchContainer - Contain id is null' do
    container_id5 = ''

    before :all do
      res = Asset.fetch_container(caller_id, '', container_id5)
    end

    it "Verify 'Invalid container id=' error message responses" do
      expect(res).to eq('Invalid container id=')
    end
  end

  context 'TC02.006 - fetchContainer - Contain id is so long' do
    container_id6 = 'The next big thing, but also the next thing We have started development on the next big release, with more REST testing improvements. We have reinforced the team, and now we are splitting it into two: a smaller team focused on 4.6.2 and a larger team focusing on the next big release'

    before :all do
      res = Asset.fetch_container(caller_id, '', container_id6)
    end

    it "Verify 'Invalid container id=...' error message responses" do
      expect(res).to eq('Invalid container id=' + container_id6)
    end
  end

  context 'TC02.007 - fetchContainer - Contain id is negative numbers' do
    container_id7 = '-12676'
    package_num7 = nil

    before :all do
      xml_res = Asset.fetch_container(caller_id, '', container_id7)
      package_num7 = xml_res.xpath('//package').count
    end

    it 'Verify no value responses' do
      expect(package_num7).to eq(0)
    end
  end

  context 'TC02.008 - fetchContainer - Contain id is special characters' do
    container_id8 = '@#$$'

    before :all do
      res = Asset.fetch_container(caller_id, '', container_id8)
    end

    it "Verify 'Invalid container id=...' error message responses" do
      expect(res).to eq('Invalid container id=' + container_id8)
    end
  end
end
