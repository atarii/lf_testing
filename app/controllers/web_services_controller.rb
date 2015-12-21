require 'json'

class WebServicesController < ApplicationController
  SELECT_TEST_SUITE = '-- Select child test suite --'
  ALL_TEST_SUITE = 'All test suites'

  def back
    render plain: Suite.test_suite_list('ws')
  end
end
