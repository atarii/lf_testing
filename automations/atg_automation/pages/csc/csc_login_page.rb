require 'site_prism'
require 'pages/csc/csc_home_page'

class LoginCSC < SitePrism::Page
  set_url URL::CSC_CONST

  # properties
  element :username_input, '#username'
  element :password_input, '#password'
  element :login_btn, '#loginFormSubmit'
  element :username_label, "#loginForm>fieldset>ul>li>label[for='username']"
  element :password_label, "#loginForm>fieldset>ul>li>label[for='password']"

  # methods
  def login(username, password)
    load
    username_input.set username
    password_input.set password
    login_btn.click
    HomeCSC.new
  end
end
