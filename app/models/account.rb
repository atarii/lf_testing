class Account
  def self.do_oobe_flow(env, auto_link, username, password, platform, child_id = nil, dev_serial = nil)
    customer_management_service = CustomerManagement.new env
    authentication_service = Authentication.new env
    owner_management_service = OwnerManagement.new env
    device_management_service = DeviceManagement.new env
    device_profile_management = DeviceProfileManagement.new env

    # Get customer ID and session
    customer_id = customer_management_service.get_customer_id username
    session = authentication_service.get_service_session(username, password)
    profile_name = 'AutoProfile'

    if auto_link
      # auto-generate device serial and register child
      dev_serial = profile_name = "#{platform}#{Time.now.strftime('%Y%m%s%H%M%S')}"
      child_id = register_child_id(env, session, customer_id)
    else
      # Get platform from the entered device_serial
      fetch_device_xml = device_management_service.fetch_device dev_serial
      platform = fetch_device_xml.at_xpath('//device/@platform').to_s
      child_id = register_child_id(env, session, customer_id) if child_id.empty?
    end

    # claim device
    owner_management_service.claim_device(session, customer_id, dev_serial, platform, 1, profile_name, child_id, Time.now, '5', 'male')

    # update profile
    device_management_service.update_profiles(session, 'service', dev_serial, platform, 1, profile_name, child_id)

    # assign profile
    device_profile_management.assign_device_profile(customer_id, dev_serial, platform, 1, profile_name, child_id)
  end

  def self.register_child_id(env, session, customer_id)
    children_management_service = ChildManagement.new env
    child_res = children_management_service.register_child(session, customer_id)
    child_res.at_xpath('//child/@id').to_s
  end
end
