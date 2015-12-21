require File.expand_path('../../spec_helper', __FILE__)

=begin
MyPals Heartbeat checking: Verify MyPals endpoints are alive (response status is 200)
=end

describe "MyPals HeartBeat Checking - #{Misc::CONST_ENV}" do
  endpoint_file = "#{Misc::CONST_PROJECT_PATH}/data/mypals_endpoint.txt"
  endpoints = LFCommon.endpoint_status endpoint_file, LFSOAP::CONST_MYPALS_ENV

  endpoints.each do |endpoint|
    context "URL: #{endpoint[:url]}" do
      it "response status: #{endpoint[:res]}" do
        expect(endpoint[:res]).to eq('200')
      end
    end
  end
end
