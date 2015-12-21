class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :reset_session
  before_filter :grant_permission, except: %w(signin help about contact create_qa)

  def grant_permission
    op_run_urls = []

    Outpost.select(:silo).group(:silo).each do |x|
      op_run_urls.push "#{x.silo.downcase}/run/index"
    end

    power_access_denied_list = ['users/create', 'users/logging', 'tc/run/index', 'tc/run/delete', 'tc/run/view_silo_group'] + op_run_urls
    qa_access_denied_list = power_access_denied_list + ['stations/index', 'rails_app_config/configuration', 'email_rollup/index', 'accounts/clear_account', 'checksum_comparison/index', 'checksum_comparison/browsing_files/index', 'accounts/fetch_customer', 'accounts/link_devices', 'device_lookup/index', 'geoip_lookup/index', 'pins/redeem', 'fetch_pin_attributes/index']
    guest_access_denied_list = qa_access_denied_list + ['scheduler/index', 'atg/run/index', 'atg/run/delete', 'ws/run/index', 'ws/run/delete', 'outpost/upload_results']

    User.current_user = User.find_by(email: session[:user_email])
    case session[:user_role]
    when 1 # Administrator
    when 2 # PowerUser
      deny_access power_access_denied_list
    when 3 # QA
      deny_access qa_access_denied_list
    else # Guest is only able to use controller "browsing_files", so we just prevent him to delete
      deny_access(guest_access_denied_list, true)
    end
  end

  def deny_access(controls, is_guest = false)
    controller = params[:controller]
    action = params[:action]
    silo = params[:silo_name]
    type = params[:type]

    if silo.blank?
      if type.blank?
        return unless controls.include? controller + '/' + action
      else
        return unless controls.include? type + '/' + controller + '/' + action
      end
    else
      return unless controls.include? silo.downcase + '/' + controller + '/' + action
    end

    if is_guest
      store_current_location
      flash.now[:error] = 'Please login to access this page'
      render 'users/signin'
    else
      redirect_to '/accessdeny'
    end
  end

  def store_current_location
    if %w(/users/signin /users/signout /signin /signout).include?(request.path) && !request.xhr?
      session[:previous_url] = '/dashboard/index'
    else
      session[:previous_url] = request.fullpath
    end
  end
end
