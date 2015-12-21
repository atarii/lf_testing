require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'
require 'owner_management'
require 'device_management'
require 'soft_good_management'
require 'device_profile_management'
require 'pin_management'

=begin
Verify redeemGiftPackages service works correctly
=end

start_browser

describe "TS04 - redeemGiftPackages - #{Misc::CONST_ENV}" do
  cus_id = nil
  device_serial = DeviceManagement.generate_serial
  package_id_inp = '58129-96914'
  pin = nil
  res = nil

  before :all do
    reg_cus_response =  CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    cus_id = cus_info[:id]

    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])

    reg_chi_response = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_id)
    child_id = reg_chi_response.xpath('//child/@id').text

    OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_id, device_serial, 'leappad', '0', 'profile', child_id)
    DeviceProfileManagement.assign_device_profile(Misc::CONST_CALLER_ID, cus_id, device_serial, 'leappad', '0', 'profile', child_id)
    DeviceManagement.update_profiles(Misc::CONST_CALLER_ID, session, 'service', device_serial, 'leappad', '0', 'profile', child_id)
    LFCommon.new.login_to_lfcom(cus_info[:username], cus_info[:password])
  end

  context 'TC04.001 - redeemGiftPackages - Successful Response' do
    package_id_inp = '58129-96914'

    license_type_res = nil
    license_id_res = nil
    package_id_res = nil

    before :all do
      sof_goo_res = SoftGoodManagement.reserve_gift_pin Misc::CONST_CALLER_ID
      pin = sof_goo_res.xpath('//reserved-pin').text

      SoftGoodManagement.purchase_gift_pin(Misc::CONST_CALLER_ID, cus_id, pin)
      pin_res = PINManagement.redeem_gift_packages(Misc::CONST_CALLER_ID, cus_id, package_id_inp, pin)

      license_type_res = pin_res.xpath('//licenses/license/@type').text
      license_id_res = pin_res.xpath('//licenses/license/@id').text
      package_id_res = pin_res.xpath('//licenses/license/@package-id').text
    end

    it 'Verify license type is gift' do
      expect(license_type_res).to eq('gift')
    end

    it 'Verify license id is not empty' do
      expect(license_id_res.size > 0).to eq(true)
    end

    it 'Verify package-id is correct' do
      expect(package_id_res).to eq(package_id_res)
    end
  end

  context 'TC04.002 - redeemGiftPackages - Invalid CallerID' do
    before :all do
      res = PINManagement.redeem_gift_packages('invalid', cus_id, package_id_inp, pin)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC04.003 - redeemGiftPackages - Invalid Request' do
    before :all do
      res = PINManagement.redeem_gift_packages(Misc::CONST_CALLER_ID, cus_id, package_id_inp, '')
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC04.004 - redeemGiftPackages - Redeemed PIN' do
    before :all do
      res = PINManagement.redeem_gift_packages(Misc::CONST_CALLER_ID, cus_id, package_id_inp, pin)
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC04.005 - redeemGiftPackages - Access Denied' do
    before :all do
      res = PINManagement.redeem_gift_packages(Misc::CONST_CALLER_ID, 1111, package_id_inp, pin)
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC04.006 - redeemGiftPackages - Cust-key is null' do
    before :all do
      res = PINManagement.redeem_gift_packages(Misc::CONST_CALLER_ID, '', package_id_inp, pin)
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC04.007 - redeemGiftPackages - Cust-key is so long' do
    before :all do
      res = PINManagement.redeem_gift_packages(Misc::CONST_CALLER_ID, '1111111111111111122', package_id_inp, pin)
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC04.008 - redeemGiftPackages - Cust-key is special characters' do
    before :all do
      res = PINManagement.redeem_gift_packages(Misc::CONST_CALLER_ID, '!@#$%^&*', package_id_inp, pin)
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC04.009 - redeemGiftPackages - Pin-text is negative numbers' do
    before :all do
      res = PINManagement.redeem_gift_packages(Misc::CONST_CALLER_ID, cus_id, package_id_inp, '-111111')
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC04.010 - redeemGiftPackages - Pin-text is so long' do
    before :all do
      res = PINManagement.redeem_gift_packages(Misc::CONST_CALLER_ID, cus_id, package_id_inp, '1111111111111111122333333335555555')
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end

  context 'TC04.011 - redeemGiftPackages - Pin-text is special characters' do
    before :all do
      res = PINManagement.redeem_gift_packages(Misc::CONST_CALLER_ID, cus_id, package_id_inp, '!@#$%^&*')
    end

    it 'Verify faultstring is returned' do
      expect('#36326: Web Services: pin-management: redeemGift: The services should have SOAP Fault mechanism to handle the SOAP fault response instead of showing data and tables information').to eq(res)
    end
  end
end
