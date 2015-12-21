require File.expand_path('../../spec_helper', __FILE__)
require 'credential_management'
require 'parent_management'

=begin
Narnia: device and profile API checking
=end

describe "TS02 - Device and Profile API - Narnia - #{Misc::CONST_ENV}" do
  callerid = Misc::CONST_REST_CALLER_ID
  device_serial = DeviceManagement.generate_serial 'NARNIA'
  locale = 'en_US'
  dev_service_code = 'android1'
  email = LFCommon.generate_email
  firstname = 'ltrc'
  lastname = 'vn'
  password = '123456'
  email_optin = 'true'
  pin = '1234'
  update_pin = '4321'
  response = session = parent_id = nil

  context 'Pre-condition: set up new device' do
    release_li_response = post_locale_response = res_fetch_device = nil

    it "Reset device (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_RESET_NARNIA % device_serial})" do
      release_li_response = reset_narnia callerid, device_serial
    end

    it "Update device (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
      post_locale_response = update_narnia(
        callerid,
        '',
        device_serial,
        '{
          "mfgsku": "31576-99903",
          "parentemail": "",
          "model": "1",
          "locale": "%s"
        }' % locale,
        '[]',
        dev_service_code
      )
    end

    it "Fetch device info (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_FETCH_DEVICE % device_serial}))" do
      res_fetch_device = fetch_device callerid, device_serial
    end

    it 'Verify release license response status is "false"' do
      expect(release_li_response['status']).to eq(false)
    end

    it 'Verify release license response faultCode is "DEVUNCLAIMED"' do
      expect(release_li_response['data']['faultCode']).to eq('DEVUNCLAIMED')
    end

    it "Verify release license response message is \"unknown device: #{device_serial}\"" do
      expect(release_li_response['data']['message']).to eq("unknown device: #{device_serial}")
    end

    it 'Verify response status is true when device post locale to server' do
      expect(post_locale_response['status']).to eq(true)
    end

    it "Verify locale match: locale - #{locale}" do
      expect(post_locale_response['data']['devProps']['locale']).to eq(locale)
    end

    it "Verify device serial match: device serial - #{device_serial}" do
      expect(res_fetch_device['data']['devSerial']).to eq(device_serial)
    end

    it "Verify device service code match: device service code - #{dev_service_code}" do
      expect(res_fetch_device['data']['devServiceCode']).to eq(dev_service_code)
    end
  end

  context '1. Create parent account and claim device.' do
    response_owner = response_claim = nil

    it "Create parent account (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_CREATE_PARENT})" do
      response = ParentManagementRest.create_parent(callerid, email, password, firstname, lastname, email_optin, locale)
      session = response['data']['token']
      parent_id = response['data']['parent']['parentID']
    end

    it "Set device owner id (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_OWNER_NARNIA % device_serial})" do
      response_owner = owner_narnia callerid, session, device_serial
    end

    it "Claim device (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
      response_claim = update_narnia(
        callerid,
        '',
        device_serial,
        '{
          "mfgsku": "31576-99903",
          "parentemail": "%s",
          "model": "1",
          "locale": "%s"
        }' % [email, locale],
        '[]',
        dev_service_code
      )
    end

    it 'Verify create parent response status is true' do
      expect(response['status']).to eq(true)
    end

    it 'Verify token is generated - token: %s' % session do
      expect(session).not_to be_empty
    end

    it 'Verify parent id is created - parent ID: %s' % parent_id do
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

    it 'Verify devOwnerId > 0' do
      expect(response_owner['data']['devOwnerId']).to be > 0
    end

    it 'Verify claim status is true' do
      expect(response_claim['status']).to eq(true)
    end

    it "Verify response devOwnerStatus is \"ACTIVE\"" do
      expect(response_claim['data']['devOwnerStatus']).to eq('ACTIVE')
    end
  end

  context "2. Set up parent lock (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
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

  context "3. Create child profile (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
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
          "locale": "%s"
        }' % [email, pin, locale],
        '[{
           "userName": "Test",
           "userGender": "female",
           "userWeakId": 1,
           "userEdu": "PRE",
           "userDob": "2012-3-1"
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
      expect(response['data']['devUsers'][0]['userDob']).to eq('2012-03-01')
    end

    it "Verify response userUploadable is \"true\"" do
      expect(response['data']['devUsers'][0]['userUploadable']).to eq(true)
    end

    it "Verify response userClaimed is \"true\"" do
      expect(response['data']['devUsers'][0]['userClaimed']).to eq(true)
    end
  end

  context "4. Update parent lock (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
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
        }' % [email, update_pin],
        '[]',
        dev_service_code
      )
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it "Verify response devProps[\"pin\"] is \"#{update_pin}\"" do
      expect(response['data']['devProps']['pin']).to eq(update_pin)
    end

    it "Verify response devPin is \"#{update_pin}\"" do
      expect(response['data']['devPin']).to eq(update_pin)
    end
  end

  context "5. Update child profile (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
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
          "locale": "%s"
        }' % [email, update_pin, locale],
        '[{
           "userName": "Test_Edit",
           "userGender": "male",
           "userWeakId": 1,
           "userEdu": "FOUR",
           "userDob": "2010-3-1"
        }]',
        dev_service_code
      )
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it 'Verify user name is updated' do
      expect(response['data']['devUsers'][0]['userName']).to eq('Test_Edit')
    end

    it 'Verify gender is updated' do
      expect(response['data']['devUsers'][0]['userGender']).to eq('male')
    end

    it 'Verify grade is updated' do
      expect(response['data']['devUsers'][0]['userEdu']).to eq('FOUR')
    end

    it 'Verify dob is updated' do
      expect(response['data']['devUsers'][0]['userDob']).to eq('2010-03-01')
    end
  end

  context "6. Add new child profile (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
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
          "locale": "%s"
        }' % [email, update_pin, locale],
        '[{
           "userName": "Test_Edit",
           "userGender": "male",
           "userWeakId": 1,
           "userEdu": "FOUR",
           "userDob": "2010-3-1"
          },
          {
           "userName": "Test Adding",
           "userGender": "male",
           "userWeakId": 2,
           "userEdu": "THRE",
           "userDob": "2007-5-7"
        }]',
        dev_service_code
      )
    end

    it 'Verify response status is true' do
      expect(response['status']).to eq(true)
    end

    it 'Verify total profiles is 2' do
      expect(response['data']['devUsers'].count).to eq(2)
    end

    it 'Verify info of child profile 2nd is put to server - user name' do
      expect(response['data']['devUsers'][1]['userName']).to eq('Test Adding')
    end

    it 'Verify info of child profile 2nd is put to server - gender' do
      expect(response['data']['devUsers'][1]['userGender']).to eq('male')
    end

    it 'Verify info of child profile 2nd is put to server - grade' do
      expect(response['data']['devUsers'][1]['userEdu']).to eq('THRE')
    end

    it 'Verify info of child profile 2nd is put to server - dob' do
      expect(response['data']['devUsers'][1]['userDob']).to eq('2007-05-07')
    end
  end
end
