require 'digest'

class User < ActiveRecord::Base
  include PublicActivity::Common
  cattr_accessor :current_user
  has_one :user_role_map

  def do_sign_in(username, password)
    @error = ''
    check_empty 'Username', username
    check_empty 'Password', password

    if @error == ''
      user_info = get_user_info(username)
      if user_info.empty? || user_info[:password] != Digest::MD5.hexdigest(password)
        @error = 'Sorry, your username and password are incorrect - Please try again!'
      elsif !user_info[:is_active]
        @error = 'Sorry, your account is not activated - Please contact administrator to active your account!'
      end
    end

    @error
  end

  def do_create_user(first_name, last_name, email, password, active = 1, role = 3)
    @error = ''
    check_empty 'Firstname', first_name
    check_empty 'Lastname', last_name
    valid_email email
    check_existing_user(email)
    valid_password password

    if @error == ''
      password = Digest::MD5.hexdigest(password)
      @user = User.new(
        first_name: first_name,
        last_name: last_name,
        email: email,
        password: password,
        is_active: active
      )

      if @user.save
        @role_map = UserRoleMap.new(
          role_id: role,
          user_id: User.get_user_id(email)
        )
        @error << 'Error while adding user\'s role. Please try again!' unless @role_map.save
        @user.create_activity key: 'user.create', owner: User.current_user
      else
        @error << 'Error while creating new account. Please try again!'
      end
    end

    @error
  end

  def do_update_user(userid, password, firstname, lastname, email, active, role)
    @error = ''
    check_existing_user(email) unless email == User.get_user_info_by_id(userid)[:email]

    if @error == ''
      if password.to_s.empty?
        schedule = User.update(userid, first_name: firstname, last_name: lastname, email: email, is_active: active)
      else
        schedule = User.update(userid, first_name: firstname, last_name: lastname, email: email, password: Digest::MD5.hexdigest(password), is_active: active)
      end

      @error << 'Error while updating user information. Please try again!' unless schedule
      schedule.create_activity key: 'user.update', owner: User.current_user
      @error << 'Error while updating user\'s role. Please try again!' unless UserRoleMap.where(user_id: userid).update_all(role_id: role)
    end

    @error
  end

  def self.get_user_id(email)
    user_info = User.where(email: email).select(:id).first
    return '' if user_info.nil?
    user_info[:id]
  end

  def get_user_info(email)
    user_info = User.joins(:user_role_map).where(email: email).select(:id, :first_name, :last_name, :email, :password, :is_active, :role_id).first
    return {} if user_info.nil?

    { id: user_info[:id],
      first_name: user_info[:first_name],
      last_name: user_info[:last_name],
      email: user_info[:email],
      password: user_info[:password],
      is_active: user_info[:is_active],
      role_id: user_info[:role_id] }
  end

  def self.get_user_info_by_id(id)
    user_info = User.where(id: id).select(:id, :first_name, :last_name, :email, :is_active).first
    return {} if user_info.nil?

    { id: user_info[:id],
      first_name: user_info[:first_name],
      last_name: user_info[:last_name],
      email: user_info[:email],
      is_active: user_info[:is_active],
      full_name: "#{user_info[:first_name]} #{user_info[:last_name]}" }
  end

  private

  def check_existing_user(username)
    @error << 'An account has already been created using this email address.<br>' unless get_user_info(username).empty?
  end

  def check_empty(field, inputtext)
    @error << field + ' should not be empty<br>' if inputtext.blank?
  end

  def valid_email(email)
    @error << 'Email can not be blank and should have format: example@abc.com<br/>' if email.blank? || !(email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  end

  def valid_password(password)
    if password.to_s.empty?
      @error << 'Password should not empty<br>'
    elsif password.length < 6
      @error << 'Password should not less than 6 characters<br>'
    end
  end
end
