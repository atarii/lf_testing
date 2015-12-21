require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'

=begin
Verify unlinkPlayData service works correctly
=end

describe "TS09 - unlinkPlayData - #{Misc::CONST_ENV}" do
  session = nil
  child_id = nil

  before :all do
    reg_cus_response =  CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
    reg_chi_response = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_info[:id])

    child_id = reg_chi_response.xpath('//child/@id').text
  end

  context 'TC09.001 - unlinkPlayData - Successful Response' do
    res = nil
    before :all do
      endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:endpoint]
      namespace = LFSOAP::CONST_INMON_ENDPOINTS[:child_management][:namespace]

      client = Savon.client(
        endpoint: endpoint,
        namespace: namespace,
        log: true,
        pretty_print_xml: true,
        namespace_identifier: :man
      )

      message = "<caller-id>#{Misc::CONST_CALLER_ID}</caller-id>
                  <session type='service'>#{session}</session>
                 <child-id>#{child_id}</child-id>"

      res = client.call(:unlink_play_data, message: message)
    end

    it 'Verify response status code = 200' do
      expect(res.http.code).to eq(200)
    end
  end

  context 'TC09.002 - unlinkPlayData - Invalid CallerID' do
    res = nil

    before :all do
      res = ChildManagement.unlink_play_data('invalid', session, child_id)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC09.003 - unlinkPlayData - Invalid Request' do
    res = nil

    before :all do
      res = ChildManagement.unlink_play_data(Misc::CONST_CALLER_ID, session, 'aaaa')
    end

    it 'Verify faultstring is returned: Unable to complete unlinkPlayData for childID "0"' do
      expect(res).to eq('Unable to complete unlinkPlayData for childID "0"')
    end
  end

  context 'TC09.004 - unlinkPlayData - Access Denied' do
    res = nil

    before :all do
      res = ChildManagement.unlink_play_data(Misc::CONST_CALLER_ID, 'invalid', 1_111_111)
    end

    it 'Verify faultstring is returned: Session is invalid: invalid' do
      expect(res).to eq('Session is invalid: invalid')
    end
  end

  context 'TC09.005 - unlinkPlayData - Nonexistent Child' do
    res = nil

    before :all do
      res = ChildManagement.unlink_play_data(Misc::CONST_CALLER_ID, session, 111)
    end

    it 'Verify faultstring is returned: Unable to complete unlinkPlayData for childID "111"' do
      expect(res).to eq('Unable to complete unlinkPlayData for childID "111"')
    end
  end
end
