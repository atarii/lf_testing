require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'

=begin
Verify registerChild service works correctly
=end

describe "TS01 - registerChild - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:namespace]
  cus_id = nil
  session = nil
  child_name = nil
  child_username = nil

  before :all do
    reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    cus_id = cus_info[:id]

    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
  end

  context 'TC01.001 - registerChild - Successful Response' do
    scr_name = CustomerManagement.generate_screenname
    name = username = "Kid#{LFCommon.get_current_time}"
    grade = '4'
    gender = 'male'
    dob = '2013-10-07'
    password = '123456'

    scr_name_res = nil
    name_res = nil
    username_res = nil
    grade_res = nil
    gender_res = nil
    dob_res = nil
    password_res = nil
    child_id_res = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>#{session}</session>
         <customer-id>#{cus_id}</customer-id>
         <child id='112233' name='#{name}' dob='#{dob}' grade='#{grade}' gender='#{gender}' can-upload='true' titles='1' screen-name='#{scr_name}' locale='en_US'>
         <credentials username='#{username}' password='#{password}'/></child>"
      )

      # Get response info
      scr_name_res = reg_chi_response.xpath('//child/@screen-name').text
      name_res = reg_chi_response.xpath('//child/@name').text
      username_res = reg_chi_response.xpath('//child/credentials/@username').text
      grade_res = reg_chi_response.xpath('//child/@grade').text
      gender_res = reg_chi_response.xpath('//child/@gender').text
      dob_res = reg_chi_response.xpath('//child/@dob').text
      password_res = reg_chi_response.xpath('//child/credentials/@password').text
      child_id_res = reg_chi_response.xpath('//child/@id').text
      child_name = reg_chi_response.xpath('//child/@name').text
      child_username = reg_chi_response.xpath('//child/credentials/@username').text
    end

    it 'Check screen-name' do
      expect(scr_name_res).to eq(scr_name)
    end

    it 'Check name' do
      expect(name_res).to eq(name)
    end

    it 'Check grade' do
      expect(grade_res).to eq(grade)
    end

    it 'Check gender' do
      expect(gender_res).to eq(gender)
    end

    it 'Check dob' do
      expect(dob_res).to eq(dob)
    end

    it 'Check username' do
      expect(username_res).to eq(username)
    end

    it 'Check password' do
      expect(password_res).to eq(password)
    end

    it 'Check for existence of child-id' do
      expect(child_id_res).not_to be_empty
    end
  end

  context 'TC01.002 - registerChild - Invalid CallerID' do
    reg_chi_response = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>invalid</caller-id>
         <session type='service'>#{session}</session>
         <customer-id>#{cus_id}</customer-id>
         <child id='112233' name='Kid201461013312946' dob='2013-10-07' grade='4' gender='male' can-upload='true' titles='1' screen-name='scr20146101331293' locale='en_US'/>"
      )
    end

    it "check error message 'Error while checking caller id'" do
      expect(reg_chi_response).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - registerChild - duplicate child-name' do
    reg_chi_response = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>#{session}</session>
         <customer-id>#{cus_id}</customer-id>
         <child id='' name='#{child_name}' dob='2013-10-07' grade='4' gender='male' can-upload='true' titles='1' screen-name='scrname' locale='en_US'/>"
      )
    end

    it "check error message \"You have already entered information for this child: ...\"" do
      expect(reg_chi_response).to eq("You have already entered information for this child: #{child_name}")
    end
  end

  context 'TC01.004 - registerChild - duplicate username' do
    reg_chi_response = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>#{session}</session>
         <customer-id>#{cus_id}</customer-id>
         <child id='' name='newname' dob='2013-10-07' grade='4' gender='male' can-upload='true' titles='1' screen-name='scrname' locale='en_US'>
         <credentials username='#{child_username}' password='123456'/></child>"
      )
    end

    it 'Check error message: Username ... is not available' do
      expect(reg_chi_response.downcase).to eq("Username \"#{child_username}\" is not available".downcase)
    end
  end

  context 'TC01.005 - registerChild - Invalid Request' do
    reg_chi_response = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>#{session}</session>
         <customer-id>#{cus_id}</customer-id>
         <child id='aaa' name='RioKid' dob='2013-10-07' grade='a' gender='male' can-upload='true' titles='a' screen-name='scrname' locale='en_US'>
         <credentials username='riokid' password='123456'/></child>"
      )
    end

    it 'Check error message: Unmarshalling Error: Not a number: aaa' do
      expect(reg_chi_response.strip).to eq('Unmarshalling Error: Not a number: aaa')
    end
  end

  context 'TC01.006 - registerChild - Access Denied' do
    reg_chi_response = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>invalid_session</session>
         <customer-id>111</customer-id>
         <child id='112233' name='RioKid' dob='2013-10-07' grade='4' gender='male' can-upload='true' titles='1' screen-name='scrname' locale='en_US'>
         <credentials username='riokid' password='123456'/></child>"
      )
    end

    it 'Check error message: Session is invalid: invalid_session' do
      expect(reg_chi_response).to eq('Session is invalid: invalid_session')
    end
  end

  context 'TC01.007 - registerChild - Child Name - Special Character' do
    reg_chi_response = nil
    name = "\@\#\$\@\#\$#{LFCommon.get_current_time}"

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
           <session type='service'>#{session}</session>
           <customer-id>#{cus_id}</customer-id>
           <child id='112233' name='#{name}' dob='2013-10-07' grade='4' gender='male' can-upload='true' titles='1' screen-name='scrname' locale='en_US'>
           <credentials username='riokid#{LFCommon.get_current_time}' password='123456'/></child>"
      )
    end

    it 'Check user cannot create new child with child-name contains special characters' do
      expect(reg_chi_response).to eq("A RuntimeException was thrown: #{name} contains special character(s)")
    end
  end

  context 'TC01.008 - registerChild - CustomerID - Negative Number' do
    reg_chi_response = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>#{session}</session>
         <customer-id>-111</customer-id>
         <child id='112233' name='RioKid' dob='2013-10-07' grade='4' gender='male' can-upload='true' titles='1' screen-name='scrname' locale='en_US'>
         <credentials username='riokid' password='123456'/></child>"
      )
    end

    it 'Check error message: Unable to complete registerChild' do
      expect(reg_chi_response).to eq('Unable to complete registerChild')
    end
  end

  context 'TC01.009 - registerChild - Invalid DOB: month is invalid' do
    reg_chi_response = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>#{session}</session>
         <customer-id>#{cus_id}</customer-id>
         <child id='112233' name='RioKid#{LFCommon.get_current_time}' dob='2020-14-07' grade='4' gender='male' can-upload='true' titles='1' screen-name='scrname' locale='en_US'>
         <credentials username='riokid#{LFCommon.get_current_time}' password='123456'/></child>"
      )
    end

    it 'Check error message: missing dob' do
      expect(reg_chi_response).to eq('missing dob')
    end
  end

  context 'TC01.010 - registerChild - Invalid DOB: incorrect format' do
    reg_chi_response = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>#{session}</session>
         <customer-id>#{cus_id}</customer-id>
         <child id='112233' name='RioKid' dob='1111111111111' grade='4' gender='male' can-upload='true' titles='1' screen-name='scrname' locale='en_US'>
         <credentials username='riokid' password='123456'/></child>"
      )
    end

    it 'Check error message: A RuntimeException was thrown: Invalid year value' do
      expect(reg_chi_response).to eq('A RuntimeException was thrown: Invalid year value')
    end
  end

  context 'TC01.011 - registerChild - Invalid Gender' do
    reg_chi_response = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>#{session}</session>
         <customer-id>#{cus_id}</customer-id>
         <child id='112233' name='RioKid' dob='2013-10-07' grade='4' gender='invalid' can-upload='true' titles='1' screen-name='scrname' locale='en_US'>
         <credentials username='riokid' password='123456'/></child>"
      )
    end

    it 'Check error message: missing gender' do
      expect(reg_chi_response).to eq('missing gender')
    end
  end

  context 'TC01.012 - registerChild - id out of range' do
    reg_chi_response = nil
    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <customer-id>#{cus_id}</customer-id>
        <child id='12312434513412312312323423434346456' name='RioKid' dob='2013-10-07' grade='4' gender='male' can-upload='true' titles='1' screen-name='scrname' locale='en_US'>
          <credentials username='riokid' password='123456'/>
        </child>"
      )
    end

    it 'Verify that user cannot register child with child-id is out of integer range' do
      expect(reg_chi_response).to eq('Username "riokid" is not available')
    end
  end

  context 'TC01.013 - registerChild - Titles Out Of Range' do
    reg_chi_response = nil

    before :all do
      reg_chi_response = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
           <session type='service'>#{session}</session>
           <customer-id>#{cus_id}</customer-id>
           <child id='112233' name='RioKid#{LFCommon.get_current_time}' dob='2013-10-07' grade='4' gender='male' can-upload='true' titles='111111111111111111111111111111111111111111111111111111142334234' screen-name='scrname' locale='en_US'>
           <credentials username='riokid#{LFCommon.get_current_time}' password='123456'/></child>"
      )
    end

    it 'Verify that user cannot register child with Titles is out of integer range' do
      expect(reg_chi_response).to eq('Known issue: error message is not returned')
    end
  end
end
