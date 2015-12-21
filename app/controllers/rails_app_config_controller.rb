class RailsAppConfigController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def configuration
    config = RailsAppConfig.new
    xml_content = Nokogiri::XML(File.read(config.config_file))
    @address = xml_content.search('//smtpSetting/address').text
    @port = xml_content.search('//smtpSetting/port').text
    @domain = xml_content.search('//smtpSetting/domain').text
    @username = xml_content.search('//smtpSetting/username').text
    @password = xml_content.search('//smtpSetting/password').text
    @attachment_type = xml_content.search('//smtpSetting/attachmentType').text
    @report_type = xml_content.search('//reportType/type').text
    @limit_rng_test = xml_content.search('//autoSetting/limitRunningTest').text
    @refresh_rate = xml_content.search('//autoSetting/refreshRunningRate').text
    @email_refresh_rate = xml_content.search('//emailQueueSetting/refreshEmailRate').text
    @outpost_refresh_rate = xml_content.search('//autoSetting/refreshOutpostStatus').text
  end

  def update_smtp_settings
    msg = nil
    config = RailsAppConfig.new

    begin
      smtp_auth = config.verify_smtp_authentication params
      unless smtp_auth.class == Net::SMTP
        render plain: ModelCommon.error_message("Error while updating SMTP settings</br> #{smtp_auth[:error_message]}")
        return
      end

      config.update_smtp_settings params
      config.update_smtp_settings_global_variables params

      msg = ModelCommon.success_message 'Update successful.'
    rescue => e
      msg = ModelCommon.error_message "Error while updating SMTP settings: #{e.message}"
    end

    render plain: msg
  end

  def update_run_queue_option
    msg = nil
    config = RailsAppConfig.new

    begin
      update_status = config.update_run_queue_option params['limit_number'], params['refresh_rate']

      case update_status
      when RailsAppConfig::NOT_A_NUMBER_CONST
        msg = ModelCommon.error_message 'Please enter a number.'
      when RailsAppConfig::SUCCESSFUL_UPDATE
        msg = ModelCommon.success_message 'Update successful.'
      end
    rescue => e
      msg = ModelCommon.error_message "Error while updating Run queue settings: #{e.message}"
      Rails.logger.error ModelCommon.full_exception_error e
    end

    render html: msg.html_safe
  end

  def update_email_queue_setting
    msg = nil
    config = RailsAppConfig.new
    email_refresh_rate = params['email_refresh_rate']

    begin
      update_status = config.update_email_queue_setting email_refresh_rate

      case update_status
      when RailsAppConfig::NOT_A_NUMBER_CONST
        msg = ModelCommon.error_message 'Please enter a number.'
      when RailsAppConfig::SUCCESSFUL_UPDATE
        msg = ModelCommon.success_message 'Update successful.'
      end
    rescue => e
      msg = ModelCommon.error_message "Error while updating Email refresh rate: #{e.message}"
      Rails.logger.error ModelCommon.full_exception_error e
    end

    render html: msg.html_safe
  end

  def update_outpost_settings
    msg = nil
    config = RailsAppConfig.new
    outpost_refresh_rate = params['outpost_refresh_rate']

    begin
      update_status = config.update_outpost_settings outpost_refresh_rate

      case update_status
      when RailsAppConfig::NOT_A_NUMBER_CONST
        msg = ModelCommon.error_message 'Please enter a number.'
      when RailsAppConfig::SUCCESSFUL_UPDATE
        msg = ModelCommon.success_message 'Update successful.'
      end
    rescue => e
      msg = ModelCommon.error_message "Error while updating Outpost refresh rate: #{e.message}"
      Rails.logger.error ModelCommon.full_exception_error e
    end

    render html: msg.html_safe
  end
end
