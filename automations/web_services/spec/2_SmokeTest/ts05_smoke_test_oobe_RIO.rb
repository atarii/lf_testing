require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow LeapPad Ultra device works correctly
=end

describe "TS05 - OOBE Smoke Test - RIO - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'RIOKid'
  platform = 'leappad3'
  device_name = 'RIO'
  package_id = '50038-97914' # Jewel Train 2

  # run test
  web_services_smoke_test(e_child_name, device_name, platform, package_id)
end
