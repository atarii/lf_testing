require File.expand_path('../../spec_helper', __FILE__)
require 'restfulcalls'
require 'license_management'

=begin
REST call: Verify remove_installation service works correctly
=end

# Get all data for REPORT_INSTALLATION
rs = Connection.my_sql_connection MysqlStringConst::CONST_REMOVE_INSTALLATION

describe "TS05 - Remove_installation rest call checking - #{Misc::CONST_ENV}" do
  rs.each_hash do |row|
    response = nil
    rs_output = Connection.get_restful_output_by_restful_calls_id(row['id']).fetch_hash

    before :all do
      response = remove_installation row['callerid'], row['session'], row['devserial'], row['pkgid']
    end

    context "#{row['test_description']}" do
      it "Verify output response as expected: #{rs_output['data']}" do
        expect(JSON.pretty_generate(response)).to eq(JSON.pretty_generate(JSON.parse(rs_output['data'])))
      end

      after :all do
        LicenseManagement.install_package row['callerid'], row['devserial'], '0', row['pkgid'] if (row['status'] == 'true')
      end
    end
  end
end
