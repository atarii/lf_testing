require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow My Leap Top device works correctly
=end

describe "TS16 - OOBE Smoke Test - MyLeapTop - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'LeapTopKid'
  platform = 'leaptop'
  device_name = 'LT'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform)
end
