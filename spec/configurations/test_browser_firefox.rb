require 'configurations/test_browser_helper'

=begin
Test Central Configuration: Browser testing - Firefox
=end

TestDriverManager.run_with(:firefox)
test_browser 'Firefox'
