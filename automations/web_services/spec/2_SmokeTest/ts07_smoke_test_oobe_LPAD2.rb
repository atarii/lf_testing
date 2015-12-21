require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow LeapPad 2 device works correctly
=end

describe "TS07 - OOBE Smoke Test - LPAD2 - #{Misc::CONST_ENV}" do
  # Device info variable
  platform = 'leappad2'
  e_child_name = 'LPAD2Kid'
  device_name = 'LPAD2'
  package_id = '59351-96914'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform, package_id)
end
