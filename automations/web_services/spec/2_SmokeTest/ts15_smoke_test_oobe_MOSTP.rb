require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow MOSTP device works correctly
=end

describe "TS15 - OOBE Smoke Test - MOSTP - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'MostpKid'
  platform = 'storytimepad'
  device_name = 'MOSTP'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform)
end
