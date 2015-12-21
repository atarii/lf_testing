require 'render_anywhere'
require 'roadie'

module Run::ViewRun
  include RenderAnywhere

  def summary_html(root_url = '')
    summary = {}
    status = Run.status_text(data['total_cases'], data['total_passed'], data['total_failed'], data['total_uncertain']).upcase
    suite_name = (data['suite_name'].nil?) ? data['suite_path'] : data['suite_name']
    summary['Test suite'] = data['silo'] + '/' + suite_name
    summary['Start time'] = data['start_datetime'].in_time_zone.strftime Rails.application.config.time_format
    summary['Duration'] = duration unless duration.blank?
    summary['Environment'] = data['env'].upcase unless data['env'].blank?
    summary['INMON'] = data['inmon_version'] unless data['inmon_version'].blank?
    summary['Locale'] = data['locale'] unless data['locale'].blank?
    summary['Release Date'] = data['release_date'] unless data['release_date'].blank?
    summary['Browser'] = data['web_driver'] unless data['web_driver'].blank?
    summary['Device Store'] = data['device_store'] unless data['device_store'].blank?
    summary['Payment Type'] = data['payment_type'] unless data['payment_type'].blank?
    summary['TC Version'] = data['tc_version'] unless data['device_store'].blank?
    summary['Station'] = data['station_name'] unless data['station_name'].blank?

    # Schedule information
    unless data['schedule_info'].nil?
      summary['Description'] = data['schedule_info']['description'] unless data['schedule_info']['description'].blank?
      summary['Start time'] = data['schedule_info']['start_date'].in_time_zone.strftime Rails.application.config.time_format
      min = data['schedule_info']['repeat_min']
      week = ModelCommon.to_day_of_week(data['schedule_info']['weekly'])

      if min.blank? && week.blank?
        summary['Repeat'] = 'None'
      elsif min.blank?
        summary['Repeat'] = "Every day of week: #{week}"
      else
        summary['Repeat'] = "Every #{min} minute(s)"
      end
    end

    query_string = ''
    query_string << "silo:#{data['silo']}" unless data['silo'].blank?
    query_string << ", suite_name:#{data['suite_name']}" unless data['suite_name'].blank?
    query_string << ", env:#{data['env']}" unless data['env'].blank?
    query_string << ", release_date:#{data['release_date']}" unless data['release_date'].blank?
    query_string << ", locale:#{data['locale']}" unless data['locale'].blank?

    <<-INTERPOLATED_HEREDOC.strip_heredoc
      <script>
        #{Rails.application.assets['chart_view.js']}
        load_pie_chart();
      </script>
      <div class="col-sm-5 left-right-padding-0px">
        <table>
          <tr><td>Status</td><td class="#{status.parameterize.underscore}">#{status}</td></tr>
          #{summary.reduce('') { |m, (key, val)| m + "<tr><td>#{key}</td><td>#{val}</td></tr>" }}
        </table>
      </div>
      <div class="col-sm-2">
        <canvas id="result_chart" width="150" height="150"></canvas>
        <div id="legend"></div>
      </div>
      <div>
        <div class="col-md-12 left-right-padding-0px">
          <b>Summary</b>
          <br/>
          <span>Total: #{data['total_cases']} = </span>
          <span class="passed">Passed:</span><span> #{data['total_passed']} + </span>
          <span class="failed">Failed:</span><span> #{data['total_failed']} + </span>
          <span class="n_a">Uncertain:</span><span> #{data['total_uncertain']}</span>
        </div>
        <div class="col-md-4 col-md-offset-8 left-right-padding-0px">
          <p class="text-right"><a href="#{root_url}/search?q=#{query_string}">see similar</a></p></div>
        </div>
      </div>
    INTERPOLATED_HEREDOC
  rescue => e
    Rails.logger.error "Error while loading test results >>> #{ModelCommon.full_exception_error e}"
    ''
  end

  def case_row_data(test_case, root_url = '')
    if self[:status] == 'done' || self[:status] == 'running'
      case_status = Run.status_text test_case['total_steps'], test_case['total_passed'], test_case['total_failed'], test_case['total_uncertain']
    else
      case_status = self[:status]
    end

    css_class = case_status.parameterize.underscore
    case_name = test_case['name'] || test_case['file_name']
    f_name = test_case['file_name'].nil? ? '' : test_case['file_name'].gsub(/.rb|.feature/, '.html')
    title_url = view_title_and_url
    url = File.join(root_url, title_url[:url], f_name).chomp('/')
    ds_url = File.join(root_url, title_url[:ds_url], f_name).chomp('/')

    {
      case_status: case_status,
      css_class: css_class,
      case_name: case_name,
      file_name: f_name,
      url: url,
      ds_url: ds_url
    }
  end

  def user_info
    User.get_user_info_by_id user_id
  end

  def to_html_row(root_url = '')
    user_info = User.get_user_info_by_id user_id
    station = data[:station_name].blank? ? '' : "Station: #{data[:station_name]}"
    status = status_and_class

    <<-INTERPOLATED_HEREDOC.strip_heredoc
    <tr>
      <td><span class="#{status[:css_class]}">#{status[:status]}</span></td>
      <td>#{created_at.in_time_zone.strftime Rails.application.config.time_format}<br/>Duration: #{duration}<br>#{station}</td>
      <td>User: #{user_info[:full_name]}<br/>#{to_html root_url}</td>
    </tr>
    INTERPOLATED_HEREDOC
  end

  def to_html(root_url = '')
    return "#{data['silo']} is running..." if data['cases'].size == 0

    case_links = ''
    data['cases'].each_with_index do |c, index|
      d = case_row_data(c, root_url)
      case_links << <<-INTERPOLATED_HEREDOC.strip_heredoc
      <tr class="#{d[:css_class]}">
        <td><a href="#{d[:ds_url]}" class="#{d[:css_class]} row-link">#{format '%02d', (index + 1)}. #{d[:case_name]}</a></td>
        <td>#{d[:case_status].upcase if self[:status] == 'done' || self[:status] == 'running'}</td>
        <td>#{c['duration']}</td>
      </tr>
      INTERPOLATED_HEREDOC
    end

    "<table class=\"run_details\"><tbody>#{link_html root_url}#{case_links}</tbody></table>"
  end

  def link_html(root_url = '')
    title_and_url = view_title_and_url root_url
    css_class = status_and_class[:css_class]

    <<-INTERPOLATED_HEREDOC.strip_heredoc
      <tr class="#{css_class}">
        <td><a class="#{css_class} row-link" href="#{title_and_url[:ds_url]}">#{title_and_url[:title].gsub(/.Feature|\(\)/, '')}</a></td>
        <td class="status">#{title_and_url[:status]}</td>
        <td class="duration">#{duration}</td>
      </tr>
    INTERPOLATED_HEREDOC
  end

  def view_run_report(testcase)
    set_instance_variable 'case', testcase

    html = render template: 'run/view_result', layout: 'view_result'
    html.delete! '✓✗Δ'

    document = Roadie::Document.new html
    document.transform
  end

  def generate_report_file(download_path, id, file_name, testcase_name, testrun_count)
    if id.blank? # Generate summary file
      new_file = File.new(File.join(download_path, '00_summary.html'), 'w')
      new_contents = <<-CONTENT.strip_heredoc
        <html>
          <head>
            <script>
              #{Rails.application.assets['jquery.min.js']}
              #{Rails.application.assets['chart_view.js']}
              load_pie_chart();
            </script>
            <style type="text/css">
              body { font-family : Helvetica, Arial; }
              .passed { color: green; }
              .failed { color: red; }
              .n_a { color: goldenrod; }
              ol { list-style-type: decimal-leading-zero; }
              .pie-legend li span {
                width: 1em;
                height: 1em;
                display: inline-block;
                margin-right: 5px;
              }
              .pie-legend {
                list-style: none;
              }
            </style>
          </head>
          <body>
            <h1>Leapfrog Automation - Summary</h1>
            #{testcase_name.html_safe}
            <br/>
            #{testrun_count.html_safe}
            <p>Email auto-generated from <a href="#{Rails.application.config.root_url}"> #{Rails.application.config.server_name}</a>. Please do not respond.</p>
            <p>Requester <a href="mailto:#{file_name}"> #{file_name}</a></p>
          </body>
        </ html>
      CONTENT

      new_contents.delete!('✓✗Δ')
    else
      tc_num = format '%02d', testrun_count
      filename = File.join(download_path, tc_num + '_' + testcase_name.gsub(/[^0-9A-Za-z]/, '_').squeeze('_') + '.html')
      new_file = File.new(filename, 'w')
      test_case = case_to_html file_name
      new_contents = view_run_report test_case
    end

    File.open(new_file, 'w') { |file| file.puts new_contents }
  end

  def case_to_html(file_name)
    @example_group_number = 0
    @example_number = 0
    @parent_number = 1

    cases = data['cases']
    return if cases.nil? || cases.length == 0

    test_case = cases.find { |c| c['file_name'].gsub(/.rb|.feature/, '') == file_name.gsub(/.rb|.feature/, '') }
    return if test_case.nil? || test_case.length == 0

    test_case['passed'] = test_case['total_steps'] - test_case['total_failed'] - test_case['total_uncertain']

    return test_case if test_case['error']

    return if test_case['steps'].nil?

    content = '' + generate_start_example_group(test_case['name'], @parent_number)
    content += '</dl></div>'
    test_case['steps'].each do |step|
      content += get_rspec_context step
    end

    test_case['content'] = content

    test_case
  end

  def get_rspec_context(step)
    temp_steps = step
    if temp_steps['steps'].nil?
      st = get_rspec_it(step)
    else
      st = generate_start_example_group(step['name'], @parent_number)
      temp_steps = temp_steps['steps']
      return '' if temp_steps.nil? || temp_steps.length == 0
      temp_steps.each do |s|
        st += get_rspec_context(s)
      end
      st += '</dl></div>'
    end
    st
  end

  def generate_example_passed(name, duration)
    "<dd class='example passed'><span class='passed_spec_name'>#{name}</span><span class='duration'>#{duration}</span></dd>"
  end

  def generate_example_failed(name, duration, exception)
    coder = HTMLEntities.new
    <<-INTERPOLATED_HEREDOC.strip_heredoc
    <dd class='example failed'>
        <span class='failed_spec_name'>#{name}</span>
        <span class='duration'>#{duration}</span>
        <div class='failure' id='failure_1'>
          <div class='message'>
            <pre>#{coder.encode exception['message']}</pre>
          </div>
          <div class='backtrace'>
            <pre>Debug info...<br>#{coder.encode exception['backtrace']}<br>#{exception['file_path']}</pre>
          </div>
        </div>
    </dd>
    INTERPOLATED_HEREDOC
  end

  def generate_example_pending(name)
    "<dd class='example not_implemented'><span class='not_implemented_spec_name'>#{name}</span></dd>"
  end

  def generate_start_example_group(name, number_of_parents)
    @example_group_number += 1
    <<-INTERPOLATED_HEREDOC.strip_heredoc
    <div id='div_group_#{@example_group_number}' class='example_group passed'>
      <dl style=\"margin-left: #{(number_of_parents - 1) * 15}px;\">
      <dt id='example_group_#{@example_group_number}' class='passed'>#{name}</dt>
    INTERPOLATED_HEREDOC
  end

  def make_example_group_header_red
    <<-INTERPOLATED_HEREDOC.strip_heredoc
    <script type=\"text/javascript\">makeRed('div_group_#{@example_group_number}');</script>
    <script type=\"text/javascript\">makeRed('example_group_#{@example_group_number}');</script>
    <script type=\"text/javascript\">makeRed('example_group_1');</script>
    <script type=\"text/javascript\">makeRed('div_group_1');</script>
    <script type=\"text/javascript\">makeRed('rspec-header');</script>
    INTERPOLATED_HEREDOC
  end
end
