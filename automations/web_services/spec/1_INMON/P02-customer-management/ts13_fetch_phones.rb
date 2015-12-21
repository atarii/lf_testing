require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify fetchPhone service works correctly
=end

describe "TS13 - fetchPhones - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  customer_id = nil
  type = 'work'
  extension = '1'
  number = LFCommon.get_current_time
  res = nil

  it 'Precondition - register customer' do
    register_response1 = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_response = CustomerManagement.get_customer_info(register_response1)
    customer_id = arr_response[:id]
  end

  context 'TC13.001 - fetchPhones - Successful Response' do
    type1 = number1 = nil

    before :all do
      CustomerManagement.add_phone(caller_id, customer_id, username, number, type, extension)

      xml_fetch_phone_res = CustomerManagement.fetch_phones(caller_id, customer_id, username)
      number1 = xml_fetch_phone_res.xpath('//phone').attr('number').text
      type1 = xml_fetch_phone_res.xpath('//phone').attr('type').text
    end

    it 'Check Number responses ' do
      expect(number1).to eq(number + ' ext. ' + extension)
    end

    it 'Check Type responses ' do
      expect(type1).to eq(type)
    end
  end

  context 'TC13.002 - fetchPhones - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CustomerManagement.fetch_phones(caller_id2, customer_id, username)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC13.003 - fetchPhones - Access Denied' do
    customer_id3 = '-12345'

    before :all do
      res = CustomerManagement.fetch_phones(caller_id, customer_id3, username)
    end

    it "Verify 'An invalid customer or customer id was provided to execute this call' error message responses" do
      expect(res).to eq('An invalid customer or customer id was provided to execute this call')
    end
  end

  context 'TC13.004 - fetchPhones - Invalid Request' do
    customer_id4 = 'invalid'

    before :all do
      res = CustomerManagement.fetch_phones(caller_id, customer_id4, username)
    end

    it "Verify 'Unable to execute the service call, an invalid/empty customer id was provided.' error message responses" do
      expect(res).to eq('Unable to execute the service call, an invalid/empty customer id was provided.')
    end
  end

  context 'TC13.005 - fetchPhones - Customer id is null' do
    customer_id5 = ''

    before :all do
      res = CustomerManagement.fetch_phones(caller_id, customer_id5, username)
    end

    it "Verify 'Unable to execute the service call, an invalid/empty customer id was provided.' error message responses" do
      expect(res).to eq('Unable to execute the service call, an invalid/empty customer id was provided.')
    end
  end

  context 'TC13.006 - fetchPhones - Customer id is so long' do
    customer_id6 = 'To set up a LeapFrog Connected toy, install the LeapFrog Connect Application for your toy and follow the onscreen instructions. Then connect again after your child plays to see his or her learning progress, access rewards your child has earned, and get ideas to expand the learning.'

    before :all do
      res = CustomerManagement.fetch_phones(caller_id, customer_id6, username)
    end

    it "Verify 'Unable to execute the service call, an invalid/empty customer id was provided.' error message responses" do
      expect(res).to eq('Unable to execute the service call, an invalid/empty customer id was provided.')
    end
  end
end
