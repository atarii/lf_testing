require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow Cabo device works correctly
=end

describe "TS22 - OOBE Smoke Test - CABO - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'CABOKid'
  platform = 'leappad3explorer'
  device_name = 'CABO'
  package_id = '50038-97914' # Jewel Train 2

  # run test
  web_services_smoke_test(e_child_name, device_name, platform, package_id)
end
