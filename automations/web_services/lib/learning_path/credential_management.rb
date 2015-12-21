class CredentialManagementRest
  def self.login(caller_id, email, password)
    params = { 'email' => email, 'password' => password }
    header = { 'x-caller-id' => caller_id }
    LFCommon.rest_call(LFRESOURCES::CONST_LOGIN, params, header, 'post')
  end

  def self.reset_password(caller_id, email)
    params = { 'email' => email }
    header = { 'x-caller-id' => caller_id }
    LFCommon.rest_call(LFRESOURCES::CONST_RESET_PASSWORD, params, header, 'post')
  end

  def self.change_password(caller_id, session, current, new)
    params = { 'current' => current, 'new' => new }
    header = { 'x-caller-id' => caller_id, 'x-session-token' => session }
    LFCommon.rest_call(LFRESOURCES::CONST_CHANGE_PASSWORD, params, header, 'put')
  end
end
