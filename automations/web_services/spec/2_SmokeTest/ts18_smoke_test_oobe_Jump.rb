require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow Jump device works correctly
=end

describe "TS18 - OOBE Smoke Test - Jump - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'JumpKid'
  platform = 'leapband'
  device_name = 'JUMP'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform)
end
