class ChildManagement
  CONST_CALLER_ID = ENV['CONST_CALLER_ID']

  def initialize(env = 'QA')
    @service_info = CommonMethods.service_info :child_management, env
  end

  def register_child(session, customer_id, child_name = "Auto#{CommonMethods.current_time}")
    CommonMethods.soap_call(
      @service_info[:endpoint],
      @service_info[:namespace],
      :register_child,
      "<caller-id>#{CONST_CALLER_ID}</caller-id>
      <session type='service'>#{session}</session>
      <customer-id>#{customer_id}</customer-id>
      <child id='1122' name='#{child_name}' dob='2001-10-08' grade='5' gender='male' can-upload='true' />"
    )
  end

  def list_children_info(session, customer_id)
    list_children_xml = CommonMethods.soap_call(
      @service_info[:endpoint],
      @service_info[:namespace],
      :list_children,
      "<caller-id>#{CONST_CALLER_ID}</caller-id>
      <session type='service'>#{session}</session>
      <customer-id>#{customer_id}</customer-id>"
    )

    return list_children_xml if list_children_xml[0] == 'error'
    child_info list_children_xml
  end

  def child_info(list_children_res)
    child_info = []
    items = list_children_res.xpath('//child')
    items.map do |e|
      child_info.push(
        id: e.at_xpath('@id').content,
        name: e.at_xpath('@name').content,
        grade: e.at_xpath('@grade').content,
        gender: e.at_xpath('@gender').content,
        dob: e.at_xpath('@dob').content
      )
    end

    child_info
  end
end
