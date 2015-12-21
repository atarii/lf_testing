require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow Leap Reader device works correctly
=end

describe "TS11 - OOBE Smoke Test - LeapReader - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'LRKid'
  platform = 'leapreader'
  device_name = 'LR'
  package_id = '58955-96914' # Birdie's Big Girl Dress

  # run test
  web_services_smoke_test(e_child_name, device_name, platform, package_id)
end
