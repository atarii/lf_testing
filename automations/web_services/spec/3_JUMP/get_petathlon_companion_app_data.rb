require File.expand_path('../../spec_helper', __FILE__)
require 'restfulcalls_jump'

=begin
Verify CONST_GET_PETATHLON_COMPANION_APP_DATA service work correctly (REST call)
=end

# Get all data for CONST_GET_PETATHLON_COMPANION_APP_DATA
rs = Connection.my_sql_connection MysqlStringConst::CONST_GET_PETATHLON_COMPANION_APP_DATA
cus = Customer.new

describe "CONST_GET_PETATHLON_COMPANION_APP_DATA rest call checking - #{Misc::CONST_ENV}" do
  rs.each_hash do |row|
    response = rs_output_wo_ts = nil

    context "#{row['test_description']}" do
      rs_output = Connection.get_restful_output_by_restful_calls_id(row['id']).fetch_hash

      before :all do
        if row['status'] == 'true'
          # pre-condition: create new customer
          cus.update_account(row['id'])

          # send request
          put_petathlon_companion_app_data row['callerid'], cus.session, cus.serial, row['upload_data']
          response = get_petathlon_companion_app_data(row['callerid'], cus.session, cus.serial)
        else
          response = get_petathlon_companion_app_data(row['callerid'], row['session'], row['devserial'])
        end

        response.delete('timestamp')
        rs_output_wo_ts = JSON.parse(rs_output['data'])
        rs_output_wo_ts.delete('timestamp')
      end

      it "Verify output response as expected: #{rs_output['data']}" do
        expect(response).to eq(rs_output_wo_ts)
      end
    end
  end
end
