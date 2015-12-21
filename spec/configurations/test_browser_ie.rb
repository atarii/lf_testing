require 'configurations/test_browser_helper'

=begin
Test Central Configuration: Browser testing - IE
=end

TestDriverManager.run_with(:internet_explorer)
test_browser 'IE'
