require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify addEmail service works correctly
=end

describe "TS07 - addEmail - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  new_email = 'new' + LFCommon.generate_email
  customer_id = nil
  res = nil

  it 'Precondition - register customer' do
    res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_response = CustomerManagement.get_customer_info(res)
    customer_id = arr_response[:id]
  end

  context 'TC07.001 - addEmail - Successful Response' do
    res_email = nil

    before :all do
      CustomerManagement.add_email(caller_id, customer_id, username, new_email)

      fetch_response1 = CustomerManagement.fetch_customer(caller_id, customer_id)
      res_email = fetch_response1.xpath('//customer/email').text
    end

    it "Verify 'Email' is added successfully" do
      expect(res_email).to eq(new_email)
    end
  end

  context 'TC07.002 - addEmail - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CustomerManagement.add_email(caller_id2, customer_id, username, new_email)
    end

    it "Verify 'Error while checking caller id' error message displays" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC07.003 - addEmail - Nonexistant Customer' do
    customer_id3 = '11454543434'
    new_email3 = 'new' + LFCommon.generate_email

    before :all do
      res = CustomerManagement.add_email(caller_id, customer_id3, username, new_email3)
    end

    it "Verify 'Unable to execute the call, invalid email or contact information were supplied.' error message displays" do
      expect(res).to eq("Unable to execute the call, invalid email or contact information was supplied: #{new_email3}")
    end
  end

  context 'TC07.004 - addEmail - Access Denied' do
    customer_id4 = ''
    username4 = ''

    before :all do
      res = CustomerManagement.add_email(caller_id, customer_id4, username4, new_email)
    end

    it "Verify 'Unable to execute the service call, an invalid/empty customer id or email information was provided.' error message displays" do
      expect(res).to eq('Unable to execute the service call, an invalid/empty customer id or email information was provided.')
    end
  end

  context 'TC07.005 - addEmail - Invalid Request' do
    new_email5 = 'invalid'

    before :all do
      res = CustomerManagement.add_email(caller_id, customer_id, username, new_email5)
    end

    it "Verify 'Unable to execute the call, there was a problem with data access.' error message displays" do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end

  context 'TC07.006 - addEmail - Email is null' do
    new_email6 = ''

    before :all do
      res = CustomerManagement.add_email(caller_id, customer_id, username, new_email6)
    end

    it "Verify 'Unable to execute the call, there was a problem with data access.' error message displays" do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end

  context 'TC07.007 - addEmail - Email is so long' do
    new_email7 = 'InthisguideyoulllearnhowtocreateadatadriventestaddadatasourceassertthedataandrunthetestThisfeatureisonlyavailableinSoapUIProsoyoushoulddownloadSoapUIProTrialbeforestartingifyoudonthaveit@yahoocom'

    before :all do
      res = CustomerManagement.add_email(caller_id, customer_id, username, new_email7)
    end

    it "Verify 'email address too long, please limit to 100 characters.' error message displays" do
      expect(res).to eq('email address too long, please limit to 100 characters.')
    end
  end
end
