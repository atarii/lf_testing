require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify registerCustomer service works correctly
=end

describe "TS0.1 - registerCustomer - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:customer_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:customer_management][:namespace]
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  res = nil
  cus_id = nil

  context 'TC01.001-registerCustomer - Successful Response' do
    xml_res = nil

    before :all do
      res = CustomerManagement.register_customer(caller_id, screen_name, email, username)
      xml_res = CustomerManagement.get_customer_info(res)
      cus_id = xml_res[:id]
    end

    it 'Verify Customer ID is not empty' do
      expect(xml_res[:id]).not_to be_empty
    end

    it "Check Email: #{email}" do
      expect(xml_res[:email]).to eq(email)
    end

    it "Check User name: #{username}" do
      expect(xml_res[:username]).to eq(username)
    end

    it 'Verify Password: 123456' do
      expect(xml_res[:password]).to eq('123456')
    end

    it 'Verify Hint: 123456' do
      expect(xml_res[:hint]).to eq('123456')
    end

    it 'Verify Middle name: mdname' do
      expect(xml_res[:middle_name]).to eq('mdname')
    end

    it 'Verify Last name: Tester' do
      expect(xml_res[:last_name]).to eq('Tester')
    end

    it 'Verify First name: LTRC' do
      expect(xml_res[:first_name]).to eq('LTRC')
    end

    it "Check Screen name: #{screen_name}" do
      expect(xml_res[:screen_name]).to eq(screen_name)
    end

    it 'Verify Alias: LTRCTester' do
      expect(xml_res[:str_alias]).to eq('LTRCTester')
    end

    it 'Verify Locale: en_US' do
      expect(xml_res[:locale]).to eq('en_US')
    end

    it 'Verify Salutation: sal' do
      expect(xml_res[:salutation]).to eq('sal')
    end

    it 'Verify Expiration: 2015-12-30T00:00:00' do
      expect(xml_res[:expiration]).to eq('2015-12-30T00:00:00')
    end
  end

  context 'TC01.002-registerCustomer - Duplicate Email' do
    screen_name2 = CustomerManagement.generate_screenname
    username2 = LFCommon.generate_email

    before :all do
      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_customer,
        "<caller-id>#{caller_id}</caller-id>
         <customer id='' first-name='LTRC' last-name='Tester' middle-name='mdname' salutation='sal' locale='en_US' alias='LTRCTester' screen-name='#{screen_name2}' modified='' created=''>
            <phone type='mobile' extension='1' number='123456789'/>
            <credentials username='#{username2}' password='123456' hint='123456' expiration='2015-12-30T00:00:00' last-login=''/>
            <email opted='true' verified='true' type='work'>#{email}</email>
            <address type='billing' id='1'>
               <street unit='172'>hollis</street>
               <region city='New York' country='US' postal-code='94608' province='New York province'/>
            </address>
         </customer>"
      )
    end

    it "Verify 'The provided email information already exists.' error message displays: " do
      expect(res).to eq('The provided email information already exists.')
    end
  end

  context 'TC01.003-registerCustomer - Invalid CallerID' do
    invalid_caller_id = 'invalid' + caller_id
    screen_name3 = CustomerManagement.generate_screenname
    username3, email3 = LFCommon.generate_email

    before :all do
      res = CustomerManagement.register_customer(invalid_caller_id, screen_name3, email3, username3)
    end

    it "Check 'Error while checking caller id' error message displays: " do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.004-registerCustomer - Duplicate Screen Name' do
    screen_name4 = screen_name

    before :all do
      username4, email4 = LFCommon.generate_email
      res = CustomerManagement.register_customer caller_id, screen_name4, email4, username4
    end

    it "Check 'Given screen name is not available, it is already in use:...' error message displays: " do
      expect(res).to eq('Given screen name is not available, it is already in use: ' + screen_name4)
    end
  end

  context 'TC01.006-registerCustomer - Duplicate UserName' do
    screen_name6 = CustomerManagement.generate_screenname
    username6 = username
    email6 = LFCommon.generate_email

    before :all do
      res = CustomerManagement.register_customer(caller_id, screen_name6, email6, username6)
    end

    it "Check 'An account with this email address already exists' error message displays: " do
      expect(res).to eq("An account with this email address already exists: #{cus_id}")
    end
  end

  context 'TC01.007-registerCustomer - Email is so long' do
    before :all do
      screen_name7 = CustomerManagement.generate_screenname
      username7 = LFCommon.generate_email
      email7 = 'One down, we keep going We released SoapUI 4.6.1 a few weeks ago (thank you SoapUI team!). You can read all about it at the bottom of this page. And as soon as 4.6.1 was out we started working on 4.6.2, which will be released a few weeks from now. The next big thing, but also the next thing We have started development on the next big release, with more REST testing improvements. We have reinforced the team, and now we are splitting it into two: a smaller team focused on 4.6.2 and a larger team focusing on the next big release Better personas We have invested a lot of time in creating personas to represent our users, and we are continuing to work with them. A lot. For us, the purpose of personas is to help us focus our user stories. We want to make sure our user stories match the personasÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ goals. This quickly puts an end to disagreements we might have while developing a certain feature. When we add the perspective of a certain persona it often becomes obvious which solution of a certain user story is the most appropriate. So learning about our users as to improve personas is an important task for us. When we meet real users and talk about the problems they face, it becomes important input for developing our personas. Error driven development Last week I was in Berlin to visit the Agile Testing Days conference where I did a small talk on focusing much more on preparing for error handling than you normally do when writing code. Surprisingly, there was a lot of interest, and I hopefully planted some ideas into peopleÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢s minds that will help in creating better quality software. DonÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢t forget; itÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢s not only about the tools, you also have to know what to do with them. Suggestions needed I received some really good feature suggestions during my short visit to the Agile Testing Days, and also on the SoapUI forums. But I always need more. Please let me know about the features you need, and the problems youÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢re having when testing. Go to the forums nd make yourself heard. Thanks! LetÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢s meet And if you happen to be in Stockholm, give us a call or email me at matti.hjelm@smartbear.com . We could meet, to let you personally describe what features you love or hate in SoapUI. Actually, the 21st of November we have a small after work pub, if you want to come just tell us in advance! Sincerely, Matti Hjelm Product Owner'

      res = CustomerManagement.register_customer(caller_id, screen_name7, email7, username7)
    end

    it "Check 'Unable to execute the call, there was a problem with data access.' error message displays: " do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end

  context 'TC01.008-registerCustomer - Email with special characters' do
    before :all do
      screen_name8 = CustomerManagement.generate_screenname
      username8 = LFCommon.generate_email
      email8 = '132132!#%^%#!#@leapfrog.test'

      res = CustomerManagement.register_customer(caller_id, screen_name8, email8, username8)
    end

    it 'Ignore will-not-fix defect: SQAAUTO-1334 [F6Q2_S13] Web Services: customer-management: registerCustomer: The service accepts email/username with special character (e.g: 132132!#@#!##@)' do
    end
  end

  context 'TC01.09-registerCustomer - Username is so long' do
    screen_name11 = CustomerManagement.generate_screenname
    username11 = 'One down, we keep going We released SoapUI 4.6.1 a few weeks ago (thank you SoapUI team!). You can read all about it at the bottom of this page. And as soon as 4.6.1 was out we started working on 4.6.2, which will be released a few weeks from now. The next big thing, but also the next thing We have started development on the next big release, with more REST testing improvements. We have reinforced the team, and now we are splitting it into two: a smaller team focused on 4.6.2 and a larger team focusing on the next big release Better personas We have invested a lot of time in creating personas to represent our users, and we are continuing to work with them. A lot. For us, the purpose of personas is to help us focus our user stories. We want to make sure our user stories match the personasÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ goals. This quickly puts an end to disagreements we might have while developing a certain feature. When we add the perspective of a certain persona it often becomes obvious which solution of a certain user story is the most appropriate. So learning about our users as to improve personas is an important task for us. When we meet real users and talk about the problems they face, it becomes important input for developing our personas. Error driven development Last week I was in Berlin to visit the Agile Testing Days conference where I did a small talk on focusing much more on preparing for error handling than you normally do when writing code. Surprisingly, there was a lot of interest, and I hopefully planted some ideas into peopleÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢s minds that will help in creating better quality software. DonÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢t forget; itÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢s not only about the tools, you also have to know what to do with them. Suggestions needed I received some really good feature suggestions during my short visit to the Agile Testing Days, and also on the SoapUI forums. But I always need more. Please let me know about the features you need, and the problems youÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢re having when testing. Go to the forums nd make yourself heard. Thanks! LetÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢s meet And if you happen to be in Stockholm, give us a call or email me at matti.hjelm@smartbear.com . We could meet, to let you personally describe what features you love or hate in SoapUI. Actually, the 21st of November we have a small after work pub, if you want to come just tell us in advance! Sincerely, Matti Hjelm Product Owner'
    email11 = LFCommon.generate_email

    before :all do
      res = CustomerManagement.register_customer(caller_id, screen_name11, email11, username11)
    end

    it "Verify 'Unable to execute the call, there was a problem with data access.' error message displays: " do
      expect(res).to eq('Unable to execute the call, there was a problem with data access.')
    end
  end

  context 'TC01.10-registerCustomer - Password is null' do
    before :all do
      screen_name10 = CustomerManagement.generate_screenname
      username10 = LFCommon.generate_email
      email10 = LFCommon.generate_email

      res = LFCommon.soap_call(
        endpoint,
        namespace,
        :register_customer,
        "<caller-id>#{caller_id}</caller-id>
        <customer id='' first-name='LTRC' last-name='Tester' middle-name='mdname' salutation='sal' locale='en_US' alias='LTRCTester' screen-name='#{screen_name10}' modified='' created=''>
         <phone type='mobile' extension='1' number='123456789'/>
          <credentials username='#{username10}' password='' hint='123456' expiration='2015-12-30T00:00:00' last-login=''/>
          <email opted='true' verified='true' type='work'>#{email10}</email>
          <address type='billing' id='1'>
            <street unit='172'>hollis</street>
            <region city='New York' country='US' postal-code='94608' province='New York province'/>
          </address>
        </customer>"
      )
    end

    it "Verify 'An invalid customer password was provided.' error message displays: " do
      expect(res).to eq('An invalid customer password was provided.')
    end
  end

  context 'TC01.11-registerCustomer - Password is so long' do
    screen_name11 = CustomerManagement.generate_screenname
    username11, email11 = LFCommon.generate_email
    password11 = 'One down, we keep going We released SoapUI 4.6.1 a few weeks ago (thank you SoapUI team!). You can read all about it at the bottom of this page. And as soon as 4.6.1 was out we started working on 4.6.2, which will be released a few weeks from now. The next big thing, but also the next thing We have started development on the next big release, with more REST testing improvements. We have reinforced the team, and now we are splitting it into two: a smaller team focused on 4.6.2 and a larger team focusing on the next big release Better personas We have invested a lot of time in creating personas to represent our users, and we are continuing to work with them. A lot. For us, the purpose of personas is to help us focus our user stories. We want to make sure our user stories match the personasÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ goals. This quickly puts an end to disagreements we might have while developing a certain feature. When we add the perspective of a certain persona it often becomes obvious which solution of a certain user story is the most appropriate. So learning about our users as to improve personas is an important task for us. When we meet real users and talk about the problems they face, it becomes important input for developing our personas. Error driven development Last week I was in Berlin to visit the Agile Testing Days conference where I did a small talk on focusing much more on preparing for error handling than you normally do when writing code. Surprisingly, there was a lot of interest, and I hopefully planted some ideas into peopleÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢s minds that will help in creating better quality software. DonÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢t forget; itÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢s not only about the tools, you also have to know what to do with them. Suggestions needed I received some really good feature suggestions during my short visit to the Agile Testing Days, and also on the SoapUI forums. But I always need more. Please let me know about the features you need, and the problems youÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢re having when testing. Go to the forums nd make yourself heard. Thanks! LetÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢s meet And if you happen to be in Stockholm, give us a call or email me at matti.hjelm@smartbear.com . We could meet, to let you personally describe what features you love or hate in SoapUI. Actually, the 21st of November we have a small after work pub, if you want to come just tell us in advance! Sincerely, Matti Hjelm Product Owner'

    before :all do
      res = CustomerManagement.register_customer(caller_id, screen_name11, username11, email11, password11)
    end

    it 'Ignore will-not-fix defect: SQAAUTO-1335 [F6Q2_S13] Web Services: customer-management: registerCustomer: The service accepts any length of entered password text' do
    end
  end

  context 'TC01.12-registerCustomer - Verify account is created successfully with special password' do
    password12 = '!@$%^123'
    screen_name12 = CustomerManagement.generate_screenname
    email12 = username12 = LFCommon.generate_email

    before :all do
      res = CustomerManagement.register_customer(caller_id, screen_name12, username12, email12, password12)
    end

    it "Verify username: #{username12}" do
      expect(res.xpath('//customer/credentials/@username').text).to eq(username12)
    end

    it "Verify password: #{password12}" do
      expect(res.xpath('//customer/credentials/@password').text).to eq(password12)
    end
  end
end
