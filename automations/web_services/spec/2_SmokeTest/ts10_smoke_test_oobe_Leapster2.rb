require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow Leapter 2 device works correctly
=end

describe "TS10 - OOBE Smoke Test - Leapster2 - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'L2Kid'
  platform = 'leapster2'
  device_name = 'L2'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform)
end
