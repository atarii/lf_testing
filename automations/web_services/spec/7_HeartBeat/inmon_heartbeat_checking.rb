require File.expand_path('../../spec_helper', __FILE__)

=begin
INMON Heartbeat checking: Verify INMON endpoints are alive (response status is 200)
=end

describe "INMON HeartBeat Checking - #{Misc::CONST_ENV}" do
  endpoint_file = "#{Misc::CONST_PROJECT_PATH}/data/webservice_endpoint.txt"
  endpoints = LFCommon.endpoint_status endpoint_file, LFSOAP::CONST_INMON_URL

  endpoints.each do |endpoint|
    context "URL: #{endpoint[:url]}" do
      it "response status: #{endpoint[:res]}" do
        expect(endpoint[:res]).to eq('200')
      end
    end
  end
end
