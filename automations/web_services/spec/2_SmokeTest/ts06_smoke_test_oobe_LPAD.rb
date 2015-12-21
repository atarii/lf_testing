require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow LeapPad device works correctly
=end

describe "TS06 - OOBE Smoke Test - LPAD - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'LPADKid'
  platform = 'leappad'
  device_name = 'LPAD'
  package_id = '59351-96914' # Octonauts Learning Game

  # run test
  web_services_smoke_test(e_child_name, device_name, platform, package_id)
end
