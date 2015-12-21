require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify searchForCustomer service works correctly
=end

describe "TS03 - searchForCustomer - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  res = nil

  it 'Precondition - register customer' do
    CustomerManagement.register_customer(caller_id, screen_name, email, username)
  end

  context 'TC03.001 - searchForCustomer - Successful Response' do
    res_username = res_number = nil
    username1 = username

    before :all do
      res = CustomerManagement.search_for_customer(caller_id, '', '', username1)
      res_number = res.xpath('//customer').count
      res_username = res.xpath('//customer/credentials/@username').text
    end

    it 'Verify only one customer is returned.' do
      expect(res_number).to eq(1)
    end

    it 'Verify user name is returned correctly.' do
      expect(res_username).to eq(username1)
    end
  end

  context 'TC03.002 - searchForCustomer - Invalid CallerID' do
    invalid_caller_id = 'invalid'

    before :all do
      res = CustomerManagement.search_for_customer(invalid_caller_id, 'LTRC', 'Tester', username)
    end

    it "Check 'Error while checking caller id' error message displays: " do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC03.003 - searchForCustomer - Nonexistent Customer' do
    username3 = '123abc@logigear.test'
    first_name3 = 'nonexistence'
    last_name3 = 'nonexistence'
    cus_num = nil

    before :all do
      xml_res = CustomerManagement.search_for_customer(caller_id, first_name3, last_name3, username3)
      cus_num = xml_res.xpath('//customer').count
    end

    it 'Verify no customer info is returned' do
      expect(cus_num).to eq(0)
    end
  end

  context 'TC03.005 - searchForCustomer - Invalid Request' do
    before :all do
      res = CustomerManagement.search_for_customer(caller_id, '', '', '')
    end

    it "Verify exception 'A RuntimeException was thrown.'" do
      expect(res).to eq('A RuntimeException was thrown.')
    end
  end
end
