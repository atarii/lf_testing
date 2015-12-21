require File.expand_path('../../spec_helper', __FILE__)

=begin
Smoke test: Verify OOBE flow Tag device works correctly
=end

describe "TS13 - OOBE Smoke Test - TAG - #{Misc::CONST_ENV}" do
  # Device info variable
  e_child_name = 'TagKid'
  platform = 'tag'
  device_name = 'TAG'

  # run test
  web_services_smoke_test(e_child_name, device_name, platform)
end
