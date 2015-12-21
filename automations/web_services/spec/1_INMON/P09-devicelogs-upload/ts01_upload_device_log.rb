require File.expand_path('../../../spec_helper', __FILE__)
require 'device_log_upload'

=begin
Verify uploadDeviceLog service works correctly
=end

describe "TS01 - uploadDeviceLog - #{Misc::CONST_ENV}" do
  caller_id = '755e6f29-b7c8-4b98-8739-a1a7096f879e'
  device_serial = Misc::CONST_DEV_SERIAL
  local_time = '2013-11-11T00:00:00'
  filename = 'Jewel_Train_2.log'
  log_data = 'cid:jeweltrain2.bin'
  slot = '0'
  res = nil

  context 'TC01.001 - uploadDeviceLog - Successful Response' do
    soap_fault = nil

    before :all do
      xml_res = DeviceLogUpload.upload_device_log(caller_id, filename, slot, device_serial, local_time, log_data)
      soap_fault = xml_res.xpath('//faultcode').count
    end

    it "Verify 'uploadDeviceLog' calls successfully" do
      expect(soap_fault).to eq(0)
    end
  end

  context 'TC01.002 - uploadDeviceLog - Invalid CallerID' do
    caller_id2 = 'invalid'

    before :all do
      res = DeviceLogUpload.upload_device_log(caller_id2, filename, slot, device_serial, local_time, log_data)
    end

    it "Verify 'Error while checking caller id' error responses" do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC01.003 - uploadDeviceLog - Invalid Request' do

    before :all do
      res = DeviceLogUpload.upload_device_log(caller_id, '', '', '', '', '')
    end

    it "Verify 'Unable to execute the call: device ts is missing.' error responses" do
      expect(res).to eq('Unable to execute the call: device ts is missing.')
    end
  end
end
