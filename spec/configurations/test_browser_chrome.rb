require 'configurations/test_browser_helper'

=begin
Test Central Configuration: Browser testing - Chrome
=end

TestDriverManager.run_with(:chrome)
test_browser 'Chrome'
