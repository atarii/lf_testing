require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow Leapter GS device works correctly
=end

describe "TS09 - OOBE Smoke Test - LeapterGS - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'GSKid'
  platform = 'explorer2'
  device_name = 'GS'
  package_id = '58922-96914'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform, package_id)
end
