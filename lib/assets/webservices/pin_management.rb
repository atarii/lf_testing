class PINManagement
  CONST_CALLER_ID = ENV['CONST_CALLER_ID']

  def initialize(env = 'QA')
    @service_info = CommonMethods.service_info :pin_management, env
  end

  def redeem_gift_packages(cus_id, pin, locale)
    pin_info = generate_pin_info_by_locale(locale)[0]
    CommonMethods.soap_call(
      @service_info[:endpoint],
      @service_info[:namespace],
      :redeem_gift_packages,
      "<caller-id>#{CONST_CALLER_ID}</caller-id>
      <session type='service'/>
      <cust-key>#{cus_id}</cust-key>
      <pin-text>#{pin}</pin-text>
      <locale>#{locale}</locale>
      <references key='accountSuffix' value='#{pin_info[:reference][:accountSuffix]}'/>
      <references key='currency' value='#{pin_info[:reference][:currency]}'/>
      <references key='locale' value='#{pin_info[:reference][:locale]}'/>
      <references key='sku.code_0' value='58129-96914'/>
      <references key='sku.count' value='1'/>
      <references key='sku.name_0' value='Learn to Read at the Storybook Factory'/>
      <references key='transactionId' value='LFGQSR#{CommonMethods.current_time}'/>"
    )
  end

  def redeem_gift_value(cus_id, pin, locale)
    pin_info = generate_pin_info_by_locale(locale)[0]
    CommonMethods.soap_call(
      @service_info[:endpoint],
      @service_info[:namespace],
      :redeem_gift_value,
      "<caller-id>#{CONST_CALLER_ID}</caller-id>
      <session type='service'/>
      <cust-key>#{cus_id}</cust-key>
      <pin-text>#{pin}</pin-text>
      <locale>#{pin_info[:locale]}</locale>
      <references key='accountSuffix' value='#{pin_info[:reference][:accountSuffix]}'/>
      <references key='currency' value='#{pin_info[:reference][:currency]}'/>
      <references key='transactionId' value='LFGQSR#{CommonMethods.current_time}'/>"
    )
  end

  def redeem_value_card(cus_id, pin, locale)
    pin_info = generate_pin_info_by_locale(locale)[0]
    CommonMethods.soap_call(
      @service_info[:endpoint],
      @service_info[:namespace],
      :redeem_value_card,
      "<caller-id>#{CONST_CALLER_ID}</caller-id>
      <session type='service'/>
      <cust-key>#{cus_id}</cust-key>
      <pin-text>#{pin}</pin-text>
      <locale>#{pin_info[:locale]}</locale>
      <references key='accountSuffix' value='#{pin_info[:reference][:accountSuffix]}'/>
      <references key='currency' value='#{pin_info[:reference][:currency]}'/>
      <references key='locale' value='#{pin_info[:reference][:locale]}'/>
      <references key='CUST_KEY' value='#{cus_id}'/>
      <references key='transactionId' value='#{pin_info[:reference][:transactionId]}'/>"
    )
  end

  def fetch_pin_attributes(pin)
    CommonMethods.soap_call(
      @service_info[:endpoint],
      @service_info[:namespace],
      :fetch_pin_attributes,
      "<caller-id>#{CONST_CALLER_ID}</caller-id>
      <session type='service'/>
      <pin-text>#{pin}</pin-text>"
    )
  end

  def get_pin_information(pin)
    res = fetch_pin_attributes pin
    return { has_error: 'error', message: res[1] } unless res.is_a?(Nokogiri::XML::Document)

    {
      has_error: 'none',
      status: res.xpath('//pins/@status').text,
      locale: res.xpath('//pins/@locale').text,
      currency: res.xpath('//pins/@currency').text,
      amount: res.xpath('//pins/@amount').text,
      type: res.xpath('//pins/@type').text
    }
  end

  #
  # get pin status
  # return: pin status: AVAILABLE, REDEEMED,...
  #
  def get_pin_status(pin)
    res = fetch_pin_attributes pin
    res.is_a?(Nokogiri::XML::Document) ? res.xpath('//pins/@status').text : res[1]
  end

  #
  # Get PIN information by locale
  #
  def generate_pin_info_by_locale(locale)
    pin_info = [
      { locale: 'US', reference: { accountSuffix: 'USD', currency: 'USD', locale: 'en_US', transactionId: 'testUS' } },
      { locale: 'CA', reference: { accountSuffix: 'CAD', currency: 'CAD', locale: 'en_CA', transactionId: 'testCA' } },
      { locale: 'GB', reference: { accountSuffix: 'GBP', currency: 'GBP', locale: 'en_UK', transactionId: 'testUK' } },
      { locale: 'IE', reference: { accountSuffix: 'EUR', currency: 'EUR', locale: 'en_IE', transactionId: 'testIE' } },
      { locale: 'AU', reference: { accountSuffix: 'AUD', currency: 'AUD', locale: 'en_AU', transactionId: 'testROW' } },
      { locale: 'ROW', reference: { accountSuffix: 'USD', currency: 'USD', locale: 'en_ROW', transactionId: 'testROW' } },
      { locale: 'fr_FR', reference: { accountSuffix: 'EUR', currency: 'EUR', locale: 'fr_FR', transactionId: 'testFR_FR' } },
      { locale: 'fr_CA', reference: { accountSuffix: 'CAD', currency: 'CAD', locale: 'fr_CA', transactionId: 'testFR_CA' } },
      { locale: 'fr_ROW', reference: { accountSuffix: 'USD', currency: 'USD', locale: 'fr_ROW', transactionId: 'testFR_ROW' } }
    ]

    pin_info.select { |pin| pin[:locale] == locale }
  end
end
