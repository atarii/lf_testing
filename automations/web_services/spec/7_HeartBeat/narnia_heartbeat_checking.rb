require File.expand_path('../../spec_helper', __FILE__)

=begin
Narnia Heartbeat checking: Verify Narnia endpoints are alive (response status is 400 or 405)
=end

describe "Narnia HeartBeat Checking - #{Misc::CONST_ENV}" do
  endpoint_file = "#{Misc::CONST_PROJECT_PATH}/data/narnia_endpoints.txt"
  endpoints = LFCommon.endpoint_status endpoint_file, LFSOAP::CONST_NARNIA_ENV

  endpoints.each do |endpoint|
    context "URL: #{endpoint[:url]}" do
      if endpoint[:res] == '400'
        it "response status: #{endpoint[:res]}" do
          expect(endpoint[:res]).to eq('400')
        end
      else
        it "response status: #{endpoint[:res]}" do
          expect(endpoint[:res]).to eq('405')
        end
      end
    end
  end
end
