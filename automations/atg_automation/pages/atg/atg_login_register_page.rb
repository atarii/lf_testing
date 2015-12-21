require 'pages/atg/atg_my_profile_page'
require 'pages/atg/atg_common_page'

class RegisterSection < SitePrism::Section
  element :firstname_input, '#atg_newAccountFirstName'
  element :lastname_input, '#atg_newAccountLastName'
  element :email_input, '#atg_newAccountEmail'
  element :password_input, '#atg_newAccountPassword'
  element :confirm_pass_input, '#atg_newAccountConfirmPassword'
  element :postal_input, '#atg_newAccountPostalCode'
  element :agree_finish_btn, '#loginformAgreeButton'
  element :country_cbo, '#atg_newAccountLocale'
  element :create_new_account_btn, :xpath, "*//button[contains(text(),'Create New Account')]"
end

class LoginSection < SitePrism::Section
  element :email_input, '#atg_loginEmail'
  element :password_input, '#atg_loginPassword'
  element :login_btn, :xpath, ".//*[@id='loginForm']//button[contains(text(),'Log In')]"
  element :error_login_msg, :xpath, "//p[contains(text(),'The email address or password you entered is incorrect. Please try again.')]"
end

class ResetPasswordBox < SitePrism::Section
  element :reset_email_txt, '#resetEmail'
  element :reset_password_btn, :xpath, ".//button[contains(text(), 'Reset')]"
end

class SentPasswordOverlay < SitePrism::Section
  element :check_your_email_txt, '#atg_sentPasswordOverlay>h3'
  element :close_button, '.btn.btn-yellow.pull-right'
end

class LoginRegisterATG < CommonATG
  set_url URL::ATG_CONST

  section :register_form, RegisterSection, '#register'
  section :login_form, LoginSection, '#login'
  section :reset_password_box, ResetPasswordBox, '#atg_forgotPasswordOverlay'
  section :sent_password_overlay, SentPasswordOverlay, '.account > #atg_sentPasswordOverlay'

  element :form_title_txt, :xpath, "//div//h1[contains(text(),'Log In / Register')]"
  element :error_register_msg, '.help-block.error>p'
  element :create_account_h2, '#register>h2'
  element :log_in_h2, '#login>h2'
  element :forgot_password_lnk, '#login #loginForm .atg-forgot-password-link'

  def login(email, password)
    login_form.email_input.set email
    login_form.password_input.set password
    login_form.login_btn.click
    wait_for_ajax
    MyProfileATG.new
  end

  def register(firstname, lastname, email, password, confirm_pass, zip_code = nil, locale = nil)
    wait_for_ajax
    register_form.create_new_account_btn.click
    register_form.create_new_account_btn.click unless register_form.has_firstname_input?(wait: 5)

    register_form.firstname_input.set firstname
    register_form.lastname_input.set lastname
    register_form.email_input.set email
    register_form.password_input.set password
    register_form.confirm_pass_input.set confirm_pass
    register_form.postal_input.set zip_code unless zip_code.nil?

    unless locale.nil?
      page.execute_script("$('#atg_newAccountLocale').css('display','block')")
      register_form.country_cbo.find("option[value='#{locale}']").select_option
    end

    # 2. Submit the information above
    register_form.agree_finish_btn.click

    # Record to atg_tracking
    unless has_error_register_msg?(wait: TimeOut::WAIT_MID_CONST)
      Connection.my_sql_connection("INSERT INTO atg_tracking(firstname, lastname, email, country, created_at, updated_at) VALUES (\'#{firstname}\',\'#{lastname}\',\'#{email}\',\'#{locale}\',\'#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\', \'#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\');")
      return MyProfileATG.new
    end

    'Error while creating new account. Please re-check!'
  end

  def register_error_message
    error_register_msg.text.strip
  end

  def login_error_message
    login_form.error_login_msg.text.strip
  end

  def reset_password(email)
    forgot_password_lnk.click
    reset_password_box.reset_email_txt.set email
    reset_password_box.reset_password_btn.click
  end

  def sent_password_overlay_display?(close = true)
    is_displayed = sent_password_overlay.has_check_your_email_txt?(wait: TimeOut::WAIT_MID_CONST)
    sent_password_overlay.close_button.click if close
    is_displayed
  end
end
