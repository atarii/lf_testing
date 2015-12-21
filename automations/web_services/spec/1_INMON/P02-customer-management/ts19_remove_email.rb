require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify removeEmail service works correctly
=end

describe "TS19 - removeEmail - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  customer_id = nil
  res = nil

  it 'Precondition - register customer' do
    res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_response = CustomerManagement.get_customer_info(res)
    customer_id = arr_response[:id]
  end

  context 'TC19.001 - removeEmail - Successful Response' do
    res_email = nil

    before :all do
      CustomerManagement.remove_email(caller_id, customer_id, email)

      fetch_res = CustomerManagement.fetch_customer(caller_id, customer_id)
      res_email = fetch_res.xpath('//customer/email').count

      CustomerManagement.add_email(caller_id, customer_id, username, email)
    end

    it 'Verify removeEmail calls successfully' do
      expect(res_email).to eq(0)
    end
  end

  context 'TC19.002 - removeEmail - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CustomerManagement.remove_email(caller_id2, customer_id, email)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC19.003 - removeEmail - Access Denied' do
    customer_id3 = '-1234'

    before :all do
      res = CustomerManagement.remove_email(caller_id, customer_id3, email)
    end

    it "Verify 'An invalid customer or customer id was provided to execute this call' error message responses" do
      expect(res).to eq('An invalid customer or customer id was provided to execute this call')
    end
  end

  context 'TC19.004 - removeEmail - Invalid Request' do
    customer_id4 = 'invalid'

    before :all do
      res = CustomerManagement.remove_email(caller_id, customer_id4, email)
    end

    it "Verify 'There was a problem while executing the call, an invalid or empty customer id or email information was provided' error message responses" do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer id or email information was provided')
    end
  end

  context 'TC19.005 - removeEmail - Customer Id is null' do
    customer_id5 = ''

    before :all do
      res = CustomerManagement.remove_email(caller_id, customer_id5, email)
    end

    it "Verify 'There was a problem while executing the call, an invalid or empty customer id or email information was provided' error message responses" do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer id or email information was provided')
    end
  end

  context 'TC19.006 - removeEmail - Customer Id is so long' do
    customer_id6 = 'See a proxy server, check your proxy settings or contact your network administrator to make sure the proxy server is working. If you dont believe you should be using a proxy server, adjust your proxy settings: Go to the Chrome menu > Settings > Show advanced settings'

    before :all do
      res = CustomerManagement.remove_email(caller_id, customer_id6, email)
    end

    it "Verify 'There was a problem while executing the call, an invalid or empty customer id or email information was provided' error message responses" do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer id or email information was provided')
    end
  end

  context 'TC19.007 - removeEmail - Email is null' do
    email7 = ''
    res_email = nil

    before :all do
      CustomerManagement.remove_email(caller_id, customer_id, email7)

      xml_fetch_cus_res = CustomerManagement.fetch_customer(caller_id, customer_id)
      res_email = xml_fetch_cus_res.xpath('//customer/email').count

      CustomerManagement.add_email(caller_id, customer_id, username, email)
    end

    it 'Verify removeEmail calls successfully' do
      expect(res_email).to eq(0)
    end
  end

  context 'TC19.008 - removeEmail - Email is so long' do
    email8 = 'A proxy server, check your proxy settings or contact your network administrator to make sure the proxy server is working. If you dont believe you should be using a proxy server, adjust your proxy settings: Go to the Chrome menu settings@lapfrog.test'

    before :all do
      res = CustomerManagement.remove_email(caller_id, customer_id, email8)
    end

    it "Verify 'Unable to execute the call, there was a problem with data access.' error message responses" do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end

  context 'TC19.009 - removeEmail - Email is invalid' do
    email9 = 'abc123!@#@#'

    before :all do
      res = CustomerManagement.remove_email(caller_id, customer_id, email9)
    end

    it "Verify 'Unable to execute the call, there was a problem with data access.' error message responses" do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end
end
