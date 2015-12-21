require File.expand_path('../../spec_helper', __FILE__)
require 'restfulcalls_jump'

=begin
Verify PUT_LEAPBAND_DATA service work correctly (REST call)
=end

# Get all data for PUT_LEAPBAND_DATA
rs = Connection.my_sql_connection MysqlStringConst::CONST_PUT_LEAPBAND_DATA
PUT_SUCCESSFUL_MESSAGE_CONST = "{\"data\":{\"updated\":true},\"status\":true}"
cus = Customer.new

describe "PUT_LEAPBAND_DATA rest call checking - #{Misc::CONST_ENV}" do
  rs.each_hash do |row|
    # get output data
    rs_output = Connection.get_restful_output_by_restful_calls_id(row['id']).fetch_hash

    context "#{row['test_description']}" do
      it "Verify output response as expected: #{rs_output['data']}" do
        if row['status'].downcase == 'true'
          # pre-condition: create new account
          cus.update_account(row['id'])

          # send put leapband request
          response = put_leapband_data row['callerid'], cus.session, cus.serial, row['upload_data']
          expect(JSON.pretty_generate(response)).to eq(JSON.pretty_generate(JSON.parse(PUT_SUCCESSFUL_MESSAGE_CONST)))

          # send get leapband to verify data as expectation
          get_leapband_data_response = get_leapband_data row['callerid'], cus.session, cus.serial
          get_leapband_data_response.delete('timestamp')

          rs_output_wo_ts = JSON.parse(rs_output['data'])
          rs_output_wo_ts.delete('timestamp')

          expect(remove_dynamic_source(JSON.pretty_generate(get_leapband_data_response))).to eq(remove_dynamic_source(JSON.pretty_generate(rs_output_wo_ts)))
        else
          response = put_leapband_data row['callerid'], row['session'], row['devserial'], row['upload_data']
          expect(remove_dynamic_source(JSON.pretty_generate(response))).to eq(remove_dynamic_source(JSON.pretty_generate(JSON.parse(rs_output['data']))))
        end
      end
    end
  end
end
