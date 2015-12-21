require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow Didj device works correctly
=end

describe "TS12 - OOBE Smoke Test - DIDJ - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'didjKid'
  platform = 'didj'
  device_name = 'DIDJ'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform)
end
