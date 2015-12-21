require 'spec_helper'

module Capybara
  class << self
    alias_method :old_reset_sessions!, :reset_sessions!

    def reset_sessions!
    end
  end
end

class TimeOut
  READTIMEOUT_CONST = 260 # for page load
  WAIT_CONTROL_CONST = 45 # for control
end

require File.expand_path('../../../automations/lib/test_driver_manager', __FILE__)

def test_browser(browser)
  include Capybara::DSL

  describe 'Test Central Configuration' do
    email = 'ltrc_vn_automation_test@leapfrog.test'
    password = '123456'
    sign_url = Rails.application.config.root_url + '/signin'

    context "Browser testing - #{browser}" do
      it 'Navigate to Test Central Login/Register page' do
        visit(sign_url)
      end

      it 'Verify "Login" button exist' do
        expect(page.has_css?('input[value="Log In"]')).to eq(true)
      end

      it 'Verify "Sign Up" button exist' do
        expect(page.has_css?('input[value="Sign Up"]')).to eq(true)
      end

      it 'Enter Email/Password in Login form' do
        find('#user_email').set(email)
        find('#user_password').set(password)
      end

      it 'Click on "Login" button' do
        click_button('Log In')
      end

      it 'Verify error message displays' do
        page.should have_css('.alert.alert-error')
      end
    end
  end
end
