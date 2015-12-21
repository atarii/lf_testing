class EmailRollup < ActiveRecord::Base
  include PublicActivity::Common

  def update_email_rollups(id, enabled, time_amount, start_time, emails, user_id)
    start_time = start_time.blank? ? Time.now.utc : Rufus::Scheduler.parse(start_time).utc
    from_time = Time.now.utc
    email_rollup = EmailRollup.update(id, repeat_min: time_amount, start_time: start_time, from_time: from_time, emails_list: emails, status: enabled, user_id: user_id)
    email_rollup.create_activity key: 'email_rollup.update', owner: User.current_user
    active_email_rollups
  end

  def active_email_rollups
    # Distributed Processing: Only TC-QA server can run Email Rollup
    return if !Rails.application.config.server_role.blank?
    Rails.logger.info "Active rollup email scheduler - CurrentTime: #{Time.now.in_time_zone}"
    dashboard = Dashboard.new
    dashboard.domain = "//#{Rails.application.config.server_ip}:#{Rails.application.config.server_port}"
    root_url = Rails.application.config.root_url

    $email_rollup.jobs.each(&:unschedule)
    active_rollups = EmailRollup.where(status: 1)
    active_rollups.each do |f|
      is_schedule_rollup = f.name == 'Schedules'
      EmailRollup.update(f.id, from_time: Time.now.utc)
      $email_rollup.every "#{f.repeat_min}m", first_at: calculate_next_run(f.start_time, f.repeat_min) do
        begin
          summary = dashboard.testrun_summary EmailRollup.find(f.id).from_time.utc, is_schedule_rollup, root_url
          UserMailer.email_rollup(f.emails_list, summary, f.repeat_min, f.name.capitalize).deliver_now
          EmailRollup.update(f.id, from_time: Time.now.utc)
        rescue => e
          Rails.logger.error e
        end
      end
    end
    $email_rollup.join
  end

  def calculate_next_run(start_time, repeat_min)
    return start_time if !(repeat_min.is_a? Integer)
    current_time = Time.now.in_time_zone
    repeat_time = repeat_min * 60
    start_time += repeat_time.to_i while current_time > start_time
    start_time
  end
end
