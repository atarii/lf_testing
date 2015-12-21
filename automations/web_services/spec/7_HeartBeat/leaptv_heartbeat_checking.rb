require File.expand_path('../../spec_helper', __FILE__)

=begin
LeapTV Heartbeat checking: Verify LeapTV endpoints are alive (response status is 200)
=end

describe "LeapTV HeartBeat Checking - #{Misc::CONST_ENV}" do
  endpoint_file = "#{Misc::CONST_PROJECT_PATH}/data/leaptv_endpoint.txt"
  endpoints = LFCommon.endpoint_status endpoint_file, GLASGOW::CONST_GLASGOW_ENV

  endpoints.each do |endpoint|
    context "URL: #{endpoint[:url]}" do
      it "response status: #{endpoint[:res]}" do
        expect(endpoint[:res]).to eq('200')
      end
    end
  end
end
