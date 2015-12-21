require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow LEX device works correctly
=end

describe "TS08 - OOBE Smoke Test - LEX - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'LEXKid'
  platform = 'emerald'
  device_name = 'LEX'
  package_id = '59351-96914'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform, package_id)
end
