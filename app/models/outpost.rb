require 'uri'
require 'rest-client'

class Outpost < ActiveRecord::Base
  serialize :available_tests, ApplicationHelper::JSONWithIndifferentAccess

  def self.register(data)
    message = validate_register_data(data)
    return { status: false, message: message } unless message.blank?

    station = Station.where(network_name: data[:name]).first
    return { status: false, message: "Outpost name is duplicated with an existing Station: #{data[:name]}" } unless station.nil?

    outpost = Outpost.where(name: data[:name]).first || Outpost.new(name: data[:name])
    outpost[:silo] = data[:silo]
    outpost[:ip] = data[:ip]
    outpost[:status_url] = data[:status_url]
    outpost[:exec_url] = data[:exec_url]
    outpost.save

    outpost_info = Outpost.where(name: data[:name])
    { status: true, message: outpost_info }
  rescue => e
    { status: false, message: e.message }
  end

  def self.outpost_nav_options
    outposts = Outpost.select(:silo, :name, :status).group(:silo).order('silo asc')
    return [] if outposts.blank?

    outpost_arr = []
    outposts.each do |op|
      outpost = {
        silo: op.silo,
        title: op.silo.titleize,
        name: op.name,
        status: op.status,
        result: false
      }

      all_name_based_on_silo = Outpost.select(:name).where(silo: op.silo)

      all_name_based_on_silo.each do |x|
        if Run.find_by location: x.name
          outpost.merge! result: true
          break
        end
      end

      outpost_arr.push outpost
    end

    outpost_arr
  end

  def self.outpost_run_options
    outposts = Outpost.where('status != \'Error\'').group(:silo).order('silo asc')
    return [] if outposts.blank?

    outposts.map { |outpost| [outpost[:silo], outpost[:silo].titleize] }
  end

  def self.outpost_view_options
    outposts = Outpost.select(:silo, :name).group(:silo).order('silo asc')
    return [] if outposts.blank?

    outpost_arr = []
    outposts.each do |outpost|
      outpost_arr.push [outpost[:silo], outpost[:silo].titleize] if Run.find_by location: outpost.name
    end

    outpost_arr
  end

  def self.outposts(silo)
    Outpost.where("silo = '#{silo}' and status != 'Error'").pluck(:id, :name)
  end

  def self.outpost_info(query)
    Outpost.where(query).select(:id, :name, :silo, :ip, :status, :status_url, :exec_url, :available_tests).first
  end

  def self.group_outpost
    Outpost.select(:id, :silo, :name, :ip, :status).group_by { |o| o[:silo] }.values
  end

  def self.test_suite_list(outpost_id)
    available_tests = Outpost.where(id: outpost_id).pluck(:available_tests).first
    return [] if available_tests.blank?

    available_tests.map { |test| [test[:testsuite].titleize, test[:testsuite]] }
  end

  def self.test_case_list(outpost, test_suite)
    available_tests = Outpost.where(id: outpost).pluck(:available_tests).first
    return [] if available_tests.blank?

    test = available_tests.detect { |t| t[:testsuite] == test_suite }
    return [] if test.nil?

    test_cases = test[:testcases].split(',')
    test_case_list = []
    test_cases.each do |tc|
      tc_name = tc.gsub(/.rb|.feature/, '').titleize
      test_case_list.push([tc, tc_name])
    end

    test_case_list
  end

  def self.sch_outpost_status
    $sch_outpost_status.jobs.each(&:unschedule)
    xml_content = Nokogiri::XML(File.read(RailsAppConfig.new.config_file))
    $outpost_refresh_rate = xml_content.search('//autoSetting/refreshOutpostStatus').text.to_i

    if $outpost_refresh_rate == 0
      Rails.logger.info "Stop refresh Outpost at: #{Time.now}"
      return
    end

    Rails.logger.info "Refresh Outpost status every #{$outpost_refresh_rate}s - CurrentTime: #{Time.now}"
    $sch_outpost_status.every "#{$outpost_refresh_rate}s", first_at: Time.now + $outpost_refresh_rate do
      outpost_status
    end
  end

  def self.outpost_status
    outposts = Outpost.select(:id, :silo, :status_url).where('status_url IS NOT NULL and TRIM(status_url) <> \'\'')
    return if outposts.blank?

    outposts.each do |op|
      begin
        request = RestClient::Request.new(
          method: :get,
          url: op[:status_url],
          verify_ssl: OpenSSL::SSL::VERIFY_NONE
        )

        res = request.execute

        next if res.body.include? '<html><head>'

        body_data = JSON.parse(res.body)
        op[:status] = body_data['data']['outpost_status']
        op[:available_tests] = body_data['data']['available_test']
      rescue
        op[:status] = 'Error'
      end

      op[:checked_at] = Time.zone.now

      # save status and available_tests into outposts
      op.save

      # save json data into runs
      Run.save_json_data(body_data['data']['test_runs']) unless body_data.blank? || body_data['data'].blank? || body_data['data']['test_runs'].blank?
    end
  rescue => e
    Rails.logger.info "Exception Outpost Status scheduler: #{ModelCommon.full_exception_error e}"
  ensure
    begin
      if ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?
        ActiveRecord::Base.connection.close
      end
    rescue => e
      Rails.logger.info "Exception closing ActiveRecord db connection: #{ModelCommon.full_exception_error e}"
    end
  end

  def self.execute(execute_endpoint, run_data)
    request = RestClient::Request.new(
      method: :post,
      url: execute_endpoint,
      headers: { 'Content-Type' => 'application/json' },
      payload: run_data.to_json,
      verify_ssl: OpenSSL::SSL::VERIFY_NONE
    )

    res = request.execute
    return res.body if res.body.include? '<html><head>'
    JSON.parse(res.body)
  end

  def self.upload_file(json_content, user = nil, silo = nil)
    data = JSON.parse json_content

    # Validate all required fields in data JSON
    data_valid = validate_upload_data data
    return { status: false, message: data_valid } unless data_valid == true

    data['tc_version'] = '' if data['tc_version'].blank?

    # Get current User and add 'user' and 'email' fields into run data
    current_user = User.current_user || user
    user_id = current_user.id
    data['user'] = current_user.first_name + ' ' + current_user.last_name
    data['email'] = current_user.email
    data['silo'] = silo if silo

    start_datetime = data['start_datetime']
    case_count = data['total_cases']
    percent_pass = data['total_passed'] / case_count
    note = data['note'] || ''
    run_id = data['run_id'] || ''

    if run_id.blank?
      run = Run.new(
        user_id: user_id,
        date: start_datetime,
        note: note,
        created_at: start_datetime
      )
    else
      run = Run.where(id: run_id).first
      return { status: false, message: "The Run ID: #{run_id} does not exist" } if run.blank?
    end

    run[:percent_pass] = percent_pass
    run[:case_count] = case_count
    run[:data] = data
    run[:status] = 'done'
    run.save

    group_details = run.view_title_and_url
    { status: true, message: "<a href='#{group_details[:url]}'>#{group_details[:url]}</a>" }
  rescue JSON::ParserError
    { status: false, message: 'Invalid JSON format' }
  rescue => e
    { status: false, message: "Error while uploading data (#{e.class.name} <br> #{e.backtrace.join '<br>'})" }
  end

  def self.date_time_valid?(datetime_string)
    DateTime.parse datetime_string
  rescue
    false
  end

  def self.validate_upload_data(data)
    spec = {
      'silo' => :blank,
      'cases' => :blank,
      'suite_path' => :blank,
      'suite_name' => :blank,
      'start_datetime' => :datetime,
      'end_datetime' => :datetime,
      'total_cases' => :integer,
      'total_passed' => :integer,
      'total_failed' => :integer,
      'total_uncertain' => :integer
    }

    return 'No data. Please re-check!' if data.blank?
    errors = []

    spec.each do |key, value|
      case value
      when :blank
        errors << "'#{key}' is missing or empty" if data[key].blank?
      when :datetime
        errors << "'#{key}' has invalid date time format" unless date_time_valid? data[key]
      when :integer
        errors << "'#{key}' is not a valid integer number" unless data[key].is_a? Integer
      end
    end

    return '<br>' + errors.join('<br>') if errors.size > 0
    true
  end

  def self.silo_valid?(silo)
    return '' unless ['ATG', 'WS', 'TC'].include? silo
    'Silo can\'t be duplicated with TestCentral silos (ATG, WS, TC)'
  end

  def self.name_valid?(name)
    return '' if /\A[^`!@#\$%\^&*+_=]+\z/ =~ name
    "Invalid Outpost name: #{name}"
  end

  def self.url_valid?(url)
    return '' if URI.regexp =~ url
    "Invalid status URL: #{url}"
  end

  def self.validate_register_data(data)
    message = ''
    message << name_valid?(data[:name])
    message << silo_valid?(data[:silo])
    message << url_valid?(data[:status_url])
    message << url_valid?(data[:exec_url])
  end
end
