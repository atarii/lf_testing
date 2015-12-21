require File.expand_path('../../../spec_helper', __FILE__)
require 'customer_management'
require 'authentication'
require 'child_management'

=begin
Verify fetchChildUploadHistory service works correctly
=end

describe "TS07 - fetchChildUploadHistory - #{Misc::CONST_ENV}" do
  session = nil
  child_id = nil

  before :all do
    reg_cus_response =  CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
    cus_info = CustomerManagement.get_customer_info(reg_cus_response)
    session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])
    reg_chi_response = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_info[:id])

    child_id = reg_chi_response.xpath('//child/@id').text
  end

  context 'TC07.001 - fetchChildUploadHistory - Successful Response' do
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

      res = client.call(:fetch_child_upload_history, message: message)
    end

    it 'Verify response status code = 200' do
      expect(res.http.code).to eq(200)
    end
  end

  context 'TC07.002 - fetchChildUploadHistory - Invalid CallerID' do
    res = nil

    before :all do
      res = ChildManagement.fetch_child_upload_history('invalid', 'service', session, child_id)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC07.003 - fetchChildUploadHistory - Invalid Request' do
    res = nil

    before :all do
      res = ChildManagement.fetch_child_upload_history(Misc::CONST_CALLER_ID, 'service', session, 'aaaa')
    end

    it 'Verify faultstring is returned: there is no parent/child relationship between the customer and child' do
      expect(res).to eq('there is no parent/child relationship between the customer and child')
    end
  end

  context 'TC07.004 - fetchChildUploadHistory - Access Denied' do
    res = nil

    before :all do
      res = ChildManagement.fetch_child_upload_history(Misc::CONST_CALLER_ID, 'service', 'invalid', 1_111_111)
    end

    it 'Verify faultstring is returned: Session is invalid: invalid' do
      expect(res).to eq('Session is invalid: invalid')
    end
  end
end
