require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'

=begin
Verify changePassword service works correctly
=end

describe "TS05 - changePassword - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  password = '123456'
  new_password = hint = LFCommon.generate_password
  new_password_ac = LFCommon.generate_password
  customer_id = nil
  res = nil

  it 'Precondition - register customer' do
    res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    arr_response = CustomerManagement.get_customer_info(res)
    customer_id = arr_response[:id]
  end

  context 'TC05.001 - changePassword - Successful Response' do
    acquire_session_res1 = nil
    acquire_session_res2 = nil

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id, username, password, new_password, hint)
      acquire_session_res1 = Authentication.acquire_service_session(caller_id, username, password)
      acquire_session_res2 = Authentication.acquire_service_session(caller_id, username, new_password)
    end

    it 'Verify user is unable to login with old password' do
      expect(acquire_session_res1).to eq(ErrorMessageConst::INVALID_PASSWORD_MESSAGE)
    end

    it 'Verify user is able to login with new password' do
      expect(acquire_session_res2.xpath('//session').text).not_to be_empty
    end
  end

  context 'TC05.002 - changePassword - Invalid CallerID' do
    caller_id2 = 'invalid'
    password2 = new_password

    before :all do
      res = CustomerManagement.change_password(caller_id2, customer_id, username, password2, new_password_ac, hint)
    end

    it "Verify that 'Error while checking caller id' error message displays" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC05.003 - changePassword - Nonexistant Customer' do
    password3 = new_password
    customer_id3 = '112211'

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id3, username, password3, new_password_ac, hint)
    end

    it "Verify that 'An invalid customer or customer id was provided to execute this call' error message displays" do
      expect(res).to eq('An invalid customer or customer id was provided to execute this call')
    end
  end

  context 'TC05.004 - changePassword - Access Denied' do
    password4 = 'invalid'

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id, username, password4, new_password_ac, hint)
    end

    it "Verify that 'Unable to update password, the given credentials don't match with current ones' error message displays" do
      expect(res).to eq("Unable to update password, the given credentials don't match with current ones")
    end
  end

  context 'TC05.005 - changePassword - Invalid Request' do
    customer_id5 = username5 = password5 = new_password5 = hint5 = ''

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id5, username5, password5, new_password5, hint5)
    end

    it "Verify that 'Unable to execute the service call, an invalid/empty customer id or credentials information was provided.' error message displays" do
      expect(res).to eq('Unable to execute the service call, an invalid/empty customer id or credentials information was provided.')
    end
  end

  context 'TC05.006 - changePassword - pw of current-credentials is null' do
    password6 = ''

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id, username, password6, new_password_ac, hint)
    end

    it "Verify that 'Unable to update password, the given credentials don't match with current ones' error message displays" do
      expect(res).to eq("Unable to update password, the given credentials don't match with current ones")
    end
  end

  context 'TC05.007 - changePassword - pw of current-credentials is so long' do
    password7 = 'SmartBear Forum Skip to content. Advanced search Follow us:Board index Change font size FAQRegisterLogin You need to login in order to reply to topics within this forum.Username:Password:Iforgot my password Resend activation e-mail  Log me on automatically each visit  Hide my online status this session    REGISTER In order to login you must be registered. Registering takes only a few moments but gives you increased capabilities. The board administrator may also grant additional permissions to registered users. Before you register please ensure you are familiar with our terms of use and related policies. Please ensure you read any forum rules as you navigate around the board.  Terms of use | Privacy policy  Register  Board indexThe team ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ Delete all board cookies ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ All times are UTC + 1 hour Powered by phpBB ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â© 2000, 2002, 2005, 2007 phpBB Group'

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id, username, password7, new_password_ac, hint)
    end

    it "Verify that 'Unable to update password, the given credentials don't match with current ones' error message displays" do
      expect(res).to eq("Unable to update password, the given credentials don't match with current ones")
    end
  end

  context 'TC05.008 - changePassword - pw of current-credentials with special characters' do
    password8 = '@@#$%^&amp;*'

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id, username, password8, new_password_ac, hint)
    end

    it "Verify that 'Unable to update password, the given credentials don't match with current ones' error message displays" do
      expect(res).to eq("Unable to update password, the given credentials don't match with current ones")
    end
  end

  context 'TC05.009 - changePassword - new pass is null' do
    current_pass = new_password
    new_password9 = ''

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id, username, current_pass, new_password9, hint)
    end

    it "Verify that 'An invalid customer password was provided.' error message displays" do
      expect(res).to eq('An invalid customer password was provided.')
    end
  end

  context 'TC05.010 - changePassword - new pass is so long' do
    current_pass = new_password
    new_password10 = 'SmartBear Forum Skip to content. Advanced search Follow us:Board index Change font size FAQRegisterLogin You need to login in order to reply to topics within this forum.Username:Password:Iforgot my password Resend activation e-mail  Log me on automatically each visit  Hide my online status this session    REGISTER In order to login you must be registered. Registering takes only a few moments but gives you increased capabilities. The board administrator may also grant additional permissions to registered users. Before you register please ensure you are familiar with our terms of use and related policies. Please ensure you read any forum rules as you navigate around the board.  Terms of use | Privacy policy  Register  Board indexThe team ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ Delete all board cookies ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ All times are UTC + 1 hour Powered by phpBB ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â© 2000, 2002, 2005, 2007 phpBB Group'

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id, username, current_pass, new_password10, new_password10)
    end

    it "Verify that 'Unable to execute the call, there was a problem with data access.' error message displays" do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end

  context 'TC05.011 - changePassword - new pass with special characters' do
    current_pass = new_password
    new_password11 = '!@#$%^&'

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id, username, current_pass, new_password11, hint)
    end

    it "Verify that 'Unmarshalling Error: Unexpected character...' error message displays" do
      expect(res).to include("Unmarshalling Error: Unexpected character ''' (code 39) (expected a name start character)\n at [row,col {unknown-source}]")
    end
  end

  context 'TC05.012 - changePassword - new pass less than 6 chars' do
    current_pass = new_password
    new_password12 = '123'

    before :all do
      res = CustomerManagement.change_password(caller_id, customer_id, username, current_pass, new_password12, hint)
    end

    it "Verify that 'An invalid customer password was provided.' error message displays" do
      expect(res).to eq('An invalid customer password was provided.')
    end
  end
end
