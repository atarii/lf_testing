require 'github/markup'

class UsersController < ApplicationController
  def signin
    flash.clear
    @error = ''
    @user = User.new

    return unless request.post?

    @error = @user.do_sign_in params[:user_email], params[:user_password]
    if @error == ''
      session[:user_email] = params[:user_email]
      user_info = @user.get_user_info(params[:user_email])
      session[:user_role] = user_info[:role_id]
      session[:first_name] = user_info[:first_name]

      redirect_to session[:previous_url].nil? ? '/dashboard/index' : session[:previous_url]
    else
      flash.now[:error] = @error.html_safe
    end
  end

  def signout
    session[:user_email] = nil
    session[:user_role] = nil
    session[:first_name] = nil
    session[:previous_url] = nil

    redirect_to '/signin'
  end

  def create
    flash.clear
    @error = ''
    @user = User.new

    if request.post?
      if params[:commit] == 'Create'
        @error = @user.do_create_user(params[:first_name], params[:last_name], params[:email], params[:password], params[:is_active].to_i, params[:role_id])
        if @error == ''
          flash.now[:success] = 'Your account is created successfully.'
        else
          flash.now[:error] = @error.html_safe
        end
      elsif params[:commit] == 'Search'
        search_user params[:email]
        return
      end
    elsif !params[:email].nil?
      search_user params[:email]
      return
    end

    render '/users/create_user'
  end

  def search_user(email)
    @user = @user.get_user_info(email)
    if @user.empty?
      flash.now[:error] = 'Cannot find the email - please try again!'
      render '/users/create_user'
    else
      render '/users/edit_user'
    end
  end

  def create_qa
    flash.clear
    @error = ''
    @user = User.new

    if request.post?
      @error = @user.do_create_user(params[:first_name], params[:last_name], params[:email], params[:password], 0)
      if @error == ''
        Thread.new { UserMailer.email_active_request(params[:email]).deliver }
        flash.now[:success] = 'Your account is created successfully. Please contact Test Central Administrator to activate your account!'
      else
        flash.now[:error] = @error.html_safe
      end
    end

    render '/users/signin'
  end

  def edit
    flash.clear
    @user = User.new

    # get user info before updating
    user_info = User.get_user_info_by_id params[:id]

    # update user info
    is_active = params[:is_active].to_i
    @error = @user.do_update_user(params[:id], params[:password], params[:first_name], params[:last_name], params[:email], is_active, params[:role_id])

    if @error == ''
      Thread.new { UserMailer.email_active_response(params[:email], "#{params[:first_name]} #{params[:last_name]}").deliver } if user_info[:is_active] == false && is_active == 1
      flash.now[:success] = 'Your account is updated successfully'
      @user = @user.get_user_info(params[:email])
    else
      flash.now[:error] = @error.html_safe
    end

    render '/users/edit_user'
  end

  def logging
    @selected_page = params[:page].blank? ? 1 : params[:page]
    @selected_user = params[:user_id]
    if @selected_user.blank?
      all_records = PublicActivity::Activity.order('id desc').where.not(owner_id: nil)
    else
      all_records = PublicActivity::Activity.order('id desc').where(owner_id: params[:user_id].to_i)
    end

    xml_content = Nokogiri::XML(File.read(RailsAppConfig.new.config_file))
    @limit_log_paging = xml_content.search('//pagingSetting/loggingPageLimit').text
    limit = xml_content.search('//pagingSetting/loggingPageLimit').text.to_i
    offset = (params[:page] ? (params[:page].to_i - 1) : 0) * limit
    @page_count = (all_records.size % limit) == 0 ? (all_records.size / limit) : (all_records.size / limit) + 1
    activities = all_records.limit(limit).offset(offset)
    @logging_result = ''

    activities.each do |a|
      if a.key.include?('update')
        action = 'updated'
      elsif a.key.include?('create')
        action = 'created'
      elsif a.key.include?('destroy')
        action = 'deleted'
      elsif a.key.include?('redeem')
        action = 'redeemed'
        redeem_info = a.parameters
      end

      @logging_result += "<tr class='bout'>
      <td>
        #{a.created_at.strftime Rails.application.config.time_format}
      </td>
      <td>
        <a href='/users/logging/u/#{a.owner_id}'>#{User.find(a.owner_id.to_i).first_name}</a>
      </td>
      <td>"
      if action == 'redeemed'
        @logging_result += "#{action} the PIN=#{redeem_info[:pin]}</br>
          Env=#{redeem_info[:env]}, Type=#{redeem_info[:type_pin].gsub('redeem', '')}</br>
          Locale=#{redeem_info[:locale]}, Email=#{redeem_info[:email]}
          </td>
          </tr>"
      else
        @logging_result += "#{action} the #{a.trackable_type} ID=#{a.trackable_id}
          </td>
        </tr>"
      end
    end
    render '/users/logging'
  end

  def update_limit
    config = RailsAppConfig.new
    limit_number = params['limit_log_paging']

    begin
      re = config.update_paging_number limit_number
      case re
      when RailsAppConfig::NOT_A_NUMBER_CONST
        flash.now[:error] = 'Please enter a number'
      when RailsAppConfig::SUCCESSFUL_UPDATE
        flash.now[:success] = 'Update successful!'
      end
    rescue => e
      flash.now[:error] = 'An error occurred while updating - please try again!'
      Rails.logger.error "run error ! >>> update_limit_rng_test error >>> #{e}"
    end
    redirect_to '/users/logging'
  end

  def help
    @link_list = FileUtilsC.get_filesname_recursively 'guides'
  end

  def download
    send_file params[:file]
  end

  def view_markdown
    @content = GitHub::Markup.render params[:file]
  end
end
