require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'

=begin
Verify fetchChild service works correctly
=end

describe "TS02 - fetchChild - #{Misc::CONST_ENV}" do
  session = nil
  child_id = nil
  scr_name = nil
  name = nil
  username = nil
  grade = nil
  gender = nil
  dob = nil
  password = nil

  before :all do
    reg_cus_response =  CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)

    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
    reg_chi_response = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_info[:id])

    scr_name = reg_chi_response.xpath('//child/@screen-name').text
    name = reg_chi_response.xpath('//child/@name').text
    username = reg_chi_response.xpath('//child/credentials/@username').text
    grade = reg_chi_response.xpath('//child/@grade').text
    gender = reg_chi_response.xpath('//child/@gender').text
    dob = reg_chi_response.xpath('//child/@dob').text
    password = reg_chi_response.xpath('//child/credentials/@password').text
    child_id = reg_chi_response.xpath('//child/@id').text
  end

  context 'TC02.001 - fetchChild - Successful Response' do
    fet_chi_res = nil

    before :all do
      fet_chi_res = ChildManagement.fetch_child(Misc::CONST_CALLER_ID, session, child_id)
    end

    it 'Check screen-name' do
      expect(scr_name).to eq(fet_chi_res.xpath('//child/@screen-name').text)
    end

    it 'Check name' do
      expect(name).to eq(fet_chi_res.xpath('//child/@name').text)
    end

    it 'Check grade' do
      expect(grade).to eq(fet_chi_res.xpath('//child/@grade').text)
    end

    it 'Check gender' do
      expect(gender).to eq(fet_chi_res.xpath('//child/@gender').text)
    end

    it 'Check dob' do
      date = Date.parse(fet_chi_res.xpath('//child/@dob').text)
      dob_fet = Date.strptime('%s-%s-%s' % [date.year, date.mon, date.day], '%Y-%m-%d')
      expect(dob).to eq(dob_fet.to_s)
    end

    it 'Check username' do
      expect(username.downcase).to eq(fet_chi_res.xpath('//child/credentials/@username').text)
    end

    it 'Check password' do
      expect(password).to eq(fet_chi_res.xpath('//child/credentials/@password').text)
    end

    it 'Check for existence of child-id' do
      expect(child_id).to eq(fet_chi_res.xpath('//child/@id').text)
    end
  end

  context 'TC02.002 - fetchChild - Access Denied' do
    fet_chi_res = nil

    before :all do
      fet_chi_res = ChildManagement.fetch_child(Misc::CONST_CALLER_ID, 'invalid', child_id)
    end

    it 'Verify faultstring is returned: Session is invalid: ...' do
      expect(fet_chi_res).to eq('Session is invalid: invalid')
    end
  end

  context 'TC02.003 - fetchChild - Invalid CallerID' do
    fet_chi_res = nil

    before :all do
      fet_chi_res = ChildManagement.fetch_child('invalid', session, child_id)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(fet_chi_res).to eq('Error while checking caller id')
    end
  end

  context 'TC02.004 - fetchChild - nonexistent child-id' do
    fet_chi_res = nil

    before :all do
      fet_chi_res = ChildManagement.fetch_child(Misc::CONST_CALLER_ID, session, 'nonexistence')
    end

    it 'Verify faultstring is returned: there is no parent/child relationship between the customer and child' do
      expect(fet_chi_res).to eq('there is no parent/child relationship between the customer and child')
    end
  end
end
