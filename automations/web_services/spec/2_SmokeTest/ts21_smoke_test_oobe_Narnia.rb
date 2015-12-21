require File.expand_path('../../spec_helper', __FILE__)
require 'license_management'
require 'package_management'
require 'device_management'
require 'parent_management'

=begin
Narnia: OOBE flow checking
=end

describe "TS21 - OOBE Smoke Test - Narnia - #{Misc::CONST_ENV}" do
  callerid = Misc::CONST_REST_CALLER_ID
  device_serial = DeviceManagement.generate_serial 'NARNIA'
  locale = 'en_US'
  dev_service_code = 'android1'
  email = LFCommon.generate_email
  firstname = 'ltrc'
  lastname = 'vn'
  password = '123456'
  email_optin = 'true'
  session = response = parent_id = nil
  package_id = '58350-96914' # Play with Pocoyo
  pin = '1111'

  context "1. Reset device device serial - #{device_serial} (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_RESET_NARNIA % device_serial})" do
    before :all do
      response = reset_narnia callerid, device_serial
    end

    it 'Verify response status is "false"' do
      expect(response['status']).to eq(false)
    end

    it 'Verify response faultCode is "DEVUNCLAIMED"' do
      expect(response['data']['faultCode']).to eq('DEVUNCLAIMED')
    end

    it "Verify response message is \"unknown device: #{device_serial}\"" do
      expect(response['data']['message']).to eq("unknown device: #{device_serial}")
    end
  end

  context "2. Put locale #{locale} to server after device is connected to wifi (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
    before :all do
      response = update_narnia(
        callerid,
        '',
        device_serial,
        '{
          "mfgsku": "31576-99903",
          "parentemail": "",
          "model": "1",
          "locale": "en_US"
        }',
        '[]',
        dev_service_code
      )
    end

    it 'Verify response status is "true"' do
      expect(response['status']).to eq(true)
    end

    it "Verify locale match: locale - #{locale}" do
      expect(response['data']['devProps']['locale']).to eq(locale)
    end
  end

  context "3. Create parent account - #{email} (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_CREATE_PARENT})" do
    before :all do
      response = ParentManagementRest.create_parent(callerid, email, password, firstname, lastname, email_optin, locale)
      session = response['data']['token']
      parent_id = response['data']['parent']['parentID']
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it 'Verify parent id is created' do
      expect(response['data']['parent']['parentID']).not_to be_empty
    end

    it "Verify parent email is \"#{email}\"" do
      expect(response['data']['parent']['parentEmail']).to eq(email)
    end

    it "Verify parent first name is \"#{firstname}\"" do
      expect(response['data']['parent']['parentFirstName']).to eq(firstname)
    end

    it "Verify parent last name is \"#{lastname}\"" do
      expect(response['data']['parent']['parentLastName']).to eq(lastname)
    end

    it "Verify parent locale is \"#{locale}\"" do
      expect(response['data']['parent']['parentLocale']).to eq(locale)
    end
  end

  context "4. Set device owner id (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_OWNER_NARNIA % device_serial})" do
    before :all do
      response = owner_narnia callerid, session, device_serial
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it 'Verify devOwnerId > 0' do
      expect(response['data']['devOwnerId']).to be > 0
    end
  end

  context "5. Claim device (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
    before :all do
      response = update_narnia(
        callerid,
        '',
        device_serial,
        '{
          "mfgsku": "31576-99903",
          "parentemail": "%s",
          "model": "1",
          "locale": "en_US"
        }' % email,
        '[]',
        dev_service_code
      )
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it "Verify response parent email is \"#{email}\"" do
      expect(response['data']['devProps']['parentemail']).to eq(email)
    end

    it "Verify response devOwnerStatus is \"ACTIVE\"" do
      expect(response['data']['devOwnerStatus']).to eq('ACTIVE')
    end
  end

  context "6. Put parent pin = #{pin} to device (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
    before :all do
      response = update_narnia(
        callerid,
        session,
        device_serial,
        '{
          "mfgsku": "31576-99903",
          "parentemail": "%s",
          "model": "1",
          "pin": "%s"
        }' % [email, pin],
        '[]',
        dev_service_code
      )
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it "Verify response devProps[\"pin\"] is \"#{pin}\"" do
      expect(response['data']['devProps']['pin']).to eq(pin)
    end

    it "Verify response devPin is \"#{pin}\"" do
      expect(response['data']['devPin']).to eq(pin)
    end
  end

  context "7. Create profile 'Test' (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
    before :all do
      response = update_narnia(
        callerid,
        session,
        device_serial,
        '{
          "mfgsku": "31576-99903",
          "parentemail": "%s",
          "model": "1",
          "pin": "%s",
          "locale": "en_US"
        }' % [email, pin],
        '[{
           "userName": "Test",
           "userGender": "female",
           "userWeakId": 1,
           "userEdu": "PRE",
           "userDob": "2014-3-1"
        }]',
        dev_service_code
      )
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it "Verify response username is \"Test\"" do
      expect(response['data']['devUsers'][0]['userName']).to eq('Test')
    end

    it "Verify response gender is \"female\"" do
      expect(response['data']['devUsers'][0]['userGender']).to eq('female')
    end

    it "Verify response userWeakId is \"1\"" do
      expect(response['data']['devUsers'][0]['userWeakId']).to eq(1)
    end

    it "Verify response userDob is \"1\"" do
      expect(response['data']['devUsers'][0]['userDob']).to eq('2014-03-01')
    end

    it "Verify response userUploadable is \"true\"" do
      expect(response['data']['devUsers'][0]['userUploadable']).to eq(true)
    end

    it "Verify response userClaimed is \"true\"" do
      expect(response['data']['devUsers'][0]['userClaimed']).to eq(true)
    end
  end

  context '8. Package installation' do
    license_id = nil

    it 'GrantLicense' do
      grant_license_res = LicenseManagement.grant_license(callerid, session, parent_id, device_serial, package_id)
      license_id = grant_license_res.xpath('//license').attr('id').text

      pending "***GrantLicense [@license-id] - #{license_id} (URL: #{LFWSDL::CONST_LICENSE_MGT})"
    end

    it "Install package [@package-id] - #{package_id} (URL: #{LFWSDL::CONST_LICENSE_MGT})" do
      LicenseManagement.install_package(callerid, device_serial, '0', package_id)
    end

    it "Report installation (URL: #{LFWSDL::CONST_PACKAGE_MGT})" do
      PackageManagement.report_installation(callerid, session, device_serial, '0', package_id, license_id)
    end

    it "Verify package is installed successfully (status = installed) (URL: #{LFWSDL::CONST_PACKAGE_MGT})" do
      device_inventory_res1 = PackageManagement.device_inventory(callerid, 'application', device_serial, 'Application')
      check_install_pgk1 = LicenseManagement.check_install_package(device_inventory_res1, package_id, 'installed')

      expect(check_install_pgk1).to eq(1)
    end

    it "Verify 'fetchRestrictedLicenses' returns @license-count - 1 (URL: #{LFWSDL::CONST_LICENSE_MGT})" do
      fetch_restricted_res = LicenseManagement.fetch_restricted_licenses(callerid, 'service', session, parent_id, device_serial)
      license_num = fetch_restricted_res.xpath('//licenses').count

      expect(license_num).to eq(1)
    end

    it "Remove package on device [@package-id] - #{package_id} (URL: #{LFWSDL::CONST_PACKAGE_MGT})" do
      PackageManagement.remove_installation(callerid, session, device_serial, 0, package_id)
    end

    it "Verify package is removed from device (status = removed) (URL: #{LFWSDL::CONST_PACKAGE_MGT})" do
      device_inventory_res2 = PackageManagement.device_inventory(callerid, 'application', device_serial, 'Application')
      check_install_pgk2 = LicenseManagement.check_install_package(device_inventory_res2, package_id, 'removed')

      expect(check_install_pgk2).to eq(1)
    end
  end

  context "9. Reset device after claiming - #{device_serial} (#{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_RESET_NARNIA % device_serial})" do
    before :all do
      response = reset_narnia callerid, device_serial
    end

    it 'Verify response status is "true"' do
      expect(response['status']).to eq(true)
    end
  end
end
