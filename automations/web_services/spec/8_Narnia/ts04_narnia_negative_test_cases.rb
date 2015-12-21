require File.expand_path('../../spec_helper', __FILE__)
require 'credential_management'
require 'parent_management'

=begin
Narnia negative test cases checking
=end

def reset_narnia_neg_caller_id(caller_id, serial = 'fake')
  res = nil
  before :all do
    res = reset_narnia caller_id, serial
  end

  it 'Verify response [status] is false' do
    expect(res['status']).to eq(false)
  end

  it 'Verify error message is \'Error while checking caller id\'' do
    expect(res['data']['message']).to eq('Error while checking caller id')
  end
end

def update_narnia_neg_caller_id(caller_id, serial = 'fake')
  res = nil

  before :all do
    dev_service_code = 'android1'
    locale = 'en_US'

    res = update_narnia(
      caller_id,
      '',
      serial,
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

  it 'Verify response [status] is false' do
    expect(res['status']).to eq(false)
  end

  it 'Verify error message is \'Error while checking caller id\'' do
    expect(res['data']['message']).to eq('Error while checking caller id')
  end
end

def own_narnia_neg_session(caller_id, session, device_serial)
  owner_res = nil

  before :all do
    owner_res = owner_narnia caller_id, session, device_serial
  end

  it 'Verify response [status] is false' do
    expect(owner_res['status']).to eq(false)
  end

  it "Verify server returns error message: Can not find session: #{session}" do
    expect(owner_res['data']['message']).to eq("Can not find session: #{session}")
  end
end

describe "TS04 - Narnia negative test cases - #{Misc::CONST_ENV}" do
  device_serial = 'fake'
  context 'Caller ID' do
    context "TC01 - reset service - invalid caller id (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_RESET_NARNIA % device_serial})" do
      reset_narnia_neg_caller_id 'invalid_caller_id', device_serial
    end

    context "TC02 - reset service - empty caller-id (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_RESET_NARNIA % device_serial})" do
      reset_narnia_neg_caller_id '', device_serial
    end

    context "TC03 - update device profile - invalid caller id (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
      update_narnia_neg_caller_id 'invalid_caller_id', device_serial
    end

    context "TC04 - update device profile - empty caller id (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
      update_narnia_neg_caller_id '', device_serial
    end
  end

  context 'Session token' do
    caller_id = Misc::CONST_REST_CALLER_ID
    device_serial = DeviceManagement.generate_serial 'NARNIA'
    locale = 'en_US'
    dev_service_code = 'android1'
    email = LFCommon.generate_email
    first_name = 'ltrc'
    last_name = 'vn'
    password = '123456'
    email_optin = 'true'

    context 'Pre-condition: set up locale, create parent account' do
      it "Reset device (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_RESET_NARNIA % device_serial})" do
        reset_narnia caller_id, device_serial
      end

      it "Update device info (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_UPDATE_NARNIA % device_serial})" do
        update_narnia(
          caller_id,
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

      it "Create parent account (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_CREATE_PARENT})" do
        ParentManagementRest.create_parent(caller_id, email, password, first_name, last_name, email_optin, locale)
      end
    end

    context "Owner device (URL: #{LFREST::CONST_ENDPOINT}#{LFRESOURCES::CONST_OWNER_NARNIA % device_serial})" do
      context 'TC05 - invalid session' do
        own_narnia_neg_session caller_id, 'invalid_session', device_serial
      end

      context 'TC06 - empty session' do
        response_owner = nil

        before :all do
          response_owner = owner_narnia caller_id, '', device_serial
        end

        it 'Verify response [status] is false' do
          expect(response_owner['status']).to eq(false)
        end

        it 'Verify server returns error message: Nil session token' do
          expect(response_owner['data']['message']).to eq('Nil session token')
        end
      end

      context 'TC07 - session token contains special chars' do
        own_narnia_neg_session caller_id, '@#$%^&*()*&^%$#@@#$%^&*', device_serial
      end
    end
  end
end
