require File.expand_path('../../spec_helper', __FILE__)
require 'restfulcalls'

=begin
REST call: Verify get_package_dependencies service works correctly
=end

# Get all data for GET_PACKAGE_DEPENDENCIES
rs = Connection.my_sql_connection MysqlStringConst::CONST_GET_PACKAGE_DEPENDENCIES

describe "TS04 - Get_package_dependencies rest call checking - #{Misc::CONST_ENV}" do
  rs.each_hash do |row|
    response = nil
    rs_output = Connection.get_restful_output_by_restful_calls_id(row['id']).fetch_hash

    before :all do
      response = package_dependencies row['callerid'], row['query_string']
    end

    context "#{row['test_description']}" do
      it "Verify output response as expected: #{rs_output['data']}" do
        expect(JSON.pretty_generate(response)).to eq(JSON.pretty_generate(JSON.parse(rs_output['data'])))
      end
    end
  end
end
