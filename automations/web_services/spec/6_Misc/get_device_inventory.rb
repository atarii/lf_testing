require File.expand_path('../../spec_helper', __FILE__)
require 'restfulcalls'
require 'customer_management'
require 'authentication'
require 'child_management'
require 'owner_management'
require 'device_management'
require 'soft_good_management'
require 'device_profile_management'

=begin
REST call: Verify get_device_inventory service works correctly
=end

# Get all data for GET_DEVICE_INVENTORY
rs = Connection.my_sql_connection MysqlStringConst::CONST_GET_DEVICE_INVENTORY
rs.data_seek(1)

describe "TS03 - Get device inventory rest call checking - #{Misc::CONST_ENV}" do
  device_serial = DeviceManagement.generate_serial
  license_id = device_inventory_res = nil
  slot = 0
  package_id = 'MULT-0x001B001A-000000'

  context 'TC12: get device inventory' do
    it 'Pre-condition: Install \'MULT-0x001B001A-000000\' package' do
      reg_cus_response = CustomerManagement.register_customer(Misc::CONST_CALLER_ID, CustomerManagement.generate_screenname, LFCommon.generate_email, LFCommon.generate_email)
      cus_info = CustomerManagement.get_customer_info(reg_cus_response)
      cus_id = cus_info[:id]

      session = Authentication.get_service_session(Misc::CONST_CALLER_ID, cus_info[:username], cus_info[:password])

      reg_chi_response = ChildManagement.register_child(Misc::CONST_CALLER_ID, session, cus_id)
      child_id = reg_chi_response.xpath('//child/@id').text

      OwnerManagement.claim_device(Misc::CONST_CALLER_ID, session, cus_id, device_serial, 'leappad2', slot, 'profile', child_id)
      DeviceProfileManagement.assign_device_profile(Misc::CONST_CALLER_ID, cus_id, device_serial, 'leappad2', slot, 'profile', child_id)
      grant_license_res = LicenseManagement.grant_license(Misc::CONST_CALLER_ID, session, cus_id, device_serial, package_id)
      license_id = grant_license_res.xpath('//license/@id').text

      LicenseManagement.install_package(Misc::CONST_CALLER_ID, device_serial, slot, package_id)
      PackageManagement.report_installation(Misc::CONST_CALLER_ID, session, device_serial, slot, package_id, license_id)

      device_inventory_res = device_inventory Misc::CONST_CALLER_ID, session, device_serial
    end

    it 'Verify status is true' do
      expect(device_inventory_res['status']).to eq(true)
    end

    it 'Verify userSlot is ' + slot.to_s do
      expect(device_inventory_res['data']['packages'][0]['userSlot']).to eq(slot)
    end

    it 'Verify installStatus is INSTALLED' do
      expect(device_inventory_res['data']['packages'][0]['installStatus']).to eq('INSTALLED')
    end

    it 'Verify package id is ' + package_id do
      expect(device_inventory_res['data']['packages'][0]['id']).to eq(package_id)
    end

    it 'Verify package licenseId is returned' do
      expect(device_inventory_res['data']['packages'][0]['licenseId'].to_s).to eq(license_id)
      pending "***Verify package licenseId is #{license_id}"
    end

    it 'Verify type is Application' do
      expect(device_inventory_res['data']['packages'][0]['type']).to eq('Application')
    end

    it 'Verify version is empty' do
      expect(device_inventory_res['data']['packages'][0]['version']).to eq('')
    end

    it 'Verify url is http://qa-digitalcontent.leapfrog.com/packages/0x001B001A/MULT-0x001B001A-000000.lf3' do
      expect(device_inventory_res['data']['packages'][0]['url']).to eq('http://qa-digitalcontent.leapfrog.com/packages/0x001B001A/MULT-0x001B001A-000000.lf3')
    end
  end

  rs.each_hash do |row|
    response = nil
    rs_output = Connection.get_restful_output_by_restful_calls_id(row['id']).fetch_hash

    before :all do
      response = device_inventory row['callerid'], row['session'], row['devserial']
    end

    context "#{row['test_description']}" do
      it "Verify output response as expected: #{rs_output['data']}" do
        expect(JSON.pretty_generate(response)).to eq(JSON.pretty_generate(JSON.parse(rs_output['data'])))
      end
    end
  end
end
