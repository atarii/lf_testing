require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'

=begin
Verify updateChild service works correctly
=end

describe "TS05 - updateChild - #{Misc::CONST_ENV}" do
  endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:endpoint]
  namespace = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:namespace]
  session = nil
  child_id = nil
  cus_id = nil

  before :all do
    reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    cus_id = cus_info[:id]

    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])

    reg_chi_response = ChildManagement.register_child_credentials(Misc::CONST_CALLER_ID, session, cus_id)
    child_id = reg_chi_response.xpath('//child/@id').text
  end

  context 'TC05.001 - updateChild - Successful Response' do
    scr_name_exp = 'new_scrname'
    name_exp = 'newname'
    grade_exp = '2'
    gender_exp = 'female'
    dob_exp = '2013-10-06'

    scr_name_act = nil
    name_act = nil
    grade_act = nil
    gender_act = nil
    dob_act = nil

    before :all do
      LFCommon.soap_call(
        endpoint,
        namespace,
        :update_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <child id='#{child_id}' name='#{name_exp}' dob='#{dob_exp}' grade='#{grade_exp}' gender='#{gender_exp}' screen-name='#{scr_name_exp}' locale='fr_FR' titles='' last-upload=''/>"
      )

      fet_chi_res = ChildManagement.fetch_child(Misc::CONST_CALLER_ID, session, child_id)
      scr_name_act = fet_chi_res.xpath('//child/@screen-name').text
      name_act = fet_chi_res.xpath('//child/@name').text
      grade_act = fet_chi_res.xpath('//child/@grade').text
      gender_act = fet_chi_res.xpath('//child/@gender').text
      dob_act = fet_chi_res.xpath('//child/@dob').text
    end

    it 'Check screen-name' do
      expect(scr_name_exp).to eq(scr_name_act)
    end

    it 'Check name' do
      expect(name_exp).to eq(name_act)
    end

    it 'Check grade' do
      expect(grade_exp).to eq(grade_act)
    end

    it 'Check gender' do
      expect(gender_exp).to eq(gender_act)
    end

    it 'Check dob' do
      date = Date.parse(dob_act)
      dob_fet = Date.strptime('%s-%s-%s' % [date.year, date.mon, date.day], '%Y-%m-%d')
      expect(dob_exp).to eq(dob_fet.to_s)
    end
  end

  context 'TC05.002 - updateChild - Duplicate Child Name' do
    upd_chi_res = nil
    child_name_2nd = nil

    before :all do
      # register 2nd child
      reg_chi_response = ChildManagement.register_child_credentials(Misc::CONST_CALLER_ID, session, cus_id)
      child_name_2nd = reg_chi_response.xpath('//child/@name').text

      # update 2nd child with child-name of 1st child
      upd_chi_res = LFCommon.soap_call(
        endpoint,
        namespace,
        :update_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
        <session type='service'>#{session}</session>
        <child id='#{child_id}' name='#{child_name_2nd}' dob='2013-10-06-07:00' grade='2' gender='female' screen-name='new_scrname' locale='fr_FR' titles='' last-upload=''/>"
      )
    end

    it 'Verify faultstring is returned: Child name already in use ...' do
      expect(upd_chi_res).to eq("Child name already in use #{child_name_2nd}")
    end
  end

  context 'TC05.003 - updateChild - Duplicate Username' do
    upd_chi_res = nil
    child_username_2nd = nil

    before :all do
      # register 2nd child
      reg_chi_response = ChildManagement.register_child_credentials(Misc::CONST_CALLER_ID, session, cus_id)
      child_username_2nd = reg_chi_response.xpath('//child/credentials/@username').text

      # update 2nd child with child-name of 1st child
      upd_chi_res = LFCommon.soap_call(
        endpoint,
        namespace,
        :update_child,
        "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
         <session type='service'>#{session}</session>
         <child id='#{child_id}' name='childname' dob='2013-10-06-07:00' grade='2' gender='female' screen-name='new_scrname' locale='fr_FR' titles='' last-upload=''>
         <credentials username='#{child_username_2nd}' password='123456'/></child>"
      )
    end

    it 'Verify faultstring is returned: Username "..." is not available' do
      expect(upd_chi_res).to eq("Username \"#{child_username_2nd.downcase}\" is not available")
    end
  end

  context 'TC05.004 - updateChild - Invalid Request' do
    upd_chi_res = nil

    before :all do
      upd_chi_res = ChildManagement.update_child(Misc::CONST_CALLER_ID, session, 'invalid')
    end

    it 'Verify faultstring is returned: Unmarshalling Error: Not a number: invalid' do
      expect(upd_chi_res.strip).to eq('Unmarshalling Error: Not a number: invalid')
    end
  end

  context 'TC05.005 - updateChild - Invalid CallerID' do
    upd_chi_res = nil

    before :all do
      upd_chi_res = ChildManagement.update_child('invalid', session, child_id)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(upd_chi_res).to eq('Error while checking caller id')
    end
  end

  context 'TC05.006 - updateChild - Access Denied' do
    upd_chi_res = nil

    before :all do
      upd_chi_res = ChildManagement.update_child(Misc::CONST_CALLER_ID, 'invalid', child_id)
    end

    it 'Verify faultstring is returned: Session is invalid: invalid' do
      expect(upd_chi_res).to eq('Session is invalid: invalid')
    end
  end
end
