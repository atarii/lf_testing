class RewardService
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:reward][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:reward][:namespace]

  def self.fetch_rewards(caller_id, device_serial, slot, length, offset)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_rewards,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id/>
      <device>#{device_serial}</device>
      <slot>#{slot}</slot>
      <page total='' length='#{length}' offset='#{offset}'/>"
    )
  end

  def self.fetch_rewards_by_title(caller_id, device_serial, slot, title_id, length, offset)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_rewards_by_title,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id/>
      <device>#{device_serial}</device>
      <slot>#{slot}</slot>
      <title id='#{title_id}' name='Coloring' levels='' platform='' product-id='' most-recent-play-date='' min-curriculum-level='' max-curriculum-level='' locale=''/>
      <page total='' length='#{length}' offset='#{offset}'/>"
    )
  end

  def self.fetch_reward_by_title_and_type(caller_id, device_serial, slot, title_id, type, length, offset)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_rewards_by_title_and_type,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id/>
      <device>#{device_serial}</device>
      <slot>#{slot}</slot>
      <title id='#{title_id}' name='' levels='' platform='' product-id='' most-recent-play-date='' min-curriculum-level='' max-curriculum-level='' locale=''/>
      <type>#{type}</type>
      <page total='' length='#{length}' offset='#{offset}'/>"
    )
  end

  def self.fetch_rewards_by_type(caller_id, device_serial, slot, type, length, offset)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_rewards_by_type,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id/>
      <device>#{device_serial}</device>
      <slot>#{slot}</slot>
      <type>#{type}</type>
      <page total='' length='#{length}' offset='#{offset}'/>"
    )
  end

  def self.fetch_reward_summary(caller_id, device_serial, slot)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_reward_summary,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id/>
      <device>#{device_serial}</device>
      <slot>#{slot}</slot>"
    )
  end

  def self.mark_reward_seen(caller_id, device_serial, slot, value, id, title_id)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :mark_reward_seen,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id/>
      <device>#{device_serial}</device>
      <slot>#{slot}</slot>
      <reward name='' value='#{value}' id='#{id}' title-id='#{title_id}' asset-id='1' asset='' type='' seen='false' earnDate=''/>"
    )
  end
end
