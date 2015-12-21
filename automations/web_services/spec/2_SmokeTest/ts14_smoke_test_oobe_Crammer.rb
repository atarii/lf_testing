require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow Crammer device works correctly
=end

describe "TS14 - OOBE Smoke Test - CRAMMER - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'CrammerKid'
  platform = 'crammer'
  device_name = 'CRA'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform)
end
