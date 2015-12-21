require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'

=begin
Verify identifyCustomer service works correctly
=end

describe "TC14.001 - identifyCustomer - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_CALLER_ID
  username = email = LFCommon.generate_email
  screen_name = CustomerManagement.generate_screenname
  customer_id = nil
  password = '123456'
  res = nil

  it 'Precondition - register customer' do
    response = CustomerManagement.register_customer(caller_id, screen_name, email, username)
    xml_response = CustomerManagement.get_customer_info(response)
    customer_id = xml_response[:id]
  end

  context 'TC14.001 - identifyCustomer - Successful Response' do
    resp_customer_id1 = resp_username1 = resp_email1 = nil

    before :all do
      xml_res = CustomerManagement.identify_customer(caller_id, username, password)
      resp_customer_id1 = xml_res.xpath('//customer').attr('id').text
      resp_username1 = xml_res.xpath('//customer/credentials').attr('username').text
      resp_email1 = xml_res.xpath('//customer/email').text
    end

    it 'Check Customer ID responses: ' do
      expect(resp_customer_id1).to eq(customer_id)
    end

    it 'Check Username responses: ' do
      expect(resp_username1).to eq(username)
    end

    it 'Check Email responses: ' do
      expect(resp_email1).to eq(email)
    end
  end

  context 'TC14.002 - identifyCustomer - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = CustomerManagement.identify_customer(caller_id2, username, password)
    end

    it "Verify 'Error while checking caller id' error message responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC14.003 - identifyCustomer - Access Denied' do
    username3 = 'nonexistence'

    before :all do
      res = CustomerManagement.identify_customer(caller_id, username3, password)
    end

    it "Verify 'A customer for the given credentials doesn't exist.' error message responses" do
      expect(res).to eq("A customer for the given credentials doesn't exist.")
    end
  end

  context 'TC14.004 - identifyCustomer - Invalid Request' do
    username4 = ''
    password4 = ''

    before :all do
      res = CustomerManagement.identify_customer(caller_id, username4, password4)
    end

    it "Verify 'A customer for the given credentials doesn't exist.' error message responses" do
      expect(res).to eq("A customer for the given credentials doesn't exist.")
    end
  end

  context 'TC14.005 - identifyCustomer - Password is null' do
    password5 = ''

    before :all do
      res = CustomerManagement.identify_customer(caller_id, username, password5)
    end

    it "Verify 'The password supplied doesn't match for this customer' error message responses" do
      expect(res).to eq("The password supplied doesn't match for this customer")
    end
  end

  context 'TC14.006 - identifyCustomer - Password is so long' do
    password6 = 'One down, we keep going We released SoapUI 4.6.1 a few weeks ago (thank you SoapUI team!). You can read all about it at the bottom of this page. And as soon as 4.6.1 was out we started working on 4.6.2, which will be released a few weeks from now. The next big thing, but also the next thing We have started development on the next big release, with more REST testing improvements. We have reinforced the team, and now we are splitting it into two: a smaller team focused on 4.6.2 and a larger team focusing on the next big release Better personas We have invested a lot of time in creating personas to represent our users, and we are continuing to work with them. A lot. For us, the purpose of personas is to help us focus our user stories. We want to make sure our user stories match the personasÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ goals. This quickly puts an end to disagreements we might have while developing a certain feature. When we add the perspective of a certain persona it often becomes obvious which solution of a certain user story is the most appropriate. So learning about our users as to improve personas is an important task for us. When we meet real users and talk about the problems they face, it becomes important input for developing our personas. Error driven development Last week I was in Berlin to visit the Agile Testing Days conference where I did a small talk on focusing much more on preparing for error handling than you normally do when writing code. Surprisingly, there was a lot of interest, and I hopefully planted some ideas into peopleÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢s minds that will help in creating better quality software. DonÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢t forget; itÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢s not only about the tools, you also have to know what to do with them. Suggestions needed I received some really good feature suggestions during my short visit to the Agile Testing Days, and also on the SoapUI forums. But I always need more. Please let me know about the features you need, and the problems youÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢re having when testing. Go to the forums nd make yourself heard. Thanks!'

    before :all do
      res = CustomerManagement.identify_customer(caller_id, username, password6)
    end

    it "Verify 'The password supplied doesn't match for this customer' error message responses" do
      expect(res).to eq("The password supplied doesn't match for this customer")
    end
  end

  context 'TC14.007 - identifyCustomer - Password is wrong' do
    password7 = 'abcdef'

    before :all do
      CustomerManagement.identify_customer(caller_id, username, password7)
    end

    it "Verify 'The password supplied doesn't match for this customer' error message responses" do
      expect(res).to eq("The password supplied doesn't match for this customer")
    end
  end
end
