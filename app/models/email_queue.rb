class EmailQueue < ActiveRecord::Base
  @@mutex_email = Mutex.new

  def send_email
    @@mutex_email.synchronize do
      begin
        email_queue = EmailQueue.order(:created_at).first
        return unless email_queue

        email_list = email_queue.email_list
        return unless email_list

        run = Run.find_by(id: email_queue.run_id)
        return unless run

        UserMailer.email_test_run(email_list, run).deliver_now
        email_queue.destroy
      rescue => e
        Rails.logger.error "Error while sending Email: #{ModelCommon.full_exception_error e}"
      ensure
        begin
          ActiveRecord::Base.connection.close if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
        rescue => e
          Rails.logger.error "Error while closing DB connection: #{ModelCommon.full_exception_error e}"
        end
      end
    end
  end

  def send_email_queue
    # Distributed Processing: Only TC-QA server can send emails
    return unless Rails.application.config.server_role.blank?
    $sch_send_email.jobs.each(&:unschedule)

    xml_content = Nokogiri::XML(File.read(RailsAppConfig.new.config_file))
    $refresh_rate = xml_content.search('//emailQueueSetting/refreshEmailRate').text.to_i
    Rails.logger.info "Send result emails every #{$refresh_rate}s - CurrentTime: #{Time.now}"

    $sch_send_email.every "#{$refresh_rate}s", first_at: Time.now + $refresh_rate do
      send_email
    end

    $sch_send_email.join
  end

  def self.add_queue(run_id, email_list)
    return if run_id.blank? || email_list.blank?

    EmailQueue.create(run_id: run_id, email_list: email_list, created_at: Time.now.in_time_zone)
  end
end
