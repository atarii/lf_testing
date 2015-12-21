module RailsAppConfigHelper
  def tc_app_config(config_text, message_id, config_controls, submit_control)
    <<-HTML.html_safe
      <div class="content-header">
        <div class="header-inner">
          <p class='subheader'>#{config_text}</p>
        </div>
      </div>
      <div id="#{message_id}"></div>
      <div class="form-horizontal">
        #{Array.[](config_controls).join('')}
        #{submit_control}
      </div>
    HTML
  end
end
