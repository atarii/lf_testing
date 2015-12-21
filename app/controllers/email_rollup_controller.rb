class EmailRollupController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    dashboard_rollup_config = EmailRollup.find_by(name: 'Dashboard')
    @configure_dashboard_rollup_email = {
      enabled: dashboard_rollup_config.status == '0' ? 'false' : 'true',
      time_amount: dashboard_rollup_config.repeat_min,
      start_time: dashboard_rollup_config.start_time,
      emails: dashboard_rollup_config.emails_list
    }

    schedule_rollup_config = EmailRollup.find_by(name: 'Schedules')
    @configure_schedules_rollup_email = {
      enabled: schedule_rollup_config.status == '0' ? 'false' : 'true',
      time_amount: schedule_rollup_config.repeat_min,
      start_time: schedule_rollup_config.start_time,
      emails: schedule_rollup_config.emails_list
    }
    format_time = '%I:%M %p'
    dashboard_start_time = @configure_dashboard_rollup_email[:start_time]
    schedules_start_time = @configure_schedules_rollup_email[:start_time]
    @dashboard_start_time = dashboard_start_time.blank? ? nil : dashboard_start_time.in_time_zone.strftime(format_time)
    @schedules_start_time = schedules_start_time.blank? ? nil : schedules_start_time.in_time_zone.strftime(format_time)
  end

  def configure_rollup_email
    Thread.new do
      id = params[:type] == 'dashboard' ? 1 : 2 # dashboard or schedules
      enabled = params[:enabled] == 'true' ? 1 : 0 # 'true' or 'false'
      time_amount = params[:time_amount]
      start_time = params[:start_time]
      emails = params[:emails]
      current_user = User.find_by(email: session[:user_email])
      EmailRollup.new.update_email_rollups(id, enabled, time_amount, start_time, emails, current_user.id)
    end

    render plain: 'true'
  end
end
