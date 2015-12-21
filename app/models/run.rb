require 'find'
require 'zip'
require 'open3'

class Run < ActiveRecord::Base
  include PublicActivity::Common
  include ViewRun
  serialize :data, ApplicationHelper::JSONWithIndifferentAccess
  belongs_to :users

  def self.status_text(total, passed, failed, uncertain)
    Rails.logger.debug "status_text >>> t#{total} p#{passed} f#{failed} u#{uncertain}"
    return 'N/A' if total == 0
    return 'Failed' if failed > 0
    return 'N/A' if uncertain > 0 || (!passed.nil? && passed != total)
    return 'Running' if passed.nil?
    'Passed'
  end

  def name_lvl1
    view_title_and_url[:parts][0]
  end

  def name_lvl2
    view_title_and_url[:parts][1]
  end

  def name_lv1_ds
    view_title_and_url[:part_w_ds]
  end

  def view_title_and_url(root_url = '')
    device_store = {}
    unless data[:device_store].nil?
      device_store[:device_store] = 'Devices[%s]'
      device_store[:payment_type] = 'Payment Types[%s]'
    end

    email = data[:email] || data[:schedule_info][:user_email]
    sub_parts_1 = {
      date: self[:date].in_time_zone.strftime('%Y-%m-%d'),
      email: email.split('@')[0],
      env: data[:env],
      locale: data[:locale],
      release_date: data[:release_date],
      inmon_version: data[:inmon_version]
    }.merge!(device_store).reject { |_k, v| v.blank? }
    part1 = sub_parts_1.values.join('_').gsub(/_{2,}/, '_').chomp '_'

    part2 = [
      data[:start_datetime].to_datetime.strftime('%H%M%S%L'),
      data[:suite_name].gsub(/[^0-9A-Za-z]/, '_').squeeze('_')
    ].join('_').gsub(/_{2,}/, '_').chomp '_'

    path = "#{data[:silo]}/view/#{part1}/#{part2}"
    root_url += '/'
    sta_cls = status_and_class

    ds_temp_path = sub_parts_1.merge(
      device_store: data[:device_store],
      payment_type: data[:payment_type]
    ) { |_k, _v1, v2| v2 }
    ds_temp_path.reject! { |_k, v| v.blank? }

    part_w_ds = ds_temp_path.values.join('_').gsub(/_{2,}/, '_').chomp '_'
    details = ds_temp_path.map { |_key, val| "#{val}" }[2..-1].join(', ')
    title = "#{data[:suite_name]} (#{details})"

    ds_part1 = ds_temp_path.values.join('_').gsub(/_{2,}/, '_').chomp '_'
    ds_url = root_url + "#{data[:silo]}/view/#{ds_part1}/#{part2}"

    {
      title: title,
      url: root_url + path,
      ds_url: ds_url,
      parts: [part1, part2],
      silo: data[:silo],
      status: sta_cls[:status].upcase,
      css_class: sta_cls[:css_class],
      part_w_ds: part_w_ds
    }
  end

  def duration
    if self[:status] == 'queued' || self[:status] == 'scheduled'
      ''
    elsif data['end_datetime'].nil? || data['start_datetime'].nil?
      'Calculating'
    else
      ((data['end_datetime'].to_datetime - data['start_datetime'].to_datetime) * 24 * 60).to_f.round(2).to_s + ' minutes'
    end
  end

  def status_and_class
    if self[:status] == 'done' || self[:status] == 'running'
      status = Run.status_text data['total_cases'], data['total_passed'], data['total_failed'], data['total_uncertain']
      status = 'Pending' if percent_pass != 0 && percent_pass != 1
    else
      status = self[:status]
    end
    css_class = status && status.parameterize.underscore || ''

    { status: status, css_class: css_class }
  end

  def suite_name
    (data['suite_name'].nil?) ? data['suite_path'] : data['suite_name'] # Handle for old data
  end

  def to_attach_file(root_url = '', type = 'zip') # Attachments for email in 'zip' type
    run_link = view_title_and_url root_url
    download_path = create_zip_file silo_name: run_link[:silo], view_path: run_link[:parts][0] + '/' + run_link[:parts][1]

    return Dir.glob(download_path + '/*') if type == 'html'
    zip_folder(download_path)
  end

  def create_zip_file(info)
    silo_name = info[:silo_name]
    arr_view_path = (info[:view_path].nil?) ? '' : info[:view_path].split('/')
    level = (arr_view_path.length == 0) ? 1 : arr_view_path.length + 1
    root_url = Rails.application.config.root_url

    if level == 2
      temp_runs = Run.by_group_name silo_name, info[:view_path]
      return '' unless temp_runs

      runs = temp_runs[:runs]
      return '' unless runs

      download_path = Dir.mktmpdir("#{info[:view_path][0..39]}_".parameterize.underscore)

      runs.each do |run|
        next if run[:status] == 'queued' || run[:status] == 'scheduled'

        sub_folder = File.join(download_path, run.name_lvl2)
        FileUtils.mkdir_p(sub_folder)
        cases = run.data['cases']

        # Generate summary html file
        html_details = run.to_html Rails.application.config.root_url
        run.generate_report_file(sub_folder, nil, run.data['email'], run.summary_html(root_url), html_details)

        return '' unless cases.each_with_index do |c, index|
          run.generate_report_file(sub_folder, run.id, c['file_name'], c['name'], index + 1)
        end
      end
    else
      group_results = Run.by_group_name silo_name, arr_view_path[0]
      return '' unless group_results

      runs = group_results[:runs]
      return '' unless runs

      run = runs.detect { |x| x.name_lvl2 == info[:view_path].gsub(arr_view_path[0] + '/', '') }
      return '' unless run
      cases = run.data['cases']

      # Generate summary html file
      download_path = Dir.mktmpdir("#{arr_view_path[1][0..39]}_".parameterize.underscore)
      html_details = run.to_html Rails.application.config.root_url
      run.generate_report_file(download_path, nil, run.data['email'], run.summary_html(root_url), html_details)

      return '' unless cases.each_with_index do |c, index|
        run.generate_report_file(download_path, run.id, c['file_name'], c['name'], index + 1)
      end
    end

    download_path
  end

  def zip_folder(folder)
    zipfile_name = "#{folder}.zip"

    Zip.setup do |c|
      c.continue_on_exists_proc = true # overwrite existing zip file
      c.unicode_names = true # for zip file name is unicode
    end

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      Find.find(folder) do |dir_or_file|
        zipfile.add(dir_or_file.sub(folder + '/', ''), dir_or_file) unless File.directory?(dir_or_file)
      end
    end

    zipfile_name
  end

  # Warning: JSON run.data is not loaded in Run objects. Use run.reload to load run.data.
  def self.by_silo_group(silo, start_date = nil, end_date = nil, email = nil, level = nil, view_path = nil)
    filter = []
    filter << "(json_extract(data, '$.silo')) = '\"#{silo}\"' COLLATE utf8_general_ci"
    filter << "date >= \"#{start_date}\"" unless start_date.nil?
    filter << "date <= \"#{end_date}\"" unless end_date.nil?

    unless email.nil?
      user_ids = User.where("email like \"#{email}@%\"").pluck :id
      filter << "user_id in (#{user_ids.join(',')})" unless user_ids.blank?
    end

    columns = 'id, user_id, date, percent_pass, case_count, note, created_at, updated_at, status'
    step_paths = Array.new(30) { |i| "'$.cases[#{i}].steps'" }
    columns += ",json_remove(data, #{step_paths.join ','}) as data"

    runs = Run.select(columns).where(filter.join ' and ')

    f_groups = {}
    if level == 1 && !view_path.to_s.include?('Devices[')
      runs.each do |run|
        run[:data][:email] = User.get_user_info_by_id(run[:user_id])[:email]
        name = run.name_lv1_ds

        if f_groups[name].nil?
          f_groups[name] = { runs: [run] }
        else
          f_groups[name][:runs].push run
        end
      end
    else
      groups = {}
      runs.each do |run|
        run[:data][:email] = User.get_user_info_by_id(run[:user_id])[:email]
        name = run.name_lvl1

        if groups[name].nil?
          groups[name] = { runs: [run] }
          groups[name][:device_store] = []
          groups[name][:payment_type] = []
        else
          unless run[:data][:device_store].nil?
            groups[name][:device_store] = groups[name][:device_store] | [run[:data][:device_store]]
            groups[name][:payment_type] = groups[name][:payment_type] | [run[:data][:payment_type]]
          end

          groups[name][:runs].push run
        end
      end

      groups.each do |k, v|
        if v[:device_store].empty?
          f_groups[k] = { runs: v[:runs] }
        else
          new_key = format(k, v[:device_store].join(', '), v[:payment_type].join(', '))
          f_groups[new_key] = { runs: v[:runs] }
        end
      end
    end

    f_groups
  end

  def self.by_group_name(silo, group_name)
    parts = group_name.split('_')
    start_date = parts[0].to_time.utc if parts.size > 0
    end_date = start_date + 1.days if parts.size > 0
    email = parts[1] if parts.size > 1

    groups = by_silo_group silo, start_date, end_date, email, 1, group_name
    groups_sch = Schedule.by_silo_group silo, start_date, end_date, email
    groups.deep_merge!(groups_sch) { |_key, v1, v2| v1 + v2 }

    group = groups[group_name]
    return if group.blank?

    group[:runs].each { |run| run.reload if run[:status] == 'done' || run[:status] == 'running' }
    { group_name: group_name, runs: group[:runs].sort_by { |run| run[:updated_at] }.reverse } unless group.blank?
  end

  def get_rspec_it(step)
    case step['status']
    when 'passed'
      generate_example_passed(step['name'], step['duration'])
    when 'failed'
      generate_example_failed(step['name'], step['duration'], step['exception']) + make_example_group_header_red
    when 'pending'
      generate_example_pending(step['name'])
    end
  end

  def self.runs_css_class(runs)
    arr_status = []
    runs.each do |run|
      if run[:status] == 'done' || run[:status] == 'running'
        counts = [run.data[:total_cases], run.data[:total_passed], run.data[:total_failed], run.data[:total_uncertain]]
        arr_status.push(Run.status_text counts[0], counts[1], counts[2], counts[3])
      else
        arr_status.push run[:status]
      end
    end

    case
    when arr_status.include?('Failed')
      status_class = 'class="failed"'
    when arr_status.include?('N/A')
      status_class = 'class="n_a"'
    when arr_status.include?('Running')
      status_class = 'class="running"'
    when arr_status.include?('Passed')
      status_class = 'class="passed"'
    when arr_status.include?('queued')
      status_class = 'class="queued"'
    when arr_status.include?('scheduled')
      status_class = 'class="scheduled"'
    else
      status_class = 'class="n_a"'
    end

    status_class.html_safe
  end

  def self.save_json_data(data)
    return if data['run_id'].blank?

    run = Run.where(id: data['run_id']).first
    return if run.blank?

    run.update(data: data)
  end

  def exec_testcentral_testcase
    Thread.new do
      begin
        sleep(rand(0.001..0.999))
        $count_progress += 1

        run_queue_data = data.clone
        data = Silo.prepare_run_data self, run_queue_data

        if data[:silo] == 'ATG'
          data = Atg.prepare_run_data data, run_queue_data

          # Create new template file to contain data test
          temp_file = Tempfile.new([File.basename(ENV['ATG_XMLDATA_PATH']), File.extname(ENV['ATG_XMLDATA_PATH'])])
          File.open(temp_file, 'wb') { |f| f.write(File.read ENV['ATG_XMLDATA_PATH']) }
          data[:data_file] = temp_file.path

          data[:reset_data_xml] = proc do
            Rails.logger.info "reset_data_xml >>> account = #{data[:exist_acc]}"
            Atg.update_data_info_to_xml(data[:data_file], data)
          end
        elsif data[:silo] == 'WS'
          data[:inmon_version] = WebService.get_inmon_version data[:env]
          data[:spec_folder] = ENV['WEBSERVICE_LOADPATH'] + '/spec'

          # Create new template file to contain data test
          temp_file = Tempfile.new([File.basename(ENV['WEBSERVICE_XMLDATA_PATH']), File.extname(ENV['WEBSERVICE_XMLDATA_PATH'])])
          File.open(temp_file, 'wb') { |f| f.write(File.read ENV['WEBSERVICE_XMLDATA_PATH']) }
          data[:data_file] = temp_file.path

          data[:reset_data_xml] = proc do
            WebService.update_data_info_to_xml(data[:data_file], data)
          end
        elsif data[:silo] == 'TC'
          data[:spec_folder] = ENV['TC_LOADPATH']
        end

        run data
        update(status: 'done')

        # Add run result to Email Queue
        EmailQueue.create(run_id: id, email_list: run_queue_data[:emaillist])
      ensure
        begin
          ActiveRecord::Base.connection.close if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
        rescue => e
          Rails.logger.info "Exception closing ActiveRecord db connection: #{ModelCommon.full_exception_error e}"
        end
        $count_progress -= 1
      end
    end
  end

  def exec_outpost_testcase
    Thread.new do
      begin
        sleep(rand(0.001..0.999))
        run_queue_data = data.clone
        data = {}

        user_info = User.get_user_info_by_id(user_id)
        data[:email] = user_info[:email]
        data[:username] = user_info[:full_name]
        data[:current_time] = data[:start_datetime] = Time.zone.now
        data[:silo] = run_queue_data[:silo]
        data[:suite_path] = run_queue_data[:testsuite]
        data[:suite_name] = run_queue_data[:testsuite].titleize
        data[:running_tcs] = run_queue_data[:testcases]
        data[:note] = run_queue_data[:description].to_s
        data[:web_driver] = run_queue_data[:web_driver].to_s
        data[:env] = run_queue_data[:env].to_s
        data[:locale] = run_queue_data[:locale].to_s
        data[:release_date] = run_queue_data[:release_date].to_s
        data[:data_driven_csv] = run_queue_data[:data_driven_csv]
        data[:device_store] = ''
        data[:payment_type] = ''
        data[:inmon_version] = ''
        data[:language] = ''
        data[:schedule_info] = run_queue_data[:schedule_info]
        data[:station_name] = location
        data[:email_list] = run_queue_data[:emaillist]

        run data
      ensure
        begin
          ActiveRecord::Base.connection.close if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
        rescue => e
          Rails.logger.info "Exception closing ActiveRecord db connection: #{ModelCommon.full_exception_error e}"
        end
      end
    end
  end

  def to_queued_html_row
    suite = Suite.find_by(id: data[:testsuite])
    suite_name = suite.blank? ? '' : suite.name

    user_info = User.get_user_info_by_id user_id
    email_domain = user_info.blank? ? '' : user_info[:email].split('@')[0]

    link_parts = [
      data[:silo],
      email_domain,
      suite_name,
      data[:env].to_s.upcase,
      data[:locale].to_s,
      data[:release_date].to_s
    ].reject(&:empty?).join('_')

    description = self[:description].blank? ? '' : "<br>Description: #{self[:description]}"
    loc = Station.station_name(location)
    loc_name = loc.blank? ? location : loc

    <<-INTERPOLATED_HEREDOC.strip_heredoc
      <tr>
        <td>Queued</td>
        <td>Station: #{loc_name}</td>
        <td>User: #{user_info[:full_name]}<br>#{link_parts}#{description}</td>
      </tr>
    INTERPOLATED_HEREDOC
  end

  def run(data)
    Rails.logger.debug 'Starting test run'

    run_json = {
      user: data[:username],
      email: data[:email],
      silo: data[:silo],
      suite_path: data[:suite_path],
      suite_name: data[:suite_name],
      env: data[:env],
      locale: data[:locale],
      web_driver: data[:web_driver],
      release_date: data[:release_date],
      data_driven_csv: data[:data_driven_csv],
      device_store: data[:device_store],
      payment_type: data[:payment_type],
      inmon_version: data[:inmon_version],
      start_datetime: data[:start_datetime],
      end_datetime: nil,
      total_cases: data[:running_tcs].size,
      total_passed: 0,
      total_failed: 0,
      total_uncertain: 0,
      schedule_info: data[:schedule_info],
      config: nil,
      tc_version: Version.tc_git_version,
      station_name: data[:station_name],
      note: data[:note],
      cases: []
    }
    Rails.logger.debug "run_json >>> #{JSON.pretty_generate run_json}"

    update(
      date: data[:current_time],
      note: data[:note],
      data: run_json,
      created_at: data[:start_datetime]
    )

    outpost_info = Outpost.outpost_info(name: data[:station_name])
    if outpost_info.blank?
      run_test_central data, run_json
    else
      run_outpost data, outpost_info
    end

    Rails.logger.debug 'Finished test run'
    create_activity key: 'run.create', owner: User.current_user
  end

  def run_test_central(data, run_json)
    scheduler = Rufus::Scheduler.new

    data[:running_tcs].each do |tc|
      begin
        `ipconfig /flushdns` unless RbConfig::CONFIG['host_os'].include?('darwin') || RbConfig::CONFIG['host_os'].include?('linux')

        json_temp_file = Tempfile.new(["#{tc.split('/').last.gsub('.rb', '')}", '.json'])
        json_temp_path = json_temp_file.path
        Rails.logger.debug "json_temp_file.path >>> #{json_temp_path}"

        rspec_file = "#{data[:spec_folder]}/#{tc}"
        output_json_option = "-f LFJsonFormatter -r ./#{ENV['RSPEC_REPORT_LIB']}/lf_json_formatter -o #{json_temp_path}"

        if data[:data_file].nil?
          command = "rspec --require rspec/legacy_formatters #{rspec_file} #{output_json_option}"
        else
          command = "rspec --require rspec/legacy_formatters #{rspec_file} #{output_json_option} -I #{data[:data_file]}"
        end

        test_case_info = Case.get_case(data[:silo], tc)
        case_json = {
          name: test_case_info.name,
          description: test_case_info.description,
          file_name: "#{tc.split('/')[-1]}",
          comment: Case.get_case_comment(rspec_file),
          total_steps: 1,
          total_failed: 0,
          total_uncertain: 0,
          steps: [{ name: '', steps: [] }]
        }

        array_index = run_json[:cases].count
        run_json[:cases][array_index] = case_json
        self[:data] = run_json
        save

        begin
          Rails.logger.info "running test case >>> #{command}"

          if data[:reset_data_xml]
            Rails.logger.debug 'calling reset_data_xml'
            run_json[:config] = data[:reset_data_xml].call
          end

          # update database after each step
          Thread.new do
            modified_time = File.mtime(json_temp_path)

            scheduler.every '5s' do
              begin
                last_modified_time = File.mtime(json_temp_path)

                # Only update run data when JSON temp file is changed
                unless modified_time == last_modified_time
                  case_json.merge!(json_report_data json_temp_path)
                  case_json[:name] = test_case_info.name
                  case_json[:description] = test_case_info.description
                  run_json[:cases][array_index] = case_json
                  self[:data] = run_json
                  save

                  modified_time = last_modified_time
                end
              ensure
                begin
                  ActiveRecord::Base.connection.close if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
                rescue => e
                  Rails.logger.info "Error while closing ActiveRecord db connection: #{ModelCommon.full_exception_error e}"
                end
              end
            end
          end

          stdout_and_stderr_str, status = Open3.capture2e(command)
          fail "Status = #{status}\n" + stdout_and_stderr_str if File.zero? json_temp_file

          # Stop scheduled job
          scheduler.jobs.each(&:unschedule)

          # Merge data from Json report to case json
          case_json.merge!(json_report_data json_temp_path)
          case_json[:name] = test_case_info.name
          case_json[:description] = test_case_info.description
        rescue => e
          full_error = ModelCommon.full_exception_error e
          case_json[:error] = full_error
          case_json[:total_uncertain] = 1
          case_json[:total_failed] = 0
          case_json[:total_steps] = 1
          Rails.logger.error "Error while running test cases: #{full_error}"
        end

        run_json[:cases][array_index] = case_json

        if case_json[:total_failed] > 0
          run_json[:total_failed] += 1
        elsif case_json[:total_uncertain] == 0
          run_json[:total_passed] += 1
        else
          run_json[:total_uncertain] += 1
        end

        self[:data] = run_json
        save

        total_steps_passed = case_json[:total_steps] - (case_json[:total_failed] + case_json[:total_uncertain])
        Rails.logger.info "Ran test case >>> #{tc}, total/pass/fail/uncertain #{case_json[:total_steps]}/#{total_steps_passed}/#{case_json[:total_failed]}/#{case_json[:total_uncertain]}"
      rescue => e
        Rails.logger.error "Error while running test cases: #{ModelCommon.full_exception_error e}"
      end
    end

    run_json[:end_datetime] = Time.now
    self[:case_count] = run_json[:total_cases]
    self[:percent_pass] = run_json[:total_passed] / run_json[:total_cases]
    self[:data] = run_json
    save
  ensure
    begin
      scheduler.stop
      ActiveRecord::Base.connection.close if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
    rescue => e
      Rails.logger.info "Exception closing ActiveRecord db connection: #{ModelCommon.full_exception_error e}"
    end
  end

  def json_report_data(json_file_path)
    raw_json = File.read json_file_path
    return {} if raw_json.empty?
    JSON.parse(raw_json, symbolize_names: true)
  end

  def run_outpost(data, outpost_info)
    run_data = {
      run_id: id,
      name: outpost_info[:name],
      silo: data[:silo],
      testsuite: data[:suite_path],
      testcases: data[:running_tcs],
      email_list: data[:email_list],
      config: data[:data_driven_csv]
    }
    Outpost.execute(outpost_info[:exec_url], run_data)
  end

  def self.run_queue_by_schedule_id(schedule_id)
    Run.where("status = 'queued' and (json_extract(data, '$.schedule_info.id')) = '?'", schedule_id)
  end

  def self.add_to_run_queue(data)
    run = Run.new data
    if run.save
      run.create_activity key: 'run.create', owner: User.current_user
    else
      Rails.logger.info 'Error while adding queue to Run'
    end
  end

  def self.initialize_data(params)
    data_driven_csv = ModelCommon.upload_and_get_data_driven_csv(params[:data_driven_csv])

    {
      email: User.current_user.email,
      silo: params[:silo],
      web_driver: params[:webdriver].to_s,
      tc_version: Version.tc_git_version,
      env: params[:env].to_s,
      locale: params[:locale],
      testsuite: params[:testsuite],
      suite_name: Suite.suite_name(params[:testsuite]),
      release_date: params[:release_date].to_s,
      data_driven_csv: data_driven_csv,
      device_store: params[:device_store],
      payment_type: params[:payment_type],
      emaillist: params[:user_email],
      description: params[:note].to_s,
      start_datetime: Time.zone.now,
      total_passed: 0,
      total_failed: 0,
      total_uncertain: 0
    }
  end

  def self.add_case_to_suite(test_runs)
    test_runs ||= []
    cases = []

    unless test_runs.blank?
      test_runs.each do |tc_id|
        cases.push(
          name: Case.info(tc_id)[:name],
          total_steps: 1,
          total_failed: 0,
          total_uncertain: 0,
          steps: [{ name: '', steps: [] }]
        )
      end
    end

    { testcases: test_runs.join(','), total_cases: test_runs.size, cases: cases }
  end

  def self.to_silo(silo, date, view_path = nil)
    test_group = []
    if date
      start_date = DateTime.strptime(date, '%Y-%m')
    else
      start_date = Date.today.at_beginning_of_month
    end

    end_date = start_date + 1.months

    current_date = start_date.strftime '%Y-%m'
    previous_date = (start_date - 1.months).strftime '%Y-%m'
    next_date = (start_date + 1.months).strftime '%Y-%m'

    groups = Run.by_silo_group silo, start_date, end_date, nil, view_path
    groups_sch = Schedule.by_silo_group silo, start_date, end_date
    groups.deep_merge!(groups_sch) { |_key, v1, v2| v1 + v2 }

    groups.values.each do |value|
      value[:status] = Run.runs_css_class value[:runs]
    end

    groups = groups.sort.reverse

    groups.each do |group|
      gb_status = group[1][:runs].group_by { |run| run[:status] }
      gb_status.each { |k, v| gb_status[k] = v.size }
      gb_status = gb_status.map { |k, v| "#{v} #{'item'.pluralize v} #{k}" }.join(', ')

      test_group << { name: "#{group[0]} (#{gb_status})", path: group[0], silo: silo, css_class: group[1][:status] }
    end

    { test_group: test_group, current_date: current_date, previous_date: previous_date, next_date: next_date }
  end

  def self.to_runs(info)
    group_runs = Run.by_group_name info[:silo_name], info[:view_path]
    return unless group_runs

    runs = group_runs[:runs]
    return unless runs

    test_run = []
    if runs[0][:data][:device_store].nil?
      runs.each do |run|
        test_run << { path: "#{info[:view_path]}/#{run.name_lvl2}", run: run, silo: info[:silo_name] }
      end
    else
      group_name = group_runs[:group_name]
      ds_groups = runs.group_by { |run| run[:data][:schedule_info][:id] unless run[:data][:schedule_info].nil? }
    end

    { test_runs: test_run, group_name: group_name, ds_groups: ds_groups }
  end

  def self.to_cases(info)
    view_path_parts = info[:view_path_parts]
    group_runs = Run.by_group_name info[:silo_name], view_path_parts[0]
    return {} unless group_runs

    runs = group_runs[:runs]
    return {} unless runs

    name_lvl2 = view_path_parts[1..(view_path_parts.length - 1)].join('/')
    run = runs.find { |x| x.name_lvl2 == name_lvl2 }
    return unless run

    suite_name = run.data['suite_name']
    running_summary = run.summary_html
    cases = run.data['cases']
    return {} if cases.blank?

    test_script = []
    cases.each do |c|
      test_script.push(run.case_row_data(c).merge! duration: c['duration'], device_store: run[:data][:device_store])
    end

    { name_lvl2: name_lvl2, suite_name: suite_name, running_summary: running_summary, test_script: test_script }
  end

  def self.status_json
    current_time = Time.now.in_time_zone

    begin
      status_hash = {
        queued: Run.where(status: 'queued').length,
        today: Run.where('status != \'queued\' AND created_at >= ? AND created_at <= ? ', current_time.beginning_of_day.utc, current_time.end_of_day.utc).length,
        scheduled: Schedule.where(status: 1).length,
        running: $count_progress,
        outpost: Run.where('status = "running" and location in (?)', Outpost.all.pluck(:name)).length
      }
    ensure
      begin
        ActiveRecord::Base.connection.close if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
      rescue => e
        Rails.logger.info "Exception closing ActiveRecord db connection: #{ModelCommon.full_exception_error e}"
      end
    end

    status_hash.to_json
  end
end
