require File.expand_path('../../spec_helper', __FILE__)
require 'restfulcalls_jump'

=begin
Verify GET_LEAPBAND_DATA service work correctly (REST call)
=end

# Get all data for PUT_LEAPBAND_DATA
rs = Connection.my_sql_connection MysqlStringConst::CONST_GET_LEAPBAND_DATA

describe "GET_LEAPBAND_DATA rest call checking - #{Misc::CONST_ENV}" do
  rs.each_hash do |row|
    response = nil
    rs_output = Connection.get_restful_output_by_restful_calls_id(row['id']).fetch_hash

    before :all do
      response = get_leapband_data row['callerid'], row['session'], row['devserial']
    end

    context "#{row['test_description']}" do
      it "Verify output response as expected: #{rs_output['data']}" do
        expect(remove_dynamic_timestamp(JSON.pretty_generate(response))).to eq(remove_dynamic_timestamp(JSON.pretty_generate(JSON.parse(rs_output['data']))))
      end
    end
  end
end
