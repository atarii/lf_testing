require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'

=begin
Verify lookupChildByUsername service works correctly
=end

describe "TS04 - lookupChildByUsername - #{Misc::CONST_ENV}" do
  session = nil
  cus_id = nil
  child_username = nil

  before :all do
    reg_cus_response =  CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    cus_id = cus_info[:id]

    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
  end

  context 'TC04.001 - lookupChildByUsername - Successful Response' do
    child_id_exp = nil
    count_children_exp = nil
    child_username_exp = nil

    child_id_act = nil
    child_username_act = nil

    before :all do
      reg_chi_response = ChildManagement.register_child_credentials(Misc::CONST_CALLER_ID, session, cus_id)
      child_id_exp = reg_chi_response.xpath('//child/@id').text
      child_username_exp = reg_chi_response.xpath('//child/credentials/@username').text
      child_username = child_username_exp

      loo_chi_res = ChildManagement.lookup_child_by_username(Misc::CONST_CALLER_ID, session, child_username_exp)
      child_username_act = loo_chi_res.xpath('//child/credentials/@username').text
      child_id_act = loo_chi_res.xpath('//child/@id').text
      count_children_exp = loo_chi_res.xpath('count(//child)').to_s.to_i
    end

    it 'Verify number of children returns: 1' do
      expect(count_children_exp).to eq(1)
    end

    it 'Verify child-id' do
      expect(child_id_exp).to eq(child_id_act)
    end

    it 'Verify username' do
      expect(child_username_exp.downcase).to eq(child_username_act.downcase)
    end
  end

  context 'TC04.002 - lookupChildByUsername - Invalid CallerID' do
    loo_chi_res = nil

    before :all do
      loo_chi_res = ChildManagement.lookup_child_by_username('invalid', session, child_username)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(loo_chi_res).to eq('Error while checking caller id')
    end
  end

  context 'TC04.003 - lookupChildByUsername - Invalid Request' do
    loo_chi_res = nil

    before :all do
      loo_chi_res = ChildManagement.lookup_child_by_username(Misc::CONST_CALLER_ID, session, child_username, 'application')
    end

    it 'Verify faultstring is returned: Unable to authenticate account' do
      expect(loo_chi_res).to eq('Unable to authenticate account')
    end
  end

  context 'TC04.004 - lookupChildByUsername - Access Denied' do
    loo_chi_res = nil

    before :all do
      loo_chi_res = ChildManagement.lookup_child_by_username(Misc::CONST_CALLER_ID, 'invalid', child_username)
    end

    it 'Verify faultstring is returned: Session is invalid: invalid' do
      expect(loo_chi_res).to eq('Session is invalid: invalid')
    end
  end

  context 'TC04.005 - lookupChildByUsername - Nonexistent Username' do
    loo_chi_res = nil

    before :all do
      loo_chi_res = ChildManagement.lookup_child_by_username(Misc::CONST_CALLER_ID, session, 'non-existent1@@@')
    end

    it 'Verify faultstring is returned: Unable to complete lookupChildByUsername for username "non-existent1@@@"' do
      expect(loo_chi_res).to eq('Unable to complete lookupChildByUsername for username "non-existent1@@@"')
    end
  end
end
