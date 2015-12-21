require File.expand_path('../../spec_helper', __FILE__)
require 'restfulcalls'

=begin
REST call: Verify fetch_device service works correctly
=end

# Get all data for fetch_device
rs = Connection.my_sql_connection MysqlStringConst::CONST_FETCH_DEVICE

describe "TS02 - Fetch device rest call checking - #{Misc::CONST_ENV}" do
  rs.each_hash do |row|
    response = nil
    rs_output = Connection.get_restful_output_by_restful_calls_id(row['id']).fetch_hash

    before :all do
      response = fetch_device row['callerid'], row['devserial']
    end

    context "#{row['test_description']}" do
      it "Verify output response as expected: #{rs_output['data']}" do
        expect(JSON.pretty_generate(response)).to eq(JSON.pretty_generate(JSON.parse(rs_output['data'])))
      end
    end
  end
end
