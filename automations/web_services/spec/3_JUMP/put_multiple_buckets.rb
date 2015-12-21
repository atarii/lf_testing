require File.expand_path('../../spec_helper', __FILE__)
require 'restfulcalls_jump'

=begin
Verify PUT_MULTIPLE_BUCKETS service work correctly (REST call)
=end

# Get all data for PUT_LEAPBAND_DATA
rs = Connection.my_sql_connection MysqlStringConst::CONST_PUT_MULTIPLE_BUCKETS
cus = Customer.new

describe "PUT_MULTIPLE_BUCKETS rest call checking - #{Misc::CONST_ENV}" do
  rs.each_hash do |row|
    context "#{row['test_description']}" do
      # get output data
      rs_output = Connection.get_restful_output_by_restful_calls_id(row['id']).fetch_hash

      if !row['status'].nil? && row['status'].downcase == 'true'
        # pre-condition: create new customer
        status = cus.update_account(row['id'])

        it 'Verify account is updated successfully' do
          expect(status).to eq(true)
        end

        response = put_multiple_buckets row['callerid'], cus.session, cus.serial, row['upload_data']

        # for TC current data
        if !row['upload_data_1'].nil? && row['upload_data_1'] != ''
          response = put_multiple_buckets row['callerid'], cus.session, cus.serial, row['upload_data_1']
        end
      else
        response = put_multiple_buckets row['callerid'], row['session'], row['devserial'], row['upload_data']
      end

      it "Verify output response as expected: #{rs_output['data']}" do
        expect(remove_dynamic_source(JSON.pretty_generate(response))).to eq(remove_dynamic_source(JSON.pretty_generate(JSON.parse(rs_output['data']))))
      end
    end
  end
end
