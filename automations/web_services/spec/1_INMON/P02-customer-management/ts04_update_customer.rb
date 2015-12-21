require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify updateCustomer service works correctly
=end

describe "TS04 - updateCustomer #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:customer_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:customer_management][:namespace]
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  duplicate_username = duplicate_email = LFCommon.generate_email
  duplicate_screenname = CustomerManagement.generate_screenname
  password = '123456'
  customer_id = nil
  res = nil

  it 'Precondition - register customer' do
    res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    xml_res = CustomerManagement.get_customer_info(res)
    customer_id = xml_res[:id]

    # Register a customer to user for duplicate email, screen name
    CustomerManagement.register_customer(caller_id, duplicate_screenname, duplicate_email, duplicate_username)
  end

  context 'TC04.001 - updateCustomer - Successful Response' do
    fetch_response = nil

    before :all do
      CustomerManagement.update_customer(caller_id, customer_id, username, email, password, '')
      fetch_response = CustomerManagement.fetch_customer(caller_id, customer_id)
    end

    it "Verify 'Locale' is updated successfully" do
      expect(fetch_response.xpath('//customer').attr('locale').text).to eq('fr_FR')
    end

    it "Verify 'First name' is updated successfully" do
      expect(fetch_response.xpath('//customer').attr('first-name').text).to eq('uLTRC')
    end

    it "Verify 'Last name' is updated successfully" do
      expect(fetch_response.xpath('//customer').attr('last-name').text).to eq('uTester')
    end
  end

  context 'TC04.002 - updateCustomer - Duplicate Email' do
    before :all do
      res = CustomerManagement.update_customer(caller_id, customer_id, username, duplicate_email, password, '')
    end

    it "Check 'The provided email information already exists.' error message displays: " do
      expect(res).to eq('The provided email information already exists.')
    end
  end

  context 'TC04.003 - updateCustomer - Invalid CallerID' do
    caller_id3 = 'invalid'

    before :all do
      res = CustomerManagement.update_customer(caller_id3, customer_id, username, email, password, '')
    end

    it "Check 'Error while checking caller id' error message displays: " do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC04.004 - updateCustomer - Duplicate Screen Name' do
    screen_name4 = duplicate_screenname

    before :all do
      res = CustomerManagement.update_customer(caller_id, customer_id, username, email, password, screen_name4)
    end

    it "Check 'Given alias name is not available, it is already in use.' error message displays: " do
      expect(res).to eq("Given alias name (#{screen_name4}) is not available, it is already in use.")
    end
  end

  context 'TC04.005 - updateCustomer - Access Denied' do
    update_customer_acd = nil

    before :all do
      update_customer_acd = LFCommon.soap_call(
        endpoint,
        namespace,
        :update_customer,
        "<caller-id>#{caller_id}</caller-id>
        <username>#{username}</username>
        <customer-id>#{customer_id}</customer-id>
        <customer id='111' first-name='uLTRC' last-name='uTester' middle-name='' salutation='' locale='fr_FR' alias='' screen-name='#{screen_name}' modified='' created='' type='' registration-date=''>
          <credentials username='#{username}' password='#{password}' hint='' expiration='' last-login='' password-temporary='?'/>
        </customer>"
      )
    end

    it "Check 'No email address was found for the customer' error message displays: " do
      expect(update_customer_acd).to eq('No email address was found for the customer')
    end
  end

  context 'TC04.006 - updateCustomer - Invalid Email' do
    email6 = 'invalid'

    before :all do
      res = CustomerManagement.update_customer(caller_id, customer_id, username, email6, password, '')
    end

    it "Check 'Unable to execute the call, there was a problem with data access.' error message displays: " do
      expect('#36235: Web Services: customer-management: updateCustomer: The message "The provided email information already exists." displays when updating customer with invalid email').to eq('Unable to execute the call, there was a problem with data access.')
    end
  end

  context 'TC04.007 - updateCustomer - customer-id is null' do
    customer_id7 = ''

    before :all do
      res = CustomerManagement.update_customer(caller_id, customer_id7, username, email, password, screen_name)
    end

    # Check error message displays correctly
    it "Check 'There was a problem while executing the call, an invalid or empty customer id or email information was provided' error message displays: " do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer id or email information was provided')
    end
  end

  context 'TC04.008 - updateCustomer - customer-id is long' do
    customer_id8 = 'SmartBear Forum Skip to content Advanced search Follow us:Board index Change font size FAQRegisterLogin You need to login in order to reply to topics within this forum.   Username:  Password:  I forgot my password Resend activation e-mail  Log me on automatically each visit  Hide my online status this session    REGISTER In order to login you must be registered. Registering takes only a few moments but gives you increased capabilities. The board administrator may also grant additional permissions to registered users. Before you register please ensure you are familiar with our terms of use and related policies. Please ensure you read any forum rules as you navigate around the board.  Terms of use | Privacy policy  Register  Board indexThe team ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Delete all board cookies ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ All times are UTC + 1 hour Powered by phpBB Ãƒâ€šÃ‚Â© 2000, 2002, 2005, 2007 phpBB Group'

    before :all do
      res = CustomerManagement.update_customer(caller_id, customer_id8, username, email, password, screen_name)
    end

    it "Check 'There was a problem while executing the call, an invalid or empty customer id or email information was provided' error message displays: " do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer id or email information was provided')
    end
  end

  context 'TC04.009 - updateCustomer - customer-id with special characters' do
    customer_id9 = '@@!##$@%%@#&amp;#^!#$#!$#!'

    before :all do
      res = CustomerManagement.update_customer(caller_id, customer_id9, username, email, password, screen_name)
    end

    it "Check 'There was a problem while executing the call, an invalid or empty customer id or email information was provided' error message displays: " do
      expect(res).to eq('There was a problem while executing the call, an invalid or empty customer id or email information was provided')
    end
  end
end
