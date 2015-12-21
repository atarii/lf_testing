require 'net/http'
require 'nokogiri'
require 'parallel'
require 'uri'

class DashboardController < ApplicationController
  skip_before_filter :grant_permission

  def index
    @current_time = Time.now.in_time_zone

    # get env versions and show on dashboard
    env_versions
    @test_outposts = Outpost.group_outpost

    @run_data = {
      queued: {
        runs: Run.where(status: 'queued').order(:created_at),
        type: 'queued'
      },
      recent: {
        runs: Run.where('status != \'queued\'').order(created_at: :desc).limit(5),
        links: [{ name: 'daily results', url: 'view/daily' }]
      },
      today: {
        runs: Run.where('status != \'queued\' AND created_at >= ? AND created_at <= ? ', @current_time.beginning_of_day.utc, @current_time.end_of_day.utc),
        url: 'view/daily',
        hide_list: true
      },
      scheduled: {
        runs: Schedule.where(status: 1).order(next_run: :asc),
        links: [{ name: 'edit', url: admin_scheduler_path }]
      }
    }
  end

  def daily
    date = params[:date].blank? ? Time.now.in_time_zone.strftime('%Y-%m-%d') : params[:date].delete('/')
    @current_date = Date.parse date
    @previous_date = @current_date - 1.days
    @next_date = @current_date + 1.days
    @test_run_content = Dashboard.new.testrun_summary nil, false, '', date
  end

  def env_versions
    # get env version from env_versions table
    @services = JSON.parse(EnvVersion.last.services, symbolize_names: true)[:services]
    @envs = @services.map { |service| service[:env] }.uniq
    @apps = @services.map { |service| service[:name] }.uniq

    # get new env versions if there is no version data in env_versions table
    refresh_env(false) if @services[0][:endpoints].empty?
    @last_updated_env = EnvVersion.last.updated_at.strftime Rails.application.config.time_format
  end

  def refresh_env(ajax = true)
    @services = JSON.parse(File.read('config/env_version.json'), symbolize_names: true)[:services]
    @envs = @services.map { |service| service[:env] }.uniq
    @apps = @services.map { |service| service[:name] }.uniq
    @services.each { |s| expand_services(s) }

    Parallel.each(@services, in_threads: 10) { |s| s[:endpoints].each { |e| http_fetch_contents(e) } }

    @services.each { |s| s[:endpoints].each { |e| e[:first_version] = e[:body] && get_first_version(e[:body]) } }

    # delete :body key of endpoint
    @services.each { |service| service[:endpoints].map! { |endpoint| endpoint.reject { |e| e == :body } } }

    EnvVersion.create(services: { services: @services }.to_json)

    return '0' unless ajax
    render plain: '1'
  end

  def expand_services(config)
    config[:endpoints] = []
    config[:instances].split(',').each do |i|
      config[:endpoints] << { first_version: '', port: '', subdomain: '', url: "#{config[:protocol] || 'http://'}#{i}.leapfrog.com#{config[:path]}" }
    end

    config[:vips].each { |n| config[:endpoints] << { first_version: '', port: '', subdomain: '', url: n } } if config[:vips]
  end

  def http_fetch_contents(endpoint)
    uri = URI.parse(endpoint[:url])
    endpoint[:subdomain] = uri.host.rpartition('.leapfrog.com')[0]
    endpoint[:port] = uri.port

    begin
      Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        request = Net::HTTP::Get.new uri
        response = http.request request
        response.code != '200' && endpoint[:error] = "HTTP status error: #{response.code}"
        endpoint[:body] = response.body unless endpoint[:error]
      end
    rescue EOFError, Errno::ECONNRESET, Errno::EINVAL, Errno::ETIMEDOUT, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, OpenSSL::SSL::SSLError, SocketError, Timeout::Error, Errno::ECONNABORTED => e
      endpoint[:error] = e.class.name
    rescue Errno::ECONNREFUSED
      endpoint[:error] = 'Network permission denied'
    end
  end

  def get_first_version(version_file_contents)
    result = version_file_contents.lines.first.chomp.split(':')[2] || version_file_contents.lines.first.chomp.split(':')[1]
    return result if result

    html_doc = Nokogiri::HTML(version_file_contents)
    "Bamboo:#{html_doc.xpath('//table/tr[2]/td[3]/b').text} SVN:#{html_doc.xpath('//table/tr[2]/td[2]/b').text}"
  end

  def get_specific_versions(version_file_contents, version_names)
    puts 'get_specific_versions'
    versions = []
    version_names.each do |version_name|
      version_file_contents =~ /(?<package>[^:]+):(?<name>#{version_name}):(?<version>[^:]+$)/
      $LAST_MATCH_INFO && versions << $LAST_MATCH_INFO['version']
    end

    versions
  end

  def delete_outpost
    Outpost.destroy params[:id]
    render json: { status: 'OK' }
  end
end
