require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TestCentral
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV['RAILS_TIME_ZONE'] || 'Pacific Time (US & Canada)'
    # Always use UTC for ActiveRecord stored values!
    config.time_format = '%Y-%m-%d @ %I:%M %P %Z'
    config.short_time_format = '%I:%M %P %Z'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # load lib directory
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/app/views/**/"]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += Dir["#{config.root}/lib/webservices/**/"]

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exist?(env_file)
    end

    config.allow_concurrency = true

    # Configure email server
    config.action_mailer.delivery_method = :smtp
    xml_content = Nokogiri::XML(File.read('config/config.xml'))
    config.action_mailer.smtp_settings = {
      address: xml_content.search('//smtpSetting/address').text,
      port: xml_content.search('//smtpSetting/port').text,
      domain: xml_content.search('//smtpSetting/domain').text,
      user_name: xml_content.search('//smtpSetting/username').text,
      password: xml_content.search('//smtpSetting/password').text,
      attachment_type: xml_content.search('//smtpSetting/attachmentType').text,
      authentication: 'plain',
      enable_starttls_auto: true
    }

    config.after_initialize do
      start_schedules
    end unless ENV['SKIP_SCHEDULERS']

    log_level = String(ENV['LOG_LEVEL'] || 'info').upcase
    config.log_level = log_level
    config.lograge.enabled = true
    config.lograge.ignore_actions = ['run#status']

    # best guess of server ip and port - no rails method to get actual values
    config.server_ip = ENV['RAILS_SERVER_IP'] || Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
    config.server_name = ENV['RAILS_SERVER_NAME'] || Socket.gethostname

    def start_schedules
      Thread.kill($start_schedules) unless $start_schedules.nil?
      $start_schedules = Thread.new {
        Thread.new { Station.new.init_server_on_db }
        Thread.new { Schedule.new.init_schedules }
        Thread.new { EmailRollup.new.active_email_rollups }
        Thread.new { EmailQueue.new.send_email_queue }
        Thread.new { Outpost.sch_outpost_status }
      }
    end
  end
end
