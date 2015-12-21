require 'site_prism'
require 'lib/const'
require 'pages/vindicia/vin_home_page'

class LoginVIN < CommonVIN
  set_url URL::VIN_CONST

  # properties
  element :username_input, '#login-login'
  element :password_input, :xpath, "//input[@name='login-password']"
  element :login_btn, :xpath, "//input[@name='login-submit']"
  element :login_error_msg, :xpath, ".//*[@id='login-form']/h2[contains(text(),'Login Error')]"

  # for health check
  element :login_label, :xpath, "(.//*[@id='login-form']/p[@class='contentH3'])[1]"
  element :password_label, :xpath, "(.//*[@id='login-form']/p[@class='contentH3'])[2]"

  # methods

  def login(username, password)
    load
    username_input.set username
    password_input.set password
    login_btn.click
    HomeVIN.new
  end
end
