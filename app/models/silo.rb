class Silo < ActiveRecord::Base
  has_many :suites

  def self.prepare_run_data(run, run_data)
    data = {}
    user_info = User.get_user_info_by_id(run[:user_id])
    data[:email] = user_info[:email]
    data[:username] = user_info[:full_name]
    data[:current_time] = data[:start_datetime] = Time.zone.now

    test_scripts = []
    run_data[:testcases].split(',').each do |id|
      test_scripts << Case.info(id)[:script_path]
    end
    data[:running_tcs] = test_scripts.reject(&:empty?)

    test_suite_id = run_data[:testsuite]
    data[:silo] = Silo.joins(:suites).find_by(suites: { id: test_suite_id }).name
    data[:suite_path] = data[:running_tcs][0][0..data[:running_tcs][0].rindex('/') - 1]
    data[:suite_name] = Suite.suite_name test_suite_id

    data[:note] = run_data[:description].to_s
    data[:web_driver] = run_data[:web_driver].to_s
    data[:env] = run_data[:env].to_s
    data[:locale] = run_data[:locale].to_s
    data[:release_date] = run_data[:release_date].to_s
    data[:data_driven_csv] = run_data[:data_driven_csv]
    data[:device_store] = run_data[:device_store]
    data[:payment_type] = run_data[:payment_type]
    data[:inmon_version] = ''
    data[:language] = ''
    data[:schedule_info] = run_data[:schedule_info]
    data[:station_name] = Station.station_name run[:location]
    data
  end
end
