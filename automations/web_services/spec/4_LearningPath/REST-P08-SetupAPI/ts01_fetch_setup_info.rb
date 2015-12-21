require File.expand_path('../../../spec_helper', __FILE__)
require 'setup_info'

=begin
REST call: Verify fetchSetupInfo service works correctly
=end

describe "TS01 - fetch SetupInfo - #{Misc::CONST_ENV}" do
  caller_id = Misc::CONST_REST_CALLER_ID
  res = nil

  context 'TC01.001 - fetch SetupInfo - Successful Response' do
    before :all do
      res = SetupInfo.fetch_setup_info(caller_id)
    end

    it 'Verify response [status] is true' do
      expect(res['status']).to eq(true)
    end

    it 'Verify data responses' do
      expect(res['data']).not_to be_empty
    end
  end
end
