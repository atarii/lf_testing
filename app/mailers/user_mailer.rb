class UserMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: 'sqaautomation@leapfrog.com'

  def email_test_run(emails, run)
    @run = run
    @root_url = Rails.application.config.root_url
    @server_name = Rails.application.config.server_name
    test_title = run.data['schedule_info'].nil? ? "#{run.data['silo']}/#{run.data['suite_path']}" : run.data['schedule_info']['description']
    start_datetime = run.data['start_datetime'].in_time_zone.strftime Rails.application.config.time_format
    status = Run.status_text(run.data['total_cases'], run.data['total_passed'], run.data['total_failed'], run.data['total_uncertain']).upcase
    env = ", Env = #{run.data['env'].upcase}" unless run.data['env'].blank?
    locale = ", Locale = #{run.data['locale'].upcase}" unless run.data['locale'].blank?
    subject = "[SQAAuto] #{status}#{env}, #{test_title}, #{start_datetime}#{locale}, Server = #{@server_name}"
    attach_type = Rails.application.config.action_mailer.smtp_settings[:attachment_type]
    if attach_type == 'zip'
      attachments['Result.zip'] = File.read(@run.to_attach_file(@root_url, 'zip'), mode: 'rb')
    elsif attach_type == 'html'
      @run.to_attach_file(@root_url, 'html').each do |file|
        attachments[File.basename(file)] = File.read(file).html_safe
      end
    end

    mail(to: emails.tr(';', ','), subject: subject)
  end

  def email_rollup(emails, content, time_amount, title = 'Dashboard')
    @time_stamp = "#{Time.now.in_time_zone.strftime Rails.application.config.time_format}"
    @content = content
    @time_amount = time_amount
    @server_name = Rails.application.config.server_name
    @root_url = Rails.application.config.root_url
    @title = title
    subject = "[SQAAuto] #{title} summary: #{@time_stamp}, Server = #{@server_name}"

    mail(to: emails.tr(';', ','), subject: subject)
  end

  def email_active_request(email)
    @email = email
    subject = "[SQAAuto Admin] TC-QA: Active Request - #{@email}"
    @account_edit_url = "#{Rails.application.config.root_url}/users/create?email=#{@email}"

    # Get admin group emails
    admin_emails = User.find_by_sql('select u.email from users u
                      join user_role_maps ur on u.id = ur.user_id
                      where ur.role_id = 1').map(&:email).join(',')

    mail(to: admin_emails, subject: subject) unless admin_emails.blank?
  end

  def email_active_response(email, full_name)
    @email = email
    @user_name = full_name
    subject = "[SQAAuto Admin] TC-QA: Account Activated - #{@email}"
    @sign_in_url = "#{Rails.application.config.root_url}/signin"

    mail(to: @email, subject: subject)
  end
end
