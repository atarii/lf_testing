require File.expand_path('../../spec_helper', __FILE__)
require 'restfulcalls_jump'

=begin
Verify ONST_PUT_PETATHLON_UPDATE_FIELDS service work correctly (REST call)
=end

# Get all data for CONST_PUT_PETATHLON_UPDATE_FIELDS
rs = Connection.my_sql_connection MysqlStringConst::CONST_PUT_PETATHLON_UPDATE_FIELDS
cus = Customer.new

describe "ONST_PUT_PETATHLON_UPDATE_FIELDS rest call checking - #{Misc::CONST_ENV}" do
  rs.each_hash do |row|
    response = rs_output_wo_ts = nil
    rs_output = Connection.get_restful_output_by_restful_calls_id(row['id']).fetch_hash

    context "#{row['test_description']}" do
      before :all do
        if row['status'].downcase == 'true'
          # pre-condition: create new customer
          cus.update_account(row['id'])

          put_petathlon_companion_app_data row['callerid'], cus.session, cus.serial, row['upload_data']

          # if upload_data_1 <> null, continue sending a request
          put_petathlon_companion_app_data row['callerid'], cus.session, cus.serial, row['upload_data_1']
        end

        response = get_petathlon_companion_app_data(row['callerid'], cus.session, cus.serial)
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
