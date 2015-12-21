require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow May Pal device works correctly
=end

describe "TS17 - OOBE Smoke Test - MyPals - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'PalsKid'
  platform = 'mypals'
  device_name = 'PALS'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform)
end
