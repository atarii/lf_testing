class RailsAppConfig
  attr_reader :config_file
  NOT_A_NUMBER_CONST = 2
  SUCCESSFUL_UPDATE = 1

  def initialize
    @config_file = ENV['MACHINE_FILE']
  end

  def update_node(path, value)
    xml_content = Nokogiri::XML(File.read(@config_file))
    xml_content.search('//smtpSetting/' + path)[0].inner_html = value
    File.open(@config_file, 'w') { |f| f.print(xml_content.to_xml) }
  end

  def update_smtp_settings(params)
    # update input to xml file
    update_node 'address', params[:address]
    update_node 'port', params[:port]
    update_node 'domain', params[:domain]
    update_node 'username', params[:username]
    update_node 'password', params[:password]
    update_node 'attachmentType', params[:attachment_type]
  end

  def update_smtp_settings_global_variables(params)
    smtp_settings = Rails.application.config.action_mailer.smtp_settings
    smtp_settings[:address] = params[:address]
    smtp_settings[:port] = params[:port]
    smtp_settings[:domain] = params[:domain]
    smtp_settings[:user_name] = params[:username]
    smtp_settings[:password] = params[:password]
    smtp_settings[:attachment_type] = params[:attachment_type]
  end

  def verify_smtp_authentication(params)
    smtp = Net::SMTP.new params[:address], params[:port]
    smtp.enable_starttls
    smtp.start('', params[:username], params[:password], :login)
  rescue SocketError, Net::OpenTimeout, Net::SMTPAuthenticationError => e
    { error_class_name: e.class.name, error_message: e.message }
  end

  def update_run_queue_option(limit_number, refresh_rate)
    begin
      limit_number.to_i
      refresh_rate.to_i
    rescue
      return NOT_A_NUMBER_CONST
    end

    xml_content = Nokogiri::XML(File.read(@config_file))
    xml_content.search('//autoSetting/limitRunningTest')[0].inner_html = limit_number
    xml_content.search('//autoSetting/refreshRunningRate')[0].inner_html = refresh_rate
    File.open(@config_file, 'w') { |f| f.print(xml_content.to_xml) }
    $limit_number = limit_number.to_i
    $refresh_rate = refresh_rate.to_i
    Thread.new { Schedule.new.exec_testcentral_test }

    SUCCESSFUL_UPDATE
  end

  def update_email_queue_setting(refresh_rate)
    begin
      refresh_rate.to_i
    rescue
      return NOT_A_NUMBER_CONST
    end

    xml_content = Nokogiri::XML(File.read(@config_file))
    xml_content.search('//emailQueueSetting/refreshEmailRate')[0].inner_html = refresh_rate
    File.open(@config_file, 'w') { |f| f.print(xml_content.to_xml) }
    $email_refresh_rate = refresh_rate.to_i
    Thread.new { EmailQueue.new.send_email_queue }

    SUCCESSFUL_UPDATE
  end

  def update_paging_number(paging_number)
    begin
      paging_number.to_i
    rescue
      return NOT_A_NUMBER_CONST
    end

    xml_content = Nokogiri::XML(File.read(@config_file))
    xml_content.search('//pagingSetting/loggingPageLimit')[0].inner_html = paging_number.to_s
    File.open(@config_file, 'w') { |f| f.print(xml_content.to_xml) }

    SUCCESSFUL_UPDATE
  end

  def update_outpost_settings(refresh_rate)
    begin
      refresh_rate.to_i
    rescue
      return NOT_A_NUMBER_CONST
    end

    xml_content = Nokogiri::XML(File.read(@config_file))
    xml_content.search('//autoSetting/refreshOutpostStatus')[0].inner_html = refresh_rate
    File.open(@config_file, 'w') { |f| f.print(xml_content.to_xml) }
    $outpost_refresh_rate = refresh_rate.to_i
    Thread.new { Outpost.sch_outpost_status }

    SUCCESSFUL_UPDATE
  end
end
