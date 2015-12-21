class UserMailerPreview < ActionMailer::Preview
  def email_test_run
    run = Run.last
    emails = run.data['email']
    UserMailer.email_test_run emails, run
  end
end