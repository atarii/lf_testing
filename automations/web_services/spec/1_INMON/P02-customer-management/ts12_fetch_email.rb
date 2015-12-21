require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify fetchEmails service works correctly
=end

describe "TS12 - fetchEmails - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  customer_id = nil
  res = nil

  it 'Precondition - register customer' do
    register_response1 = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_response = CustomerManagement.get_customer_info(register_response1)
    customer_id = arr_response[:id]
  end

  context 'TC12.001 - fetchEmails - Successful Response' do
    res_email = nil

    before :all do
      res = CustomerManagement.fetch_emails(caller_id, customer_id, username)
      res_email = res.xpath('//email').text
    end

    it 'Verify fecthEmails call successfully' do
      expect(res_email).to eq(email)
    end
  end

  context 'TC12.002 - fetchEmails - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CustomerManagement.fetch_emails(caller_id2, customer_id, username)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC12.003 - fetchEmails - Access Denied' do
    customer_id3 = '-1234'

    before :all do
      res = CustomerManagement.fetch_emails(caller_id, customer_id3, username)
    end

    it "Verify 'An invalid customer or customer id was provided to execute this call' error message responses" do
      expect(res).to eq('An invalid customer or customer id was provided to execute this call')
    end
  end

  context 'TC12.004 - fetchEmails - Invalid Request' do
    customer_id4 = 'invalid'

    before :all do
      res = CustomerManagement.fetch_emails(caller_id, customer_id4, username)
    end

    it "Verify 'There was a problem while executing the call, an invalid or empty customer was provided' error message responses" do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer was provided')
    end
  end

  context 'TC12.005 - fetchEmails - Customer id is null' do
    customer_id5 = ''

    before :all do
      res = CustomerManagement.fetch_emails(caller_id, customer_id5, username)
    end

    it "Verify 'There was a problem while executing the call, an invalid or empty customer was provided' error message responses" do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer was provided')
    end
  end

  context 'TC12.006 - fetchEmails - Customer id is so long' do
    customer_id6 = 'To set up a LeapFrog Connected toy, install the LeapFrog Connect Application for your toy and follow the onscreen instructions. Then connect again after your child plays to see his or her learning progress, access rewards your child has earned, and get ideas to expand the learning.'

    before :all do
      res = CustomerManagement.fetch_emails(caller_id, customer_id6, username)
    end

    it "Verify 'There was a problem while executing the call, an invalid or empty customer was provided' error message responses" do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer was provided')
    end
  end
end
