class Curriculum
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:curriculum][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:curriculum][:namespace]

  def self.create_question_curriculum(caller_id, device_serial, slot, cur_id, cur_name, delivered, child_name, grade)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :create_question_curriculum,
      "<caller-id>#{caller_id}</caller-id>
      <device-serial>#{device_serial}</device-serial>
      <slot>#{slot}</slot>
      <curriculum id='#{cur_id}' status='pending' name='#{cur_name}' type='S' completion-param='3' delivered='#{delivered}' completion-rate='0' owner-name='#{child_name}' created=''/>
      <operands grade='#{grade}' category='0'>
        <operand>a</operand>
        <operand>an</operand>
        <operand>on</operand>
        <operand>of</operand>
        <operand>to</operand>
      </operands>"
    )
  end

  def self.list_curricula(caller_id, device_serial, slot)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_curricula,
      "<caller-id>#{caller_id}</caller-id>
      <device-serial>#{device_serial}</device-serial>
      <slot>#{slot}</slot>"
    )
  end

  def self.remove_curriculum(caller_id, cyo_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :remove_curriculum,
      "<caller-id>#{caller_id}</caller-id>
      <cyo-id>#{cyo_id}</cyo-id>"
    )
  end

  def self.create_sublevel_curriculum(caller_id, device_serial, slot, cur_id, cur_name, child_name, type, delivered, started, created, grade)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :create_sublevel_curriculum,
      "<caller-id>#{caller_id}</caller-id>
      <device-serial>#{device_serial}</device-serial>
      <slot>#{slot}</slot>
      <curriculum id='#{cur_id}' name='#{cur_name}' owner-name='#{child_name}' type='#{type}' completion-param='10' completion-rate='0' status='pending' delivered='#{delivered}' started='#{started}' created='#{created}'/>
      <sublevel-groups>
        <sublevel-groups grade='#{grade}'>
          <sublevel id='1' status='NOT-STARTED'>
            <name>nam</name>
            <description>description</description>
            <example>example</example>
            </sublevel>
        </sublevel-groups>
      </sublevel-groups>"
    )
  end

  def self.fetch_sub_level_curriculum(caller_id, cyo_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_sub_level_curriculum,
      "<caller-id>#{caller_id}</caller-id>
      <cyo-id>#{cyo_id}</cyo-id>"
    )
  end

  def self.fetch_question_curriculum(caller_id, cyo_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_question_curriculum,
      "<caller-id>#{caller_id}</caller-id>
      <cyo-id>#{cyo_id}</cyo-id>"
    )
  end

  def self.list_curricula_by_subject_and_status(caller_id, device_serial, slot, subject, status)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_curricula_by_subject_and_status,
      "<caller-id>#{caller_id}</caller-id>
      <device-serial>#{device_serial}</device-serial>
      <slot>#{slot}</slot>
      <subject>#{subject}</subject>
      <status>#{status}</status>"
    )
  end

  def self.list_curriculum_subjects(caller_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_curriculum_subjects,
      "<caller-id>#{caller_id}</caller-id>"
    )
  end

  def self.list_sub_level_catalog(caller_id, subject)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_sub_level_catalog,
      "<caller-id>#{caller_id}</caller-id>
      <subject>#{subject}</subject>"
    )
  end

  def self.list_sub_level_catalog_by_platform(caller_id, subject, platform)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_sub_level_catalog_by_platform,
      "<caller-id>#{caller_id}</caller-id>
      <subject>#{subject}</subject>
      <platform-type>#{platform}</platform-type>"
    )
  end

  def self.remove_all_curriculum(caller_id, list_cur_resp)
    cur_count = list_cur_resp.xpath('//curriculum').count
    (1..cur_count).each do |i|
      if list_cur_resp.xpath('//curriculum[' + i.to_s + ']').attr('status').text != 'removed'
        cyo_id = list_cur_resp.xpath('//curriculum[' + i.to_s + ']').attr('id').text
        Curriculum.remove_curriculum(caller_id, cyo_id)
      end
    end
  end
end
