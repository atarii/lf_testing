class Dashboard
  attr_accessor :domain

  # load some recent test runs on dashboard page
  def testrun_summary(from_time = nil, only_schedules = false, root_url = '', current_date_time = nil)
    content = ''

    if from_time.nil?
      if current_date_time.nil?
        runs = Run.order(updated_at: :desc).limit(5)
      else
        current_date_time_start = current_date_time.in_time_zone.beginning_of_day
        current_date_time_end = current_date_time_start.end_of_day
        runs = Run.where('created_at >= ? AND created_at <= ? ', current_date_time_start.utc, current_date_time_end.utc).order(created_at: :desc)
      end
    else
      runs = Run.where('created_at > ?', from_time.in_time_zone.utc).order(created_at: :desc)
    end

    runs.each do |r|
      # Show only run which has been executed by active-schedules
      next if r.data['schedule_info'].nil? && only_schedules
      content << r.to_html_row(root_url)
    end

    content
  end
end
