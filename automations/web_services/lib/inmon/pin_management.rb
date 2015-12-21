class PINManagement
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:pin_management][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:pin_management][:namespace]

  def self.redeem_gift_packages(caller_id, cus_id, package_id, pin)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :redeem_gift_packages,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'/>
      <cust-key>#{cus_id}</cust-key>
      <pin-text>#{pin}</pin-text>
      <locale>US</locale>
      <references key='accountSuffix' value='USD'/>
      <references key='currency' value='USD'/>
      <references key='locale' value='en_US'/>
      <references key='sku.code_0' value='#{package_id}'/>
      <references key='sku.count' value='1'/>
      <references key='sku.name_0' value='Learn to Read at the Storybook Factory'/>
      <references key='transactionId' value='LFGQSR#{LFCommon.get_current_time}'/>"
    )
  end

  def self.fetch_pin_attributes(caller_id, pin, locale = 'US')
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :fetch_pin_attributes,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'/>
      <pin-text>#{pin}</pin-text><locale>#{locale}</locale>"
    )
  end

  def self.redeem_gift_value(caller_id, cus_id, pin)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :redeem_gift_value,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'/>
      <cust-key>#{cus_id}</cust-key>
      <pin-text>#{pin}</pin-text>
      <locale>US</locale><references key='accountSuffix' value='USD'/>
      <references key='currency' value='USD'/>
      <references key='transactionId' value='LFGQSR#{LFCommon.get_current_time}'/>"
    )
  end

  def self.redeem_value_card(caller_id, cus_id, pin)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :redeem_value_card,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'/>
      <cust-key>#{cus_id}</cust-key>
      <pin-text>#{pin}</pin-text>
      <locale>US</locale>
      <references key='accountSuffix' value='USD'/>
      <references key='currency' value='USD'/>
      <references key='locale' value='en_US'/>
      <references key='CUST_KEY' value='#{cus_id}'/>
      <references key='transactionId' value='11223344'/>"
    )
  end

  def self.revoke_pins(caller_id, pin)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :revoke_pins,
      "<caller-id>#{caller_id}</caller-id>
      <session type='service'/>
      <cust-key/>
      <pin-text>#{pin}</pin-text>"
    )
  end
end
