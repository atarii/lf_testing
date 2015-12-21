require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow Glasgow device works correctly
=end

describe "TS20 - OOBE Smoke Test - Glasgow - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'GlasgowKid'
  platform = 'leapup'
  device_name = 'LEAPTV'
  package_id = '58979-96914' # Roly Poly World

  # run test
  web_services_smoke_test(e_child_name, device_name, platform, package_id)
end
