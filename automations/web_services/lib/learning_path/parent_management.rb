class ParentManagementRest
  def self.create_parent(caller_id, email, password, firstname, lastname, email_optin, locale)
    header = { 'x-caller-id' => caller_id }
    params = { 'parentEmail' => email, 'password' => password, 'parentFirstName' => firstname, 'parentLastName' => lastname, 'email_option' => email_optin, 'locale' => locale }
    LFCommon.rest_call(LFRESOURCES::CONST_CREATE_PARENT, params, header, 'post')
  end

  def self.fetch_parent(caller_id, session, parent_id)
    params = { 'parentId' => parent_id }
    header = { 'x-caller-id' => caller_id, 'x-session-token' => session }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_PARENT % parent_id, params, header, 'get')
  end

  def self.update_parent(caller_id, session, parent_id, lastname, firstname, email, country, city, state, zipcode, picture_url, contentNotify_optin, milestoneNotify_optin, lfEmail_optin, lpEmail_optin)
    params = { 'parentID' => parent_id, 'parentLastName' => lastname, 'parentFirstName' => firstname,
               'parentEmail' => email, 'parentCountry' => country, 'parentCity' => city,
               'parentState' => state, 'parentZipCode' => zipcode, 'parentPictureURL' => picture_url,
               'parentContentNotify_optin' => contentNotify_optin, 'parentMilestoneNotify_optin' => milestoneNotify_optin,
               'parentLFemail_optin' => lfEmail_optin, 'parentLPemail_optin' => lpEmail_optin
    }
    header = { 'x-caller-id' => caller_id, 'x-session-token' => session }
    LFCommon.rest_call(LFRESOURCES::CONST_UPDATE_PARENT % parent_id, params, header, 'put')
  end

  def self.fetch_child(caller_id, session, parent_id)
    header = { 'x-caller-id' => caller_id, 'x-session-token' => session }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_CHILDREN % parent_id, nil, header, 'get')
  end
end
